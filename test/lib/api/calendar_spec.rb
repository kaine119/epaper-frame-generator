require 'generator/api/calendar'
require 'rspec'

describe Calendar::API do
  # Singapore holidays.
  let(:calendar) {
    Calendar::API.new([
      "https://calendar.google.com/calendar/ical/muikaien1%40gmail.com/private-d0b415e93ed736127f8244aeed2388c3/basic.ics",
      "https://calendar.google.com/calendar/ical/et545b8tt8rtjfispkb9eg6b9g%40group.calendar.google.com/private-0d5f75d2c5ba5bb903a54008f942ae28/basic.ics"
    ])
  }

  it 'returns a list of events' do
    events = calendar.fetch_events(5)
    pp events
    expect(events.count).to eq(5)
  end
end