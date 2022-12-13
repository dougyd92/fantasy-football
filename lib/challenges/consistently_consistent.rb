# frozen_string_literal: true

module Challenges
  # Closest to season average points per game 
  class ConsistentlyConsistent
    def run(week, league_id)
      puts 'Consistently Consistent: Closest to season average points per game.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []
      season_results = []

      teams.each do |team|
        team_name = team['name']

        scores = []
        (1..(week-1)).each do |szn_week|
          total_score = yahoo_client.fetch_team_score(team['team_key'], szn_week)
          scores << total_score
        end
        
        avg = scores.sum / scores.size
        this_week_score = yahoo_client.fetch_team_score(team['team_key'], week)
        difference = (this_week_score - avg).round(2)

        puts team_name
        puts("\nWeeks 1 to #{week-1}: #{avg.round(2)} points")
        puts("This week: #{this_week_score} points")
        puts "Difference: #{difference}"
        puts ''
        puts ''

        team_results << {
          team_name: team_name,
          pts: this_week_score, 
          avg_pts: avg.round(2),
          difference: difference
        }
        
        # Get some season-long stats for fun
        scores << this_week_score
        stats = DescriptiveStatistics::Stats.new(scores)
        season_results << {
          team_name: team_name,
          total: stats.sum.round(2),
          avg: stats.mean.round(2),
          median: stats.median.round(2),
          max: stats.max,
          min: stats.min,
          range: stats.range.round(2),
          std_dev: stats.standard_deviation.round(2)
        }        
      end

      puts ''
      puts('************** CHALLENGE RESULTS **************')
      team_results = team_results.sort_by { |data| data[:difference].abs }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :pts, :avg_pts, :difference)
      puts ''
      puts ''

      puts('********** Season Long stats (inc. week 14) **********')
      season_results = season_results.sort_by { |data| -data[:total] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end
      tp(season_results, :rank, :team_name, :total, :avg, :median, :max, :min, :range, :std_dev)
    end
  end
end
