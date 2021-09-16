# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week4
    def run(week, league_id)
      puts "run 2020week4 for week #{week} league #{league_id}"

      by_team = {}

      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)
        puts("************** #{team_name} **************")

        weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_defense_stats(4, team_index)

        # Grab the starter, as a team might also have a defense on their bench.
        starting_def = weekly_data.select { |player| player[:roster_position] == 'DEF' }.first

        defense_name = starting_def[:player_name]
        ints = starting_def[:interceptions]
        fumbles = starting_def[:fumbles]
        turnovers = ints + fumbles

        puts "DEF: #{defense_name}"
        puts "Points: #{starting_def[:points]}"
        puts "Interceptions: #{ints}"
        puts "Fumbles recovered: #{fumbles}"
        puts "Total turnovers: #{turnovers}"
        puts "\n"
        by_team[team_name] = {
          defense_name: defense_name,
          ints: ints,
          fumbles: fumbles,
          turnovers: turnovers
        }
      end

      puts('************** RESULTS **************')
      by_team.sort_by { |_, data| -data[:turnovers] }.each_with_index do |(team, data), index|
        print("In #{(index + 1).ordinalize} place: #{team} - #{data[:defense_name]} - ")
        puts("#{data[:turnovers]} turnovers (#{data[:ints]} Int, #{data[:fumbles]} Fum Rec)")
      end
    end
  end
end
