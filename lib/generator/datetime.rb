require 'date'

module Generator
  class DateTimeGenerator
    def self.write_to(image)
      now = DateTime.now
      year, month, day, timestring, ampm = %w[%Y %b %-d %-l:%M %-P].map { |s| now.strftime(s).downcase }

      text_draw = Magick::Draw.new
      text_draw.text_antialias = false
      text_draw.gravity = Magick::NorthWestGravity
      text_draw.font_style = Magick::NormalStyle

      text_draw.annotate(image, 85, 85, -33, 25, day) {
        self.gravity = Magick::EastGravity
        self.pointsize = 80
        self.font_family = 'Montserrat'
      }

      text_draw.annotate(image, 70, 70, 115, 28, "#{month}\n#{year}") {
        self.gravity = Magick::NorthWestGravity
        self.pointsize = 35
        self.font_family = 'Montserrat'
        self.interline_spacing = -7.0
      }

      text_draw.annotate(image, 90, 50, -52, -110, timestring) {
        self.interline_spacing = 0
        self.pointsize = 45
        self.font_family = 'Montserrat'
        self.gravity = Magick::SouthEastGravity
      }

      text_draw.annotate(image, 50, 50, 140, -105, ampm) {
        self.pointsize = 25
        self.font_family = 'Montserrat'
        self.gravity = Magick::SouthWestGravity
      }
    end
  end
end
