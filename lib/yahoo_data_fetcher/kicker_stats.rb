module YahooDataFetcher
  class KickerStats
    attr_reader :data

    def initialize(player_id)
      @data = fetch_stats(player_id)
    end

    def fetch_stats(player_id)
      url = "https://sports.yahoo.com/nfl/players/#{player_id}/gamelog"
      doc = Nokogiri::HTML(URI.open(url).read)
      rows = doc.css('div.ys-graph-stats').css('table').css('tr')[2..]

      rows.map do |row|
        {
          # First column should be date, but it is missing when scraped
          opponent: row.children[1].text,
          game_score: row.children[2].text,
          fg_attempted: row.children[4].text.to_i,
          fg_made: row.children[5].text.to_i,
          long: row.children[7].text.to_i
        }
      end
    end

    # Until date issue is fixed, can't query by week; just grab most recent game
    def most_recent
      @data.first
    end
  end
end