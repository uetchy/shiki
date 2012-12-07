require "psych"
require "yaml"

# Reply based on favor
class Rbof < Shiki::Fuda
  def self.prepare(option)
    @@file = YAML.load_file(option[:file])
  end
  
  def self.replies; @@file; end
  
  def self.collect(event, text, favor)
    @@file[event.to_s].each do |match, option|
      if text =~ Regexp.new(match)
        puts "matching!"
        puts "#{match} => #{text}"
      end
    end
  end
end