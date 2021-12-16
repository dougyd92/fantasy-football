# frozen_string_literal: true

module Challenges
  # Most points scored by two players on the same NFL team.
  class DynamicDuo
    def run(week, league_id)
      puts 'Dynamic Duo: Most points scored by two players on the same NFL team.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_name = team['name']
        nfl_teams = {}
        best_duo_points = 0
        best_duo_player_1 = ''
        best_duo_player_2 = ''
        best_duo_team = ''
        best_duo_positions = ''

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'
          
          nfl_team = player['editorial_team_abbr']
          nfl_teams[nfl_team] = [] if nfl_teams[nfl_team].nil?
          
          nfl_teams[nfl_team] << {
            'player' => player['name']['full'],
            'points' => player['player_points']['total'].to_f.round(2),
            'pos' => player['display_position']
          }
        end

        puts team_name

        nfl_teams.each do |team, players|
          puts "#{team}: "
          players = players.sort_by { |p| -p['points'] }
          players.each do |player|
            puts "  #{player['player'].ljust(21)} #{player['points']}"
          end
          if players.length > 1
            duo_points = (players[0]['points'] + players[1]['points']).round(2)
            if duo_points > best_duo_points
              best_duo_points = duo_points
              best_duo_player_1 = players[0]['player']
              best_duo_player_2 = players[1]['player']
              best_duo_team = team
              best_duo_positions = "#{players[0]['pos']}, #{players[1]['pos']}"
            end
          end
        end

        if best_duo_player_1.empty?
          puts 'No duos on the whole roster!'
        else
          puts "Best dynamic duo:"
          puts "#{best_duo_player_1} + #{best_duo_player_2} (#{best_duo_team}) for #{best_duo_points} points"
          puts ''
        end

        team_results << {
          team_name: team_name,
          challenge_rating: best_duo_points,
          team: best_duo_team,
          positions: best_duo_positions
        }
      end

      puts ''
      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :challenge_rating, :team, :positions)
      puts ''
    end
  end
end
