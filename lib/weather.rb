require 'json'
require 'net/http'
require 'uri'
require 'date'

class Weather < Struct.new(:outlook, :temperature, :precipitation_chances, :haze?, :day?)
  HOSTNAME = "https://api.weatherapi.com/v1"
  API_KEY = "4fff719640f24335818132621211803"

  def self.today
    query = URI.encode_www_form({
      key: API_KEY,
      q: "Singapore",
      days: 1,
      aqi: "yes",
      alerts: "no"
    })
    data = JSON.parse Net::HTTP.get(URI("#{HOSTNAME}/forecast.json?#{query}"))

    current = data.fetch("current")
    hazy = current.fetch("air_quality").fetch("pm2_5") > 150
    outlook = current.fetch("condition")
    temperature = current.fetch("temp_c").round
    day = current.fetch("is_day") == 1

    hourly = data.dig("forecast", "forecastday", 0, "hour")
    raise if hourly.nil?

    morning, afternoon, night = [], [], []
    hourly.each do |forecast|
      time = Time.at(forecast.fetch("time_epoch")).to_datetime
      case time.hour
      when (6..12)
        morning << forecast.fetch("chance_of_rain").to_i
      when (12..18)
        afternoon << forecast.fetch("chance_of_rain").to_i
      when (0..6), (18..)
        night << forecast.fetch("chance_of_rain").to_i
      end
    end

    precipitation_chances = [morning, afternoon, night].map { |arr| arr.reduce(0) { |acc, i| acc + i/arr.length } }

    Weather.new(outlook, temperature, precipitation_chances, hazy, day)
  end
end
