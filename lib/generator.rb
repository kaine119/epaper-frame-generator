require 'rmagick'
require 'generator/calendar'
require 'generator/datetime'
require 'generator/weather'
require 'generator/xkcd'

module Generator
  class FrameGenerator
    attr_reader :iamge

    def initialize(template)
      @image = template
    end
    
    def generate!
      DateTimeGenerator.write_to(@image)
      WeatherGenerator.write_to(@image)
      XKCDGenerator.write_to(@image)
      CalendarGenerator.write_to(@image)
    end

    def write(filename)
      @image.write(filename)
    end
  end
end
