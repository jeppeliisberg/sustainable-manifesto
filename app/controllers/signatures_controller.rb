class SignaturesController < ApplicationController
  before_action :load_signature_from_session, only: [ :verify, :confirm, :resend_code ]
  before_action :load_signature_from_id, only: [ :edit, :update ]

  helper_method :previous_step

  def index
    @individual_count = Signature.where(signature_type: :individual).where.not(signed_at: nil).count
    @organization_count = Signature.where(signature_type: :organization).where.not(signed_at: nil).count

    signed_signatures = Signature.where.not(signed_at: nil).order(created_at: :desc)
    @pagy, @signatures = pagy(signed_signatures, items: 50)
  end

  def new
    @signature = Signature.new
  end

  def create
    # Verify Turnstile token
    turnstile_token = params["cf-turnstile-response"]
    unless TurnstileVerifier.verify(turnstile_token, request.remote_ip)
      @signature = Signature.new(signature_params)
      render :new, status: :unprocessable_entity, locals: { error: "Please complete the security verification." }
      return
    end

    @signature = Signature.find_or_initialize_by(email: signature_params[:email])

    # Check if already fully signed
    if @signature.signed?
      render :new, status: :unprocessable_entity, locals: {
        error: "You've already signed the manifesto.",
        show_contact_link: true
      }
      return
    end

    # If confirmed but not signed, allow resume
    if @signature.confirmed?
      @signature.send_confirmation_code!
      session[:signature_id] = @signature.id
      redirect_to verify_signatures_path, notice: "We've sent a verification code to continue your signature."
      return
    end

    # New signature - save name and send verification
    @signature.assign_attributes(signature_params)
    if @signature.save
      @signature.send_confirmation_code!
      session[:signature_id] = @signature.id
      redirect_to verify_signatures_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def verify
    unless @signature
      redirect_to new_signature_path, alert: "Please start by entering your email."
      return
    end

    @verification_code_hint = @signature.confirmation_token[0]
  end

  def confirm
    unless @signature
      redirect_to new_signature_path, alert: "Please start by entering your email."
      return
    end

    submitted_code = params[:code]&.strip
    expected_code = @signature.confirmation_token[0, 6]

    if submitted_code == expected_code
      @signature.update(confirmed_at: Time.current)
      redirect_to edit_signature_path(@signature)
    else
      @verification_code_hint = @signature.confirmation_token[0]
      render :verify, status: :unprocessable_entity, locals: { error: "Invalid verification code. Please try again." }
    end
  end

  def edit
    unless @signature&.confirmed?
      redirect_to new_signature_path, alert: "Please verify your email first."
      return
    end

    # Determine which step to show based on URL param or default
    @current_step = params[:step]&.to_sym || default_step(@signature)
  end

  def update
    unless @signature&.confirmed?
      redirect_to new_signature_path, alert: "Please verify your email first."
      return
    end

    current_step = params[:current_step]&.to_sym

    if @signature.update(update_signature_params)
      # Determine next step
      next_step = next_step_after(current_step, @signature)

      if next_step == :complete
        # Final step - mark as signed
        @signature.update(signed_at: Time.current)
        render :success
      else
        # Move to next step
        redirect_to edit_signature_path(@signature, step: next_step)
      end
    else
      @current_step = current_step
      render :edit, status: :unprocessable_entity
    end
  end

  def resend_code
    unless @signature
      redirect_to new_signature_path, alert: "Please start by entering your email."
      return
    end

    unless @signature.can_resend_code?
      @verification_code_hint = @signature.confirmation_token[0]
      render :verify, status: :unprocessable_entity, locals: { error: "Please wait at least 1 minute before requesting a new code." }
      return
    end

    @signature.send_confirmation_code!

    redirect_to verify_signatures_path, notice: "A new verification code has been sent to your email."
  end

  private

  def signature_params
    params.require(:signature).permit(:email, :name)
  end

  def update_signature_params
    params.require(:signature).permit(:name, :signature_type, :title, :organization, :profile_url)
  end

  def load_signature_from_session
    @signature = Signature.find_by(id: session[:signature_id]) if session[:signature_id]
  end

  def load_signature_from_id
    @signature = Signature.find(params[:id])
  end

  def default_step(signature)
    # Always start at type selection - we show all steps now
    :signature_type
  end

  def next_step_after(current_step, signature)
    case current_step
    when :signature_type
      :details
    when :details
      :complete
    else
      :signature_type
    end
  end

  def previous_step(current_step)
    case current_step
    when :details
      :signature_type
    else
      nil # No previous step, go to root
    end
  end
end
