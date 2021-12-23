# frozen_string_literal: true

module Challenges
  # Most points scored by two players on the same NFL team.
  class SmarterThanYahoo
    def run(week, league_id)
      puts 'Are You Smarter Than Yahoo?: Largest (positive) difference between actual and projected points scored.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_name = team['name']

        actual_points = yahoo_client.fetch_team_score(team['team_key'], week)
        proj_points = yahoo_client.fetch_team_projection(team['team_key'], week)
        difference = (actual_points - proj_points).round(2)

        puts team_name
        puts "Projected points: #{proj_points}"
        puts "Actual points: #{actual_points}"
        puts "Difference: #{difference}"
        puts ''

        team_results << {
          team_name: team_name,
          challenge_rating: difference,
        }        
      end

      puts ''
      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :challenge_rating)
      puts ''
    end
  end
end
