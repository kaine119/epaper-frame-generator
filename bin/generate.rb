#!/usr/bin/env ruby

require 'rmagick'
require 'generator'

if ARGV.first.nil?
  puts <<-HELP
    Usage: generate.rb <image-path>
  HELP
  exit 1
end

template = Magick::Image.read("template.bmp").first

frame = Generator::FrameGenerator.new(template)
frame.generate!
frame.write(ARGV.first)
