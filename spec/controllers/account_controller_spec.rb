require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include ActiveMerchant::Billing::Integrations
 
describe AccountController do
  fixtures :users
  
  describe "login" do
    before(:each) { @identity_url = "http://foo.com" }
    it "should use openid authentication if params include openid_url" do
      controller.should_receive(:authenticate_with_open_id)
      post :login, :openid_url  => @identity_url
    end
    it "should use openid authentication if params include openid_identifier" do
      controller.should_receive(:authenticate_with_open_id)
      post :login, :openid_identifier  => @identity_url
    end
    
    describe "with successful authentication" do
      # NOTE: Mocking is getting tricky here so lets defer these specs for now in the interest of time
      it "should store the user in the session if user with matching openid_url is found"
      it "should create a new user if an email parameter is returned"
      it "should allow user to associate the openid with an existing user if an email match is found"
      it "should ask user to supplly an email if no matching user is found"
    end
  end
end