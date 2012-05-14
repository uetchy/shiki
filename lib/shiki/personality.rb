require "sequel"

module Shiki
  class Personality
    def initialize pattern_db
      @db = Sequel.sqlite pattern_db
      @tweets  = @db[:tweets]
      @replies = @db[:replies]
      @locations = @db[:locations]
    end
    
    def tweets time_zone, week
      
    end
    
    def replies fear, interest
      
    end
    
    def random_location
      return @locations.to_a
    end
  end
end