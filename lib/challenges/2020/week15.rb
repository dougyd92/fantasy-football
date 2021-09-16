# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week15
    def run(week, league_id)
      puts "run 2020week15 for week #{week} league #{league_id}"

      challenge_week = 15
      team_results = []

      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)
        puts("************** #{team_name} **************")

        scores = []

        (1..13).each do |week|
          game_result = YahooDataFetcher::GameResults.fetch_game_results(week, team_index)
          scores << game_result[:team_1_pts]
        end

        stats = DescriptiveStatistics::Stats.new(scores)
        tp([{
             avg: stats.mean.round(2),
             median: stats.median,
             min: stats.min,
             max: stats.max,
             range: stats.range,
             std_dev: stats.standard_deviation.round(2)
           }])

        challenge_week_result = YahooDataFetcher::GameResults.fetch_game_results(challenge_week, team_index)
        challenge_week_pts = challenge_week_result[:team_1_pts]

        puts("\nWeek 15: #{challenge_week_pts} points \n\n")

        team_results << {
          team_name: team_name,
          avg_pts: stats.mean.round(2),
          week_15_pts: challenge_week_pts,
          difference: (challenge_week_pts - stats.mean).round(2)
        }

        sleep(10) # Try not to exceed rate limit
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:difference] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :week_15_pts, :avg_pts, :difference)
    end
  end
end
