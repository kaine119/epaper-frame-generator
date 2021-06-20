require "date"
require "fileutils"
require "icalendar"
require "open-uri"

module Calendar
  class Event < Struct.new(:datetime, :title, :allday?)
  end

  class API
    def initialize(calendar_urls)
      @calendars ||= []
      calendar_urls.each do |calendar_url|
        URI.open(calendar_url) do |f|
          @calendars += Icalendar::Calendar.parse(f)
        end
      end
    end

    def fetch_events(n_days)
      calendar_events = []
      @calendars.each do |calendar|
        calendar_events += calendar.events
                            .select { |event| 
                              p event.dtstart if event.summary == "[KE] Mount"
                              event.dtstart.to_datetime > DateTime.now && event.dtstart.to_datetime < DateTime.now + n_days 
                            }
                            .sort_by { |event| event.dtstart }
                            .first(n_days)
      end
      events = {} # Hash mapping day => [events]
      calendar_events.each do |event|
        # If the event is all-day, add it as an event for each day.
        # All-day events are marked with dtstart not having a time.
        if event.dtstart.respond_to? :hour
          date = event.dtstart.to_date
          events[date] ||= []
          events[date] << Event.new(event.dtstart, event.summary, false)
        else
          (event.dtstart...event.dtend).each do |date|
            events[date] ||= []
            events[date] << Event.new(event.dtstart, event.summary, true)
          end
        end
      end
      events
    end

    def fetch_holidays(n_days)
    end
  end
end
