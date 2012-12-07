# -*- coding: utf-8 -*-
require "sequel"
require "json"
require "time"

class Memory < Shiki::Fuda
  attr_reader :db

  def self.prepare(option)
    @db = Sequel.sqlite(option[:on])
    
    # Initialize Knowledge
    unless @db.table_exists? :knowledge
      @db.create_table :knowledge do
        primary_key :id
        String :key
        String :value
      end
    end

    # Initialize People
    unless @db.table_exists? :people
      @db.create_table :people do
        primary_key :id
        String :id
        String :screen_name
        String :nickname
        Float  :fear # active reply ratio; based on dst reply.
        Float  :interest # passive reply ratio; Math.exp(-8*5**-2)*100 => Math.exp(-:timerag * :ratio) * 100
        Fixnum :mental_lock
        Fixnum :last_tweet_time
        String :recent_tweet_time
        Fixnum :last_reply_time
        String :recent_reply_time
        Fixnum :last_replied_time
        String :recent_replied_time
        String :last_tweet_text
        String :recent_tweet_text
        String :last_reply_text
        String :recent_reply_text
        String :last_replied_text
        String :recent_replied_text
      end
    end
    
    return self
  end

  # Add user to database
  # @return [Hash] Person record
  def self.create_person(person)
    response = @db[:people].insert(
    :id => person.id_str,
    :screen_name => person.screen_name,
    :nickname => person.name,
    :fear => 0.2,
    :interest => 1.0,
    :mental_lock => 0,
    :last_tweet_time => 0,
    :recent_tweet_time => [0, 0, 0, 0, 0].to_json,
    :last_reply_time => 0,
    :recent_reply_time => [0, 0, 0, 0, 0].to_json,
    :last_replied_time => 0,
    :recent_replied_time => [0, 0, 0, 0, 0].to_json,
    :last_tweet_text => "",
    :recent_tweet_text => ["", "", "", "", ""].to_json,
    :last_reply_text => "",
    :recent_reply_text => ["", "", "", "", ""].to_json,
    :last_replied_text => "",
    :recent_replied_text => ["", "", "", "", ""].to_json
    )
    return Person.new(@db[:people].where(:id => person.id_str).all.first, @db)
  end

  # Finding person on memory
  # @return [Hash] Person record
  def self.remember option
    option = [*option][0]
    case option[0]
    when :person
      people = @db[:people]
      result = people.where(:id => option[1].id_str).all.first
      return (!result.nil?)? Person.new(result, @db) : self.create_person(option[1])
    when :knowledge
      @db[:knowledge].where(:key => option[1]).value
    end
  end

  class Person < Hash
    def initialize(person, db)
      super(person)
      @db = db
      @person = person
    end

    def update(query)
      people = @db[:people]
      people.where(:id => @person[:id]).update(query)
      @person = people.where(:id => @person[:id]).all.first
      return @person
    end

    def method_missing(action, arg=nil)
      method = action.to_s.sub(/=$/, "").to_sym
      if @person.keys.index(method)
        if action.match(/=$/)
          self.update(method => arg)
        else
          return @person[method]
        end
      else
        return nil
      end
    end
    
    def interest_ratio(ratio=5**-7)
      rag = self.diff_latest_reply_time
      return Math.exp(-rag * ratio) * 100
    end
    
    def fear_ratio(status, ratio=1.07)
      fear = @person[:fear]
      if status.text.positive?
        return fear + ((fear ** ratio) - fear)
      else
        return fear - ((fear ** ratio) - fear)
      end
    end
    
    def combined_favor(status)
      interest = self.interest_ratio
      fear = self.fear_ratio(status)
      puts "#{interest}, #{fear}"
      puts (interest + fear)/2
    end
    
    def levenshtein_distance(str1, str2)
      col, row = str1.size + 1, str2.size + 1
      d = row.times.inject([]){|a, i| a << [0] * col }
      col.times {|i| d[0][i] = i }
      row.times {|i| d[i][0] = i }

      str1.size.times do |i1|
        str2.size.times do |i2|
          cost = str1[i1] == str2[i2] ? 0 : 1
          x, y = i1 + 1, i2 + 1
          d[y][x] = [d[y][x-1]+1, d[y-1][x]+1, d[y-1][x-1]+cost].min
        end
      end
      d[str2.size][str1.size]
    end

    def replied_average_time
      time = self.recent_replied_time
      ave = 0
      time.reverse.each_cons(2) do |f, l|
        ave += f-l
      end
      return ave/time.size
    end

    def reply_average_time
      time = self.recent_reply_time
      ave = 0
      time.reverse.each_cons(2) do |f, l|
        ave += f-l
      end
      return ave/time.size
    end

    def diff_latest_replied_time(mergediff=true)
      time = self.recent_replied_time
      diff = time[3, 5].reverse
      return (mergediff)? diff[0]-diff[1] : diff
    end

    def diff_latest_reply_time(mergediff=true)
      time = self.recent_reply_time
      diff = time[3, 5].reverse
      return (mergediff)? diff[0]-diff[1] : diff
    end
    
    # *_replied functions
    def recent_tweet_time
      return JSON.parse(@person[:recent_tweet_time])
    end

    def recent_tweet_text
      return JSON.parse(@person[:recent_tweet_text])
    end

    # *_replied functions
    def recent_replied_time
      return JSON.parse(@person[:recent_replied_time])
    end

    def recent_replied_text
      return JSON.parse(@person[:recent_replied_text])
    end

    # *_reply functions
    def recent_reply_time
      return JSON.parse(@person[:recent_reply_time])
    end

    def recent_reply_text
      return JSON.parse(person[:recent_reply_text])
    end
    
    def rotate_recent_tweet_time(time)
      rrt = self.recent_tweet_time
      rrt.slice!(0, 1)
      rrt.push(time)
      self.update(:recent_tweet_time => rrt.to_json)
    end    

    def rotate_recent_tweet_text(text)
      rrt = self.recent_tweet_text
      rrt.slice!(0, 1)
      rrt.push(text)
      self.update(:recent_tweet_text => rrt.to_json)
    end

    def rotate_recent_replied_time(time)
      rrt = self.recent_replied_time
      rrt.slice!(0, 1)
      rrt.push(time)
      self.update(:recent_replied_time => rrt.to_json)
    end

    def rotate_recent_replied_text(text)
      rrt = self.recent_replied_text
      rrt.slice!(0, 1)
      rrt.push(text)
      self.update(:recent_replied_text => rrt.to_json)
    end

    def rotate_recent_reply_time(time)
      rrt = self.recent_reply_time
      rrt.slice!(0, 1)
      rrt.push(time)
      self.update(:recent_reply_time => rrt.to_json)
    end    

    def rotate_recent_reply_text(text)
      rrt = self.recent_reply_text
      rrt.slice!(0, 1)
      rrt.push(text)
      self.update(:recent_reply_text => rrt.to_json)
    end
    
    def has_tweeted(status)
      tweeted_time = Time.parse(status.created_at).to_i
      self.update(:last_tweet_time => tweeted_time)
      self.update(:last_tweet_text => status.text)
      self.rotate_recent_tweet_time(tweeted_time)
      self.rotate_recent_tweet_text(status.text)
    end

    def has_replied(status)
      replied_text = text.sub(/^@[a-zA-Z0-9_]+?\s/, "").strip
      replied_time = Time.parse(status.created_at).to_i
      self.update(:last_replied_time => replied_time)
      self.update(:last_replied_text => replied_text)
      self.rotate_recent_replied_time(replied_time)
      self.rotate_recent_replied_text(replied_text)
    end

    def has_received(text)
      reply_text = text.sub(/^@[a-zA-Z0-9_]+?\s/, "").strip
      reply_time = Time.now.to_i
      self.update(:last_reply_time => reply_time)
      self.update(:last_reply_text => reply_text)
      self.rotate_recent_reply_time(reply_time)
      self.rotate_recent_reply_text(reply_text)
    end
  end
end
