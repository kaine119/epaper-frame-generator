require 'rmagick'
require 'generator/api/calendar'
require 'generator/rmagick-textwrap'

module Generator
  class CalendarGenerator
    def self.write_to(image)
      api = Calendar::API.new
      events = api.fetch_events(12)
      holidays = api.fetch_holidays(8)
      now = DateTime.now
      text_draw = Magick::Draw.new
      text_draw.text_antialias = false
      text_draw.font_style = Magick::NormalStyle

      text_draw.fill = "red"
      text_draw.fill_opacity 1.0
      text_draw.rectangle(443, 0, 548, 130)
      text_draw.draw(image)

      4.times do |i|
        day = (now + i).to_date
        if holidays[day].nil?
          text_draw.annotate(image, 110, 132, 440, 132 * i, day.strftime("%a").downcase) {
            self.gravity = Magick::CenterGravity
            self.pointsize = 30
            self.font_family = 'Montserrat'
            self.fill = if i == 0
                          "white"
                        else
                          "black"
                        end
            self.undercolor = if i == 0
                                "red"
                              else
                                "white"
                              end
          }
        else
          text_draw.annotate(image, 110, 132, 440, -132 * i + 66, day.strftime("%a").downcase) {
            p day.strftime("%a")
            self.gravity = Magick::SouthGravity
            self.pointsize = 30
            self.font_family = 'Montserrat'
            self.fill = if i == 0
                          "white"
                        else
                          "black"
                        end
            self.undercolor = if i == 0
                                "red"
                              else
                                "white"
                              end
          }
          wrapper = WordWrapper.new(holidays[day].first.title, 100, 'Montserrat', 16, Magick::NorthGravity)
          text_draw.annotate(image, 110, 132, 440, 132 * i + 66, wrapper.wrap) {
            self.gravity = Magick::NorthGravity
            self.pointsize = 16
            self.font_family = 'Montserrat'
            self.undercolor = "none"
            self.fill = "black"
          }
        end

        begin
          events.fetch(day).first(3).each.with_index do |event, j|
            text_draw.annotate(image,
                               105,
                               132,
                               -550 + -110 * j,
                               132 * i,
                               if event.allday? 
                                  "allday" 
                               else 
                                 event.datetime.strftime('%-I%P')
                               end) {
              self.fill = 'black'
              self.undercolor = 'none'
              self.gravity = Magick::NorthEastGravity
              self.pointsize = 30
            }
            title_wrapper = WordWrapper.new(event.title, 105, 'Montserrat', 20, Magick::NorthEastGravity)
            text_draw.annotate(image, 105, 132, -550 + -110 * j, 132 * i + 35, title_wrapper.wrap.downcase) {
              self.fill = 'black'
              self.gravity = Magick::NorthEastGravity
              self.pointsize = 20
            }
          end
        rescue KeyError
          text_draw.annotate(image, 330, 132, 550, 132 * i, 'nothing scheduled') {
            self.gravity = Magick::CenterGravity
            self.pointsize = 25
            self.undercolor = 'white'
            self.fill = 'black'
          }
        end
      end
    end
  end
end
