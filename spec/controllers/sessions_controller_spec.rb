require 'spec_helper'

describe SessionsController do
  
  describe "POST 'create'" do

    it "should redirect to oAuth dialog url without user_id" do
      @request.session['sub_domain'] = 'abc'
      # construct signed param
      param_hash = {'sub_domain' =>'abc', 'algorithm' => 'HMAC-SHA256'}
      param = SK::SDK::SignedRequest.signed_param( ActiveSupport::JSON.encode(param_hash), Sk::APP.secret)
      post :create, :signed_request => param
      response.body.should include"<script> top.location.href='http://abc.salesking.local:3000/oauth/authorize?"
    end

    it "should set session var with user_id" do
      @request.session['sub_domain'] = 'abc'
      # construct signed param
      param_hash = {'sub_domain' =>'abc', 'company_id'=>'xyz',
                    'access_token'=>'a-long-token',
                    'user_id'=>'xyz', 'algorithm' => 'HMAC-SHA256' }
      param = SK::SDK::SignedRequest.signed_param( ActiveSupport::JSON.encode(param_hash), Sk::APP.secret)
      
      post :create, :signed_request => param
      response.should redirect_to imports_url
      @request.session['user_id'].should == param_hash['user_id']
    end
  end


  describe "GET 'new'" do

    it "should redirect to app canvas url" do
      @request.session['sub_domain'] = 'abc'
      Sk::APP.should_receive(:get_token).with('some-token-code').and_return('an access token')
      get :new, :code=>'some-token-code'
      response.body.should =="<script> top.location.href='http://abc.salesking.local:3000/app/csv-importer'</script>"
    end

  end
end