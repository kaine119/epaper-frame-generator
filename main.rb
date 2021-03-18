require 'calendar'
require 'date'
require 'net/http'
require 'rmagick'
require 'rmagick-textwrap'
require 'uri'
require 'weather'
require 'xkcd'

composite = Magick::Image.read("template.bmp").first

# date
now = DateTime.now
year, month, day, timestring, ampm = %w[%Y %b %-d %-l:%M %-P].map { |s| now.strftime(s).downcase }
#year, month, day, timestring, ampm = %w[2021 oct 31 12:48 pm]
p year, month, day, timestring, ampm

text_draw = Magick::Draw.new
text_draw.text_antialias = false
text_draw.gravity = Magick::NorthWestGravity
text_draw.font_style = Magick::NormalStyle

text_draw.annotate(composite, 85, 85, 30, 15, day) {
  self.pointsize = 85
  self.font_family = 'Montserrat'
}

text_draw.annotate(composite, 70, 70, 115, 28, "#{month}\n#{year}") {
  self.pointsize = 35
  self.font_family = 'Montserrat'
  self.interline_spacing = -7.0
}

text_draw.annotate(composite, 90, 50, -52, -110, timestring) {
  self.interline_spacing = 0
  self.pointsize = 45
  self.font_family = 'Montserrat'
  self.gravity = Magick::SouthEastGravity
}

text_draw.annotate(composite, 50, 50, 140, -105, ampm) {
  self.pointsize = 25
  self.font_family = 'Montserrat'
  self.gravity = Magick::SouthWestGravity
}

# Weather
weather = Weather.today
weather_icon_path = "weather_icons/#{weather.outlook['code']}_#{weather.day? ? 'day' : 'night'}.bmp"
weather_icon = Magick::Image.read(weather_icon_path).first
                            .resize_to_fit(80, 80)
composite.composite!(weather_icon, 210, 30, Magick::SrcOverCompositeOp)

text_draw.annotate(composite, 110, 70, 300, 25, weather.temperature.to_s) {
  self.gravity = Magick::NorthWestGravity
  self.pointsize = 65
  self.font_family = 'Montserrat'
}

text_draw.annotate(composite, 50, 40, 375, 30, "°C") {
  self.gravity = Magick::NorthGravity
  self.pointsize = 40
  self.font_family = 'Montserrat'
}

# Bold the first one for morning, second one for afternoon, third one for night.
weather.precipitation_chances
  .map { |s| s.to_s + '%' }
  .each.with_index do |precipitation, i|
    text_draw.annotate(composite, 0, 0, 215 + 75 * i, 110, precipitation) {
      self.gravity = Magick::NorthWestGravity
      self.pointsize = 30
      self.font_family = 'Montserrat'

      case now.hour
      when (6..12)
        self.font_weight = if i == 0; Magick::BoldWeight; else; Magick::NormalWeight; end
      when (12..18)
        self.font_weight = if i == 1; Magick::BoldWeight; else; Magick::NormalWeight; end
      when (0..6), (19..24)
        self.font_weight = if i == 2; Magick::BoldWeight; else; Magick::NormalWeight; end
      else
        self.font_weight = Magick::NormalWeight
      end
    }
  end


text_draw.annotate(composite, 0, 0, 260, 160, "chance of rain") {
  self.font_weight = Magick::NormalWeight
  self.pointsize = 14
  self.font_family = 'Sans-serif'
  self.kerning = 3
}

# XKCD
xkcd = XKCD.latest
xkcd_blob = xkcd.image

xkcd_image = Magick::Image.from_blob(xkcd_blob).first
                          .resize_to_fit(417, 245)

reference = Magick::Image.constitute(3, 1, 'RGB', [
  1.0, 0.0, 0.0, # red
  0.0, 0.0, 0.0, # black
  1.0, 1.0, 1.0  # white
])

if xkcd_image.gray?
  xkcd_image = xkcd_image.threshold(0xffff * 0.65)
else
  xkcd_image = xkcd_image.remap(reference, Magick::FloydSteinbergDitherMethod) 
end

# center mid = 220, 350
left = 220 - (xkcd_image.columns / 2)
top = 350 - (xkcd_image.rows / 2)
composite.composite!(xkcd_image, left, top, Magick::SrcOverCompositeOp)

text_draw.annotate(composite, 420, 50, 10, 180, "#{xkcd.comic_number}: #{xkcd.title}") {
  self.pointsize = 25
  self.font_family = 'Montserrat'
  self.gravity = Magick::CenterGravity
  self.kerning = 0
}

wrapper = WordWrapper.new(xkcd.alt_text, 400, 'Montserrat', 14, Magick::NorthGravity)
text_draw.annotate(composite, 420, 100, 10, 473, wrapper.wrap) {
  self.pointsize = 14
  self.font_family = 'Montserrat'
  self.gravity = Magick::NorthGravity
}

# calendar
events = {
  DateTime.parse('2021-03-18') => [
    Calendar::Event.new(DateTime.parse('2021-03-18 10:00pm'), "Run"),
  ],
  DateTime.parse('2021-03-19') => [
    Calendar::Event.new(DateTime.parse('2021-03-19 12:00pm'), "Lunch with Jade"),
    Calendar::Event.new(DateTime.parse('2021-03-19 1:00pm'), "10.002 Design in our world"),
  ]
}

p events

4.times do |i|
  day = (now + i).to_date
  text_draw.annotate(composite, 110, 132, 440, 132 * i, day.strftime("%a")) {
    self.gravity = Magick::CenterGravity
    self.pointsize = 30
    self.font_family = 'Montserrat'
    self.fill = if i == 0
                  "red"
                else
                  "black"
                end
  }

  begin
    events.fetch(day).first(3).each.with_index do |event, j|
      text_draw.annotate(composite, 105, 132, -550 + -110 * j, 132 * i, event.datetime.strftime('%-I %P')) {
        self.fill = 'black'
        self.gravity = Magick::NorthEastGravity
        self.pointsize = 30
      }
      title_wrapper = WordWrapper.new(event.title, 105, 'Montserrat', 20, Magick::NorthEastGravity)
      p title_wrapper.wrap
      text_draw.annotate(composite, 105, 132, -550 + -110 * j, 132 * i + 35, title_wrapper.wrap) {
        self.fill = 'black'
        self.gravity = Magick::NorthEastGravity
        self.pointsize = 20
      }
    end
  rescue KeyError
    p 'no event'
    text_draw.annotate(composite, 330, 132, 550, 132 * i, 'Nothing for today') {
      self.gravity = Magick::CenterGravity
      self.pointsize = 25
      self.undercolor = 'white'
    }
  end
end

composite.write("test.png")
