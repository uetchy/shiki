式(Shiki) beta
=============

式(Shiki)はTwitter Botを作成するためのイベントドリブンモデルのフレームワークです。

主な特徴
-------------

* イベントドリブンモデルの記法
* Pupilとの統合によりTwitter APIをRubyライクな文法で呼び出しできます(Pupilとは式のために作られたTwitter APIラッパーのこと)
* 札(Fuda)プラグインを追加することで機能拡張ができます

必要なもの
-------------

* pupil, json, oauth gem
* Ruby 1.9.x

導入方法
-------------

	gem install shiki

サンプル
-------------
頻繁にリプライを送ってくる迷惑ユーザーに苦言を呈するBotの例(メリーさんBot)

	require "shiki"

	OAUTH_KEY = {
		:consumer_key => "something",   	# Required
		:consumer_secret => "something"		# Required
		:access_token => "something",       # Required
		:access_token_secret => "something" # Required
	}
	
	class Merry < Shiki::Base # クラス全体でひとつのBotとして抽象化する
      set :oauth_key, OAUTH_KEY
      
      use :memory, :on => "databases/memory/memory.db" # Memory.rb Plug-in
      
      event :mention do |status|
        user = memory.remember :person => status.user # Memoryからユーザーを呼び出し
        if user.replied_average_time < 40 # 平均リプライ頻度が40秒以内の時
          status.user.reply("頻繁にリプ飛ばしてくるの、正直鬱陶しいんです。やめてください")
        end
      end
    end

	merry = Merry.new
 	merry.run
 	
自動でフォロー返ししつつ挨拶も送る気さくなBotの例(おおあめさんBot)

	require "shiki"

	OAUTH_KEY = {
		:consumer_key => "something",   	# Required
		:consumer_secret => "something"		# Required
		:access_token => "something",       # Required
		:access_token_secret => "something" # Required
	}
	
	class Oame < Shiki::Base
      set :oauth_key, OAUTH_KEY
      
      event :follow do |user|
      	user.follow
      	user.reply("フォローありがと！#{user.name}って呼べばいいのかしら？よろしくね！")
      end
    end

	oame = Oame.new
 	oame.run
 	
リプライをオウム返しするBotの例(響子さんBot)

	require "shiki"

	OAUTH_KEY = {
		:consumer_key => "something",   	# Required
		:consumer_secret => "something"		# Required
		:access_token => "something",       # Required
		:access_token_secret => "something" # Required
	}
	
	class Kyoko < Shiki::Base
      set :oauth_key, OAUTH_KEY
      
      event :mention do |status|
      	if status.text =~ /いちたすいちはー/
      	  status.user.reply("・・・") # 算数は苦手
      	else
      	  status.user.reply(status.text) # 山彦なので
      	end
      end
    end

	kyoko = Kyoko.new
 	kyoko.run

Credits
-------------

Developer: [Oame](http://twitter.com/o_ame)

License
-------------

Copyright (c) 2011 Oame. See LICENSE.txt for
further details.

