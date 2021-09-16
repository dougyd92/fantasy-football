# frozen_string_literal: true

module YahooDataFetcher
  class GameResults
    def self.fetch_game_data(week, team_index, league_id)
      player_data = []

      game_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/#{league_id}/matchup?week=#{week}&mid1=#{team_index}"))
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

    def self.fetch_game_results(week, team_index, league_id)
      game_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/#{league_id}/matchup?week=#{week}&mid1=#{team_index}"))
      result_row = game_doc.css('div#matchups tbody').children[10]
      bench_result_row = game_doc.css('div#bench-table tbody').children.last
      managers_header = game_doc.css('div.Grid-h-top.Relative')

      {
        team_1_name: managers_header.children[0].css('div.Fz-xxl').first.text,
        team_1_projected_pts: result_row.children[2].text.to_f,
        team_1_pts: result_row.children[3].text.to_f,
        team_1_bench_pts: bench_result_row.children[3].text.to_f,
        team_2_name: managers_header.children[3].css('div.Fz-xxl').first&.text,
        team_2_projected_pts: result_row.children[8]&.text.to_f,
        team_2_pts: result_row.children[7]&.text.to_f,
        team_2_bench_pts: bench_result_row.children[7]&.text.to_f
      }
    end
  end
end
