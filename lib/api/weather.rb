require 'json'
require 'net/http'
require 'uri'
require 'date'

class Weather < Struct.new(:outlook, :temperature, :precipitation_chances)
  API_BASE = "https://api.openweathermap.org/data/2.5"
  API_KEY = File.open("config/weather.token").read().strip

  def self.today
    query = URI.encode_www_form({
      appid: API_KEY,
      lat: 1.334,
      lon: 103.945,
      exclude: "minutely,alerts",
      units: "metric"
    })
    data = JSON.parse Net::HTTP.get(URI("#{API_BASE}/onecall?#{query}"))

    current = data.fetch("current")
    outlook = current.fetch("weather").first
    temperature = current.fetch("temp").round

    precipitation_chances = 
      data.fetch("hourly")
      .map { |hour| (hour.fetch("pop") * 100).round  }

    Weather.new(outlook, temperature, precipitation_chances)
  end
end
