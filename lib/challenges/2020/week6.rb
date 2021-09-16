# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week6
    def run(week, league_id)
      puts "run 2020week6 for week #{week} league #{league_id}"
      week = 6
      by_team = {}

      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)

        weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_offense_stats(week, team_index)

        starting_te = weekly_data.select { |player| player[:roster_position] == 'TE' }.first

        by_team[team_name] = {
          player_name: starting_te[:player_name],
          points: starting_te[:points]
        }
      end

      puts('************** RESULTS **************')
      by_team.sort_by { |_, data| -data[:points] }.each_with_index do |(team, data), index|
        print("In #{(index + 1).ordinalize} place: #{team} - #{data[:player_name]} - ")
        puts("#{data[:points]} pts")
      end
    end
  end
end
