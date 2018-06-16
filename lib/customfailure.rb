class CustomFailure < Devise::FailureApp
  def redirect_url
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end