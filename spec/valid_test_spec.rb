#!/usr/bin/env ruby
#! -*- coding: utf-8 -*-

require "rubygems"
require "rspec"
require "yaml"

TWEETS_FILE = "tweets.yml"
REPLY_PATTERNS_FILE = "reply_patterns.yml"
LOCATIONS_FILE = "locations.yml"

describe "YAML Configurations" do
  before do
    @tweets = YAML.load_file TWEETS_FILE
    @replies = YAML.load_file REPLY_PATTERNS_FILE
    @locations = YAML.load_file LOCATIONS_FILE
  end
  
  it "TweetsはHash型であること" do
    @tweets.class.should == Hash
  end
  
  it "RepliesはHash型であること" do
    @replies.class.should == Hash
  end
  
  it "LocationsはArray型であること" do
    @locations.class.should == Array
  end
end