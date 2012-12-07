# -*- coding: utf-8 -*-
require "MeCab"
require "kconv"
require "sequel"

class Pn < Shiki::Fuda  
  def self.prepare(option)
    @@db = Sequel.sqlite(option[:dict])
    return self
  end
  
  def self.positive?(sentence)
    ems = [0, 0]

    @@db[:noun].each do |noun|
      if sentence.match noun[:word]
        case noun[:attr].to_sym
        when "p"
          ems[0] += 0.2
        when "n"
          ems[1] += 0.2
        end
      end
    end

    mecab = MeCab::Tagger.new("-O wakati")
    w_sentence = mecab.parse(sentence).toutf8

    @@db[:declinable_word].each do |decw|
      next unless decw[:word]
      if w_sentence.match decw[:word]
        case decw[:attr]
        when "p"
          ems[0] += 0.2
        when "n"
          ems[1] += 0.2
        end
      end
    end

    if ems[0] > ems[1]
      return true
    elsif ems[0] < ems[1]
      return false
    else
      return nil
    end
  end

  def self.negative?(sentence)
    ems = [0, 0]

    @@db[:noun].each do |noun|
      if sentence.match noun[:word]
        case noun[:attr].to_sym
        when "p"
          ems[0] += 0.1
        when "n"
          ems[1] += 0.1
        end
      end
    end

    mecab = MeCab::Tagger.new("-O wakati")
    w_sentence = mecab.parse(sentence).toutf8

    @@db[:declinable_word].each do |decw|
      next unless decw[:word]
      if w_sentence.match decw[:word]
        case decw[:attr]
        when "p"
          ems[0] += 0.2
        when "n"
          ems[1] += 0.2
        end
      end
    end

    if ems[0] > ems[1]
      return false
    elsif ems[0] < ems[1]
      return true
    else
      return nil
    end
  end
end

class String
  def positive?
    Pn.positive?(self)
  end

  def negative?
    Pn.negative?(self)
  end
end