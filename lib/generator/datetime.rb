require 'date'

module Generator
  class DateTimeGenerator
    def self.write_to(image)
      #now = DateTime.now
      now = DateTime.new(2021, 4, 14, 17, 01, 00)
      year, month, day, timestring, ampm = %w[%Y %b %-d %-l:%M %-P].map { |s| now.strftime(s).downcase }

      text_draw = Magick::Draw.new
      text_draw.text_antialias = false
      text_draw.gravity = Magick::NorthWestGravity
      text_draw.font_style = Magick::NormalStyle

      text_draw.annotate(image, 80, 85, -33, 25, day) {
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

      greeting_text = "Good\n" + case now.hour
                                   when (6..12) then "Morning"
                                   when (12..18) then "Afternoon"
                                   when (18..20) then "Evening"
                                   else "Night"
                                 end

      text_draw.annotate(image, 200, 45, 30, 110, greeting_text) {
        self.pointsize = 23
        self.font_family = 'Montserrat'
        self.gravity = Magick::NorthWestGravity
      }
    end
  end
end
