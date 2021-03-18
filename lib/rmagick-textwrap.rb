class WordWrapper
  # Initializes a wrapper with the parameters needed to measure out wraps.
  # @param text [string] The string to wrap.
  # @param text_width [integer] The width of the text field.
  # @param font [string] The font to use for measurement.
  # @param gravity [Magick::GravityType] How text should be laid out within the text field.
  def initialize(text, text_width, font, fontsize, gravity)
    @text = text
    @text_width = text_width
    @font = font
    @fontsize = fontsize
    @gravity = gravity
  end

  # Creates a temporary image to check if text needs to be wrapped, given the current width.
  # @param text [string] The string to be checked.
  # @return [bool] Whether the text exceeds the width of the current wrapper.
  def needs_splitting?(text)
    return false if text.empty?
    tmp_image = Magick::Image.new(@text_width, 500)
    drawing = Magick::Draw.new
    drawing.gravity = @gravity
    drawing.pointsize = @fontsize
    drawing.fill = "#ffffff"
    drawing.font_family = 'Montserrat'
    drawing.annotate(tmp_image, @text_width, @text_width, 0, 0, text)
    metrics = drawing.get_multiline_type_metrics(tmp_image, text)
    return metrics.width >= @text_width
  end

  # Iterates over the text, adding newlines where needed.
  # @return [string] the text wrapped with newlines.
  def wrap
    return @text unless needs_splitting?(@text)

    separator = ' '
    current_line = ''
    lines = []
    @text.split(separator).each do |word|
      if needs_splitting? current_line + word
        lines << current_line.strip
        current_line = ''
      end
      current_line += word + separator
    end
    lines << current_line.strip
    return lines.join("\n")
  end
end
