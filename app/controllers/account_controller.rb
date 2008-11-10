class AccountController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => :login   
  before_filter :login_from_cookie

  def index
    redirect_to(login_path) unless logged_in? || User.count > 0
  end

  def login
    if session[:openid_url] && session[:openid_email]
      flash.now[:notice] = "OpenID authentication successful. Please authenticate with your email and password to associate this existing account with your OpenID URL."
    end
    return unless request.post?
    if using_open_id?
      self.current_user = open_id_authentication
    else
      self.current_user = User.authenticate(params[:email], params[:password])
    end
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(products_path)
      flash.now[:notice] = "Logged in successfully"
    else
      flash.now[:error] = "Login authentication failed."
    end
  end 
  
  # logout method is unmodified from original (so far)
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
    #redirect_back_or_default(:controller => '/account', :action => 'index')
  end

  protected
  def open_id_authentication
    identity_url = params[:openid_identifier] || params[:openid_url]
    identity_url = normalize_url(identity_url) if identity_url
    # Pass optional :required and :optional keys to specify what sreg fields you want.
    # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
    authenticate_with_open_id(identity_url, :required => [ :email ]) do |result, identity_url, registration|
      current_user = nil
      case result.status
      when :missing
        failed_login "Sorry, the OpenID server couldn't be found"
      when :invalid
        failed_login "Sorry, but this does not appear to be a valid OpenID"
      when :canceled
        failed_login "OpenID verification was canceled"
      when :failed
        failed_login "Sorry, the OpenID verification failed"
      when :successful
        if current_user = User.find_by_identity_url(identity_url)
          session[:user_id] = current_user.id
        else
          begin
            email = registration["email"]
            # check if a user ewith this email already exists
            user = User.find_by_email(registration["email"])
            if user
              # user will need to authenticate first, then they associate this user with their account
              session[:openid_url] = identity_url
              session[:openid_email] = email
              redirect_to edit_user_url(user) and return
            else  
              if email.blank?
                # user authenticated by their openid provider did not provide an email
                session[:openid_url] = identity_url
                redirect_to new_user_url and return
              end              
              # no user but they did provide an email so we can create an account for them
              user = User.create(:email => email, :identity_url => identity_url)
              session[:user_id] = user.id
            end
          rescue
            # user has no email in the profile or chose not to send us one
          end      
        end
      else  
      end
    end  
    user_id = session[:user_id]
    return user_id ? User.find(user_id) : nil  
  end
    
  def failed_login(message)
    flash.now[:error] = message
    redirect_to(new_session_url)
  end
      
end
