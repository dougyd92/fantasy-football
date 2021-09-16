# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week14
    def run(week, league_id)
      puts "run 2020week14 for week #{week} league #{league_id}"

      week = 14
      team_results = []

      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)
        puts("************** #{team_name} **************")

        game_result = YahooDataFetcher::GameResults.fetch_game_results(week, team_index)

        starter_pts = game_result[:team_1_pts].round(2)
        bench_pts = game_result[:team_1_bench_pts].round(2)
        total_pts = starter_pts + bench_pts

        puts "Starters: #{starter_pts}"
        puts "Bench:    #{bench_pts}"
        puts "Total:    #{total_pts}"
        puts "\n"

        team_results << {
          team_name: team_name,
          starter_pts: starter_pts,
          bench_pts: bench_pts,
          total_pts: total_pts
        }
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:total_pts] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :total_pts, :starter_pts, :bench_pts)
    end
  end
end
