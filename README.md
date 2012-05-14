式(Shiki) beta
=============

Shiki is The "Unidentified" Bot Framework for Twitter. written in Ruby.

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
	
	class UsefullBot < Shiki::Base
		set :oauth_key, OAUTH_KEY
		use :memory, :database => "databases/memory.db"
		
		event :mention do |status|
			status.user.reply "Guten morgen!"
		end
	end

Credits
-------------

Developer: [Oame](http://twitter.com/o_ame)

License
-------------

Copyright (c) 2011 Oame. See LICENSE.txt for
further details.

