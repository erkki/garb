require File.join(File.dirname(__FILE__), '..', '..', '/test_helper')

module Garb
  class ProfileTest < MiniTest::Unit::TestCase
    
    context "The Profile class" do
      setup {@session = Session.new}

      should "be able to return a list of all profiles" do
        url = 'https://www.google.com/analytics/feeds/accounts/default'

        xml = read_fixture('profile_feed.xml')

        data_request = stub
        data_request.stubs(:send_request).returns(stub(:body => xml))
        DataRequest.stubs(:new).returns(data_request)

        assert_equal ['12345', '12346'], Profile.all(@session).map(&:id)
        assert_received(DataRequest, :new) {|e| e.with(@session, url)}
        assert_received(data_request, :send_request)
      end

      should "return the first profile for a given web property id" do
        profile1 = stub(:web_property_id => '12345', :id => 'abcdef')
        profile2 = stub(:web_property_id => '67890', :id => 'ghijkl')
        entries = [profile1, profile2]

        Profile.stubs(:all).returns(entries)

        assert_equal profile1, Profile.first('12345', @session)

        assert_received(Profile, :all) {|e| e.with(@session)}
      end

      should "return the first profile for a given table id" do
        profile1 = stub(:id => '12345', :web_property_id => 'abcdef')
        profile2 = stub(:id => '67890', :web_property_id => 'ghijkl')
        entries = [profile1, profile2]

        Profile.stubs(:all).returns(entries)

        assert_equal profile2, Profile.first('67890', @session)

        assert_received(Profile, :all) {|e| e.with(@session)}
      end
    end

    context "An instance of the Profile class" do
      setup do
        entry = Profile.parse(read_fixture('profile_feed.xml')).first
        @profile = Profile.new(entry, Session)
      end

      should "have a value for :title" do
        assert_equal "Historical", @profile.title
      end
    
      should "have a value for :table_id" do
        assert_equal 'ga:12345', @profile.table_id
      end
    
      should "have a value for :id" do
        assert_equal '12345', @profile.id
      end
    
      should "have a value for :account_id" do
        assert_equal '1111', @profile.account_id
      end
    
      should "have a value for :account_name" do
        assert_equal 'Blog Beta', @profile.account_name
      end
    end
  end
end
