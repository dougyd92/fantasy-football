# frozen_string_literal: true

module Challenges
  # K with the longest field goal
  class DasBoot
    def run(week, league_id)
      puts 'Das Boot: Kicker with the longest field goal'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        longest_fg = 0
        kicker_name = ''

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next unless position == 'K'

          kicker_name = player['name']['full']
          # TODO kicker stats only work for most recent week, so running this challenge retroactively won't work.
          stats = YahooDataFetcher::KickerStats.new(player["player_id"]).most_recent
          longest_fg = stats[:long]

          break
        end
        
        puts team_name
        puts "Kicker: #{kicker_name}"
        puts "Longest FG made: #{longest_fg} yds"
        puts ''

        team_results << {
          team_name: team_name,
          kicker: kicker_name,
          long: longest_fg,
        }
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:long] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, 
        :rank, 
        :team_name, 
        :kicker,
        :long)
      puts ''
    end
  end
end
