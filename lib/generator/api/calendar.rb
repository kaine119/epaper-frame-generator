require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"


module Calendar
  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "e-ink Calendar Frame".freeze
  CREDENTIALS_PATH = "config/client_id.json".freeze

  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  class Event < Struct.new(:datetime, :title, :allday?)
  end

  class API
    def self.authorize
      client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
      token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
      authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
      user_id = "default"
      credentials = authorizer.get_credentials user_id
      if credentials.nil?
        url = authorizer.get_authorization_url base_url: OOB_URI
        puts "Open the following URL in the browser and enter the " \
             "resulting code after authorization:\n" + url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI
        )
      end
      credentials
    end

    def initialize
      @service = Google::Apis::CalendarV3::CalendarService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = API.authorize
    end

    def fetch_calendars
      response = @service.list_calendar_lists
      response.items.select { |calendar| calendar.selected }
    end

    def fetch_events(n)
      items = []
      fetch_calendars.each do |calendar|
        items += @service.list_events(calendar.id,
                                        max_results: n,
                                        single_events: true,
                                        order_by: "startTime",
                                        time_min: DateTime.now.rfc3339
                                     ).items
      end
      events = {}
      items.each do |item|
        # if the item is all-day, add item as an all-day event for every day in the event's duration.
        if item.start.date_time.nil?
          (item.start.date...item.end.date).each do |date|
            events[date] ||= []
            events[date] << Event.new(item.start.date, item.summary, true)
          end
        else
          date = item.start.date_time.to_date
          events[date] ||= []
          events[date] << Event.new(item.start.date_time, item.summary, false)
        end
      end
      events
    end

    def fetch_holidays(n_days)
      items = @service.list_events("en.singapore#holiday@group.v.calendar.google.com",
                           max_results: n_days,
                           single_events: true,
                           order_by: "startTime",
                           #time_min: DateTime.now.to_date.rfc3339).items
                           time_min: "2021-04-02T00:00:00+08:00").items
      events = {}
      items.each do |item|
        date = (item.start.date_time || item.start.date).to_date
        events[date] ||= []
        events[date] << Event.new(item.start.date_time || item.start.date, item.summary, item.start.date_time.nil?)
      end
      events
    end
  end
end
