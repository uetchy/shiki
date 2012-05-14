式(Shiki) beta
=============

Shiki is The "Unidentified" Bot Framework for Twitter, written in Ruby.

Features / Problems
-------------

* Easy to write.

Requirement
-------------

* pupil, json and oauth gem
* Ruby 1.9.x

Installation
-------------

	gem install shiki

Examples
-------------
	require "shiki"

	OAUTH_KEY = {
		:consumer_key => "something",   	  # Required
		:consumer_secret => "something"		  # Required
		:access_token => "something",       # Required
		:access_token_secret => "something" # Required
	}
	
	class Merry < Shiki::Base
    set :oauth_key, OAUTH_KEY

    use :memory, :database => "databases/memory/memory.db"

    event :follow do |user|
      puts "Follow catched!"
    end

    event :mention, :from => "o_ame" do |status|
      user = memory.remember :person => status.user
      if user.replied_average_time < 40
        tweet = "頻繁にリプ飛ばしてくるの、正直鬱陶しいんです。やめてください"
        status.user.reply(tweet)
      end
    end
    end

	merry = Merry.new
 	merry.run

Credits
-------------

Developer: [Oame](http://twitter.com/o_ame)

License
-------------

Copyright (c) 2011 Oame. See LICENSE.txt for
further details.

