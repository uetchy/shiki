# coding: utf-8

require "net/https"
require "time"
require "json"
require "oauth"
require "pupil"
require "pupil/stream"
require "shiki/fuda"
#require "shiki/personality"

module Shiki
  class Base
    attr_accessor :memory

    TWITTER_URL = "http://twitter.com"
    TWITTER_USERSTREAM_API = "https://userstream.twitter.com/2/user.json"

    SCHEMES = [
      [:status, :mention, :follow, :favorite, :retweet],
      [:search]
    ]

    def initialize
      super()
      @key = self.oauth_key
      @consumer = OAuth::Consumer.new(@key[:consumer_key], @key[:consumer_secret], :site => TWITTER_URL)
      @access_token = OAuth::AccessToken.new(@consumer, @key[:access_token], @key[:access_token_secret])
      register(:twitter => Pupil.new(@key))

      #register(:memory => Shiki::Memory.new(self.memory_database))
    end

    def register(option)
      self.class.register(option)
    end

    def call(action, num, option=nil)
      self.class.call(action, num, option)
    end

    def disharmony?(keys)
      i1 = keys.map{|k| SCHEMES[0].include?(k)}
      i2 = keys.map{|k| SCHEMES[1].include?(k)}
      return ((i1&i2).size > 0)? true : false
    end

    def guess_scheme(keys)
      if keys.map{|k| SCHEMES[0].index(k)}
        return :userstream
      else
        return :search
      end
    end

    def run
      keys = self.class.blocks.keys
      raise ArgumentError, "Disharnomy event blocks are detected." if disharmony?(keys)
      raise NoMethodError, "self.oauth_key not defined" unless self.respond_to? :oauth_key

      scheme = guess_scheme(keys)
      ps = Pupil::Stream.new self.oauth_key
      begin
        ps.start scheme do |status|
          #puts "Event: #{status.event}"
          case status.event
          when :status
            if status.text.match /^@/
              # Mention event
              next unless self.class.blocks[:mention]
              proc_status_event(:mention, status)
            else
              # Status event
              next unless self.class.blocks[:status]
              proc_status_event(:status, status)
            end
          when :retweet
            # Retweeted event
            next unless self.class.blocks[:retweet]
            proc_status_event(:retweet, status)
          when :follow
            # Foolow event
            next unless self.class.blocks[:follow]
            proc_follow(status)
          end
        end
      rescue Interrupt
        puts "> Stopping ..."
        exit()
      end
    end
    
    def proc_follow(status)
      blocks = self.class.blocks[:follow]
      num = 0
      blocks.each do |block|
        option = block[:option]
        call(:follow, num, status)
        num += 1
      end
    end
    
    def proc_status_event(event, status)
      blocks = self.class.blocks[event]
      num = 0
      blocks.each do |block|
        option = block[:option]
        if option
          response = []

          if option[:include]
            if Regexp.new(option[:include]) =~ status.text
              response << true
            else
              response << false
            end
          end
          
          if option[:from]
            if option[:from].to_s == status.user.screen_name
              response << true
            else
              response << false
            end
          end

          if response.index(false) == nil
            call(event, num, status)
            next
          else
            next
          end
        end
        
        call(event, num, status)
        num += 1
      end
    end
    
    class << self
      @@blocks = {}
      @@conditions = {}
      @@env = {}
      
      # Accessor methods

      def blocks; @@blocks; end
      def env(param); @@env[param]; end

      def register(opt)
        option = [*opt][0]
        @@conditions[option[0]] = option[1]
      end

      def call(action, num, option)
        @@blocks[action][num][:block].call option
      end
      
      def set(option, value=nil)
        #class_eval "def self.#{option}() #{value.inspect} ; end"
        define_method option, proc{ value }
      end

      def use(name, option=nil)
        require File.expand_path("../../fuda/#{name}/#{name}", $0)
        fuda = eval("#{name.capitalize}")
        @@env[:fuda] ||= {}
        @@env[:fuda].update(name.to_sym => {:block => fuda.prepare(option), :option => option})
      end
      
      def enable(func, option={})
        # e.g. enable :auto_follow
        # Not implement
        case func.to_sym
        when :auto_follow
          
        end
      end

      def event(action, option=nil, &block)
        @@blocks[action] ||= []
        @@blocks[action] << {:block => block, :option => option}
      end

      def method_missing(action, *option)
        @@env[:fuda].each do |name, option|
          p action
          p name
          return option[:block] if action == name
        end
        #raise NoMethodError
      end
      
      # Bot methods
      
      def say(sentence)
        @@conditions[:twitter].update(sentence)
      end
      
      alias_method :tweet, :say

      def reply(opts, status=nil)
        puts "get reply"
        raise ArgumentError, "target parameter not given" unless opts.values[0]
        sentence, target = opts.to_a.first
        name = nil
        case target.class.to_s
        when "Pupil::User"
          name = target.screen_name
        when "String"
          name = target
        when "Symbol"
          name = target.to_s
        end
        if status
          @@conditions[:twitter].update("@#{name} #{sentence}", status)
        else
          @@conditions[:twitter].update("@#{name} #{sentence}")
        end
      end
      
    end
  end
end