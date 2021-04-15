require 'generator/api/xkcd'
require 'rmagick'

module Generator
  class XKCDGenerator
    def self.write_to(image)
      text_draw = Magick::Draw.new
      text_draw.text_antialias = false
      text_draw.font_style = Magick::NormalStyle

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
      image.composite!(xkcd_image, left, top, Magick::SrcOverCompositeOp)

      text_draw.annotate(image, 420, 50, 10, 180, "#{xkcd.comic_number}: #{xkcd.title}") {
        self.pointsize = 25
        self.font_family = 'Montserrat'
        self.gravity = Magick::CenterGravity
        self.kerning = 0
      }

      wrapper = WordWrapper.new(xkcd.alt_text, 400, 'Montserrat', 14, Magick::NorthGravity)
      text_draw.annotate(image, 420, 100, 10, 473, wrapper.wrap) {
        self.pointsize = 14
        self.font_family = 'Montserrat'
        self.gravity = Magick::NorthGravity
      }
    end
  end
end
