# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week12
    def run(week, league_id)
      puts "run 2020week12 for week #{week} league #{league_id}"

      week = 12
      team_results = []

      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)
        puts("************** #{team_name} **************")

        max_points = 0
        best_player_name = ''
        best_player_pos = ''
        rows = []

        weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_full_roster_stats(week, team_index)
        weekly_data.each do |player|
          next if player[:roster_position] == 'BN'

          if player[:points] > max_points
            best_player_pos = player[:player_position]
            max_points = player[:points]
            best_player_name = player[:player_name]
          end

          rows << {
            player_name: player[:player_name],
            pos: player[:player_position],
            points: player[:points]
          }
        end

        tp(rows, { player_name: { fixed_width: 22 } }, :pos, :points)
        puts("\n")

        team_results << {
          team_name: team_name,
          points: max_points,
          mvp: best_player_name,
          pos: best_player_pos
        }
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:points] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :mvp, :pos, :points)
    end
  end
end
