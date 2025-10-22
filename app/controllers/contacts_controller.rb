class ContactsController < ApplicationController
  def new
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]
  end

  def create
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]

    # Verify Turnstile token
    turnstile_token = params["cf-turnstile-response"]
    unless TurnstileVerifier.verify(turnstile_token, request.remote_ip)
      render :new, status: :unprocessable_entity, locals: { error: "Please complete the security verification." }
      return
    end

    # Validate presence of fields
    if @name.blank? || @email.blank? || @message.blank?
      render :new, status: :unprocessable_entity, locals: { error: "Please fill out all fields." }
      return
    end

    # Send the email
    ContactMailer.submit_request(@name, @email, @message).deliver_later

    # Redirect to success page
    redirect_to contact_success_path
  end

  def success
    # This action just renders the success view
  end
end
