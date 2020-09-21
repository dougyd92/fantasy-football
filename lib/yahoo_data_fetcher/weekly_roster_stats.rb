# frozen_string_literal: true

module YahooDataFetcher
  class WeeklyRosterStats
    def self.fetch_stats(week, team_index)
      player_data = []

      roster_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/810182/#{team_index}/team?&week=#{week}"))
      rows = roster_doc.css('table#statTable0 tbody').children
      rows.each do |row|
        player_data.append(
          {
            position: row.children[0].text,
            player_name: row.children[1].css('div.ysf-player-name').children.first.text,
            player_id: row.children[1].css('div.ysf-player-name').children.first['href'].split('/').last,
            points: row.children[6].text.to_f,
            projected_pts: row.children[7].text.to_f,
            passing_yds: row.children[9].text.to_i,
            passing_tds: row.children[10].text.to_i,
            interceptions: row.children[11].text.to_i,
            rushing_attempts: row.children[12].text.to_i,
            rushing_yds: row.children[13].text.to_i,
            rushing_tds: row.children[14].text.to_i,
            receiving_targets: row.children[15].text.to_i,
            receiving_receptions: row.children[16].text.to_i,
            receiving_yds: row.children[17].text.to_i,
            receiving_tds: row.children[18].text.to_i
          }
        )
      end

      player_data
    end
  end
end
