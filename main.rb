require 'rmagick'
require 'generator'

template = Magick::Image.read("template.bmp").first

frame = Generator::FrameGenerator.new(template)
frame.generate!
frame.write('test.png')
