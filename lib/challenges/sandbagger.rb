# frozen_string_literal: true

module Challenges
  # Highest (positive) difference between points scored and regular season average.'
  class Sandbagger
    def run(week, league_id)
      puts 'Sandbagger: Highest (positive) difference between points scored and regular season average.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_name = team['name']

        scores = []
        (1..14).each do |szn_week|
          total_score = yahoo_client.fetch_team_score(team['team_key'], szn_week)
          scores << total_score
        end
        stats = DescriptiveStatistics::Stats.new(scores)
        this_week_score = yahoo_client.fetch_team_score(team['team_key'], week)
        
        difference = (this_week_score - stats.mean).round(2)

        puts team_name
        puts("\nRegular season: ")
        tp([{
             avg: stats.mean.round(2),
             median: stats.median,
             min: stats.min,
             max: stats.max,
             range: stats.range.round(2),
             std_dev: stats.standard_deviation.round(2)
           }])
        puts("\nThis week: #{this_week_score} points")
        puts "Difference: #{difference}"
        puts ''
        puts ''

        team_results << {
          team_name: team_name,
          pts: this_week_score, 
          avg_pts: stats.mean.round(2),
          challenge_rating: difference,
        }        
      end

      puts ''
      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :pts, :avg_pts, :challenge_rating)
      puts ''
    end
  end
end
