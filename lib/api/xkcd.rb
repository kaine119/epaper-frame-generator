require 'date'
require 'json'
require 'net/http'
require 'open-uri'
require 'uri'

module XKCD
  HOSTNAME = 'https://xkcd.com'
  INFO_ENDPOINT = 'info.0.json'

  # Fetch the latest comic.
  def self.latest
    data = JSON.parse Net::HTTP.get(URI("#{HOSTNAME}/#{INFO_ENDPOINT}"))  
    comic_date = DateTime.new(*%w[year month day].map { |s| data.fetch(s).to_i })
    XKCDComic.new(*%w[img alt title transcript num].map { |s| data.fetch(s) }, comic_date) 
  end

  # Fetch a comic with a certain number.
  def self.by_number(comic_number)
    data = JSON.parse Net::HTTP.get(URI("#{HOSTNAME}/#{comic_number}/#{INFO_ENDPOINT}"))  
    comic_date = DateTime.new(*%w[year month day].map { |s| data.fetch(s).to_i })
    XKCDComic.new(*%w[img alt title transcript num].map { |s| data.fetch(s) }, comic_date) 
  end

  # One xkcd entry. Don't initialize one of these yourself, use the methods XKCD.latest and XKCD.for_number.
  class XKCDComic
    # @returns [string] a direct url to the image file.
    attr_reader :image_url

    # @returns [string] the alt text for this comic.
    attr_reader :alt_text
    alias_method :title_text, :alt_text
    alias_method :hovertext, :alt_text

    # @returns [string] the title of this comic.
    attr_reader :title

    # @returns [string] the transcript of this comic, if any.
    attr_reader :transcript

    # @returns [integer] the serial number for this comic.
    attr_reader :comic_number

    # @returns [DateTime] the date this comic was published.
    attr_reader :date

    def initialize(image_url, alt_text, title, transcript, comic_number, date)
      @image_url = image_url
      @alt_text = alt_text
      @title = title
      @transcript = transcript
      @comic_number = comic_number
      @date = date
    end

    # @returns a link to the comic page (e.g. https://xkcd.com/39)
    def page_url
      "https://xkcd.com/#{@comic_number}"
    end

    # Downloads and returns the image as a byte string.
    # @returns [string] The bytes of an image.
    def image_blob
      open(@image_url).read
    end
    alias_method :image_bytes, :image_blob
    alias_method :image, :image_blob

    def inspect
      "<XKCD::XKCDComic \##{@comic_number}: #{@title}>"
    end
  end
end
