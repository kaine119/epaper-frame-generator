require 'generator/api/weather'
require 'rmagick'

module Generator
  class WeatherGenerator
    def self.write_to(image)
      text_draw = Magick::Draw.new
      text_draw.text_antialias = false
      text_draw.font_style = Magick::NormalStyle

      weather = Weather.today
      weather_icon_path = "weather_icons/#{weather.outlook.fetch("icon")}.bmp"
      weather_icon = Magick::Image.read(weather_icon_path).first
                                  .resize_to_fit(100, 100)
      image.composite!(weather_icon, 200, 15, Magick::SrcOverCompositeOp)

      text_draw.annotate(image, 110, 70, 300, 25, weather.temperature.to_s) {
        self.gravity = Magick::NorthWestGravity
        self.pointsize = 65
        self.font_family = 'Montserrat'
      }

      text_draw.annotate(image, 50, 40, 375, 30, "°C") {
        self.gravity = Magick::NorthGravity
        self.pointsize = 40
        self.font_family = 'Montserrat'
      }

      # Bold the first one for morning, second one for afternoon, third one for night.
      weather.precipitation_chances.first(3)
        .map { |s| s.to_s + '%' }
        .each_with_index do |precipitation, i|
          text_draw.annotate(image, 0, 0, 215 + 75 * i, 110, precipitation) {
            self.gravity = Magick::NorthWestGravity
            self.pointsize = 30
            self.font_family = 'Montserrat'
            self.font_weight = if i == 0
                                 Magick::BoldWeight
                               else
                                 Magick::NormalWeight
                               end
          }
        end

      text_draw.annotate(image, 220, 50, 210, 160, "chance of rain") {
        self.font_weight = Magick::NormalWeight
        self.gravity = Magick::NorthGravity
        self.pointsize = 14
        self.font_family = 'Sans-serif'
        self.kerning = 3
      }
    end
  end
end
