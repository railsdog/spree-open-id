# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class OpenIdExtension < Spree::Extension
  version "1.0"
  description "Provides OpenID Support for Spree Accounts"
  url "http://spreehq.org"

  # define_routes do |map|
  #   map.namespace :admin do |admin|
  #     admin.resources :whatever
  #   end  
  # end

  def self.require_gems(config)
    config.gem "ruby-openid", :lib => 'openid', :version => '2.0.4'  
  end
  
  def activate

    # Add identity_url attribute to the user model
    User.class_eval do
      attr_accessible :identity_url
      protected
      def password_required?
        return false if identity_url
        crypted_password.blank? || !password.blank?
      end      
    end

    # Add a partial for adding the identity_url field to the user form
    UsersController.class_eval do

      before_filter :add_openid_fields

      def add_openid_fields
        @extension_partials << 'identity_url'
      end
      
      edit.before do 
        next unless openid_url = session[:openid_url]
        @user.identity_url = openid_url
      end

      update.after do    
        session[:openid_url] = nil
      end      
   
    end
  end
end