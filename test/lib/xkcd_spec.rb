require 'xkcd'
require 'date'

describe XKCD do
  describe '.latest' do
    before do
      allow(Net::HTTP).to receive(:get)
        .with(URI("#{XKCD::HOSTNAME}/#{XKCD::INFO_ENDPOINT}"))
        .and_return %q({"month": "5", "num": 2000, "link": "", "year": "2018", "news": "", "safe_title": "xkcd Phone 2000", "transcript": "", "alt": "Our retina display features hundreds of pixels per inch in the central fovea region.", "img": "https://imgs.xkcd.com/comics/xkcd_phone_2000.png", "title": "xkcd Phone 2000", "day": "30"})
    end

    it 'fetches the latest comic' do
      latest = XKCD.latest
      expect(latest.title).to eq("xkcd Phone 2000")
    end

    it 'parses the date correctly' do
      latest = XKCD.latest
      expect(latest.date).to eq(DateTime.new(2018, 5, 30))
    end
  end

  describe XKCD::XKCDComic do
    it 'puts the page url together correctly' do
      comic = XKCD::XKCDComic.new(1, 'alt', 'title', 'transcript', 1024, DateTime.now)
      expect(comic.page_url).to eq('https://xkcd.com/1024')
    end
  end
end
