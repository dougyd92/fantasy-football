# frozen_string_literal: true

module YahooDataFetcher
  class GameResults
    def self.fetch_game_data(week, team_index)
      player_data = []

      game_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/810182/matchup?week=#{week}&mid1=#{team_index}"))
      rows = game_doc.css('div#matchups tbody').children
      rows[0, 10].each do |row|
        player_data.append(
          {
            stats: row.children[0].text,
            player_name: row.children[1].css('div.ysf-player-name').children.first.text,
            player_id: row.children[1].css('div.ysf-player-name').children.first['href'].split('/').last,
            projected_pts: row.children[2].text,
            points: row.children[3].text,
            position: row.children[4].text
          }
        )
      end

      player_data
    end
  end
end
