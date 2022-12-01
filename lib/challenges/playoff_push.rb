# frozen_string_literal: true

module Challenges
  class PlayoffPush
    def run(week, league_id)
      puts 'Playoff Push: Total points by starters on NFL teams that are in a playoff spot.'
      puts ''

      # ToDo: would be nice to do this programmatically
      playoff_teams = [
        'KC',
        'Mia',
        'Ten',
        'Bal',
        'Buf',
        'Cin',
        'NYJ',

        'Phi',
        'Min',
        'SF',
        'TB',
        'Dal',
        'NYG',
        'Was',
      ]

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams
      player_history = YahooDataFetcher::PlayerHistory.new(yahoo_client, week)

      team_results = []
      
      teams.each do |team|
        total_points = 0
        player_count = 0
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'

          nfl_team = player['editorial_team_abbr']
          playoff_bound = playoff_teams.include?(nfl_team)

          points = player['player_points']['total'].to_f
          
          if playoff_bound
            total_points += points
            player_count += 1
          end

          player_data = {
            name: player['name']['full'],
            pos: position,
            pts: points,
            team: nfl_team,
            playoff_bound: playoff_bound
          }

          team_players << player_data
        end

        team_results << {
          team_name: team_name,
          challenge_rating: total_points,
          playoff_players: player_count
        }

        puts team_name
        puts 'Starting players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :pos,
           ColumnFormatter.decimal(:pts, 2),
           :team,
           :playoff_bound
        )

        puts "Total points by playoff-bound players: #{total_points.round(2)}"
        puts ''
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, ColumnFormatter.decimal(:challenge_rating, 2), :playoff_players)
      puts ''

    end
  end
end
