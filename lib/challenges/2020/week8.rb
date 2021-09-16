# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week8
    def run(week, league_id)
      puts "run 2020week8 for week #{week} league #{league_id}"

      week = 8
      qbr_lookup = EspnDataFetcher::QBR.new(week)
      by_team = {}
      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)

        weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_offense_stats(week, team_index)

        starting_qb = weekly_data.select { |player| player[:roster_position] == 'QB' }.first[:player_name]

        by_team[team_name] = {
          player_name: starting_qb,
          qbr: qbr_lookup.qbr_for_player(starting_qb)
        }
      end

      puts('************** RESULTS **************')
      by_team.sort_by { |_, data| -data[:qbr] }.each_with_index do |(team, data), index|
        print("In #{(index + 1).ordinalize} place: #{team} - #{data[:player_name]} - ")
        puts("Total QBR: #{data[:qbr]}")
      end
    end
  end
end
