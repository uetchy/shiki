# -*- coding: utf-8 -*-
require "sequel"

class Personality << Shiki::Fuda
  def self.prepare(option)
    @@db = Sequel.sqlite(option[:on])
    @tweets  = @db[:tweets]
    @replies = @db[:replies]
    @locations = @db[:locations]
    return self
  end

  def self.tweets time_zone, week

  end

  def self.replies fear, interest

  end

  def self.random_location
    return @locations.to_a
  end
end
