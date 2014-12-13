#!/usr/bin/ruby -KU
# encoding: UTF-8

# Replaces high ascii characters with placeholders to avoid encoding issues when sending text through shell or AppleScript
class Preserve
  attr_accessor :legend

  def initialize
    @legend = {}
    @counter = 0
  end

  def tag(content)
    "xxx#{content}xxx"
  end

  def store(text)
    key = self.object_id.to_s + '-' + (@counter += 1).to_s
    @legend[key] = text
    key
  end

  def remove!(text,regex)
    text.gsub!(regex) do |match|
      tag(store(match))
    end
  end

  def remove(text,regex)
    remove!(text.dup,regex)
  end

  def restore!(text)
    @legend.each_pair do |key,value|
      text.gsub!(tag(key),value)
    end
    text
  end

  def restore(text)
    restore!(text.dup)
  end

end