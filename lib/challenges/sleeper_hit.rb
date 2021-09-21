# frozen_string_literal: true

module Challenges
  # Most points from a single player who was acquired for $5 or less
  class SleeperHit
    def run(week, league_id)
      puts 'Sleeper Hit: Most points from a single player who was acquired for $5 or less (excluding keepers, K, and DEF).'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams
      player_history = YahooDataFetcher::PlayerHistory.new(yahoo_client, week)

      team_results = []
      all_players = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'

          player_key = player['player_key']
          points = player['player_points']['total'].to_f

          player_salary = player_history.salary(player_key)
          keeper = player_history.keeper?(player_key)
          eligible = player_salary <= 5 && position != 'K' && position != 'DEF' && !keeper

          player_data = {
            name: player['name']['full'],
            pos: position,
            pts: points,
            eligible: eligible,
            acquisition: player_history.salary_human_readable(player_key)
          }

          team_players << player_data
          all_players << player_data.merge({ team: team_name }) if eligible
        end

        best_player = team_players.select { |p| p[:eligible] }.min { |p| -p[:pts] }

        team_results << if best_player.nil?
                          {
                            team_name: team_name,
                            challenge_rating: 0,
                            player_name: 'No eligible players'
                          }
                        else
                          {
                            team_name: team_name,
                            challenge_rating: best_player[:pts],
                            player_name: best_player[:name]
                          }
                        end

        puts team_name
        puts 'Starting players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :pos,
           :eligible,
           ColumnFormatter.decimal(:pts, 2),
           { acquisition: { width: 32 } })

        if best_player
          puts "Best sleeper: #{best_player[:name]} with #{best_player[:pts]} points"
        else
          puts 'No eligible players.'
        end
        puts ''
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :challenge_rating, :player_name)
      puts ''

      puts('************** All players **************')
      all_players = all_players.sort_by { |data| -data[:pts] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end
      tp(all_players,
         :rank,
         { name: { fixed_width: 22 } },
         :pos,
         ColumnFormatter.decimal(:pts, 2),
         { acquisition: { fixed_width: 20 } },
         { team: { fixed_width: 32 } })
    end
  end
end
