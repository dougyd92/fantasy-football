# frozen_string_literal: true

module Challenges
  # DEF with the least points allowed
  class Shutout
    def run(week, league_id)
      puts 'Shutout: DEF with the least points allowed'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        pts_allowed = 0
        def_name = ''

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next unless position == 'DEF'

          def_name = player['name']['full']
          stats = YahooDataFetcher::Stats.new(player)
          pts_allowed = stats.get(:PtsAllow)
          break
        end
        
        puts team_name
        puts "DEF: #{def_name}"
        puts "Points Allowed: #{pts_allowed}"
        puts ''

        team_results << {
          team_name: team_name,
          def: def_name,
          pts: pts_allowed,
        }
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| data[:pts] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, 
        :rank, 
        :team_name, 
        :def,
        :pts)
      puts ''
    end
  end
end
