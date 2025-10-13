class SignaturesController < ApplicationController
  before_action :load_signature_from_session, only: [ :verify, :confirm, :resend_code ]
  before_action :load_signature_from_id, only: [ :edit, :update ]

  def index
    @individual_count = Signature.where(signature_type: :individual).where.not(confirmed_at: nil).count
    @organization_count = Signature.where(signature_type: :organization).where.not(confirmed_at: nil).count

    confirmed_signatures = Signature.where.not(confirmed_at: nil).order(created_at: :desc)
    @pagy, @signatures = pagy(confirmed_signatures, items: 50)
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

    if @signature.confirmed?
      render :new, status: :unprocessable_entity, locals: { error: "This email has already been confirmed." }
      return
    end

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

    # Determine which step to show based on what's missing
    @current_step = determine_current_step(@signature)
  end

  def update
    unless @signature&.confirmed?
      redirect_to new_signature_path, alert: "Please verify your email first."
      return
    end

    # Store the current step before updating
    current_step_before_update = determine_current_step(@signature)

    if @signature.update(update_signature_params)
      # Special handling: if this was the individual details step, we're done
      # (all individual fields are optional, so any submission completes the flow)
      if current_step_before_update == :individual_details
        render :success
        return
      end

      # For other steps, check if we need to show another step
      current_step_after_update = determine_current_step(@signature)

      # If we're still on a step (not complete), redirect back to continue the flow
      if current_step_after_update != :complete
        redirect_to edit_signature_path(@signature)
      else
        # All required steps complete, show success
        render :success
      end
    else
      @current_step = current_step_before_update
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
    params.require(:signature).permit(:email)
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

  def determine_current_step(signature)
    return :name if signature.name.blank?
    return :signature_type if signature.signature_type.nil?
    # For individuals, always show details step (fields are optional)
    # For organizations, show details step until required fields are filled
    return :individual_details if signature.individual?
    return :organization_details if signature.organization? && signature_incomplete_organization?(signature)
    :complete
  end

  def signature_incomplete_organization?(signature)
    # For organizations, require organization name and profile URL
    signature.organization.blank? || signature.profile_url.blank?
  end
end
