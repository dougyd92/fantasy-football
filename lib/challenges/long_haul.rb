# frozen_string_literal: true

module Challenges
  # Most total points from starters owned continuously since draft day.
  class LongHaul
    def run(week, league_id)
      puts 'The Long Haul: Most total points from starters owned continuously since draft day.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams
      player_history = YahooDataFetcher::PlayerHistory.new(yahoo_client, week)

      team_results = []

      teams.each do |team|
        long_haul_pts = 0
        player_count = 0
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'

          player_key = player['player_key']

          next unless player_history.acquistion(player_key) == 'drafted'

          points = player['player_points']['total'].to_f
          long_haul_pts += points
          player_count += 1

          player_data = {
            name: player['name']['full'],
            pts: points,
          }

          team_players << player_data
        end

        team_results << {
          team_name: team_name,
          players: player_count,
          challenge_rating: long_haul_pts.round(2)
        }

        puts team_name
        puts 'Starting players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           ColumnFormatter.decimal(:pts, 2))

        puts "Total points by starters owned since draft: #{long_haul_pts.round(2)}"
        puts ''
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :players, :challenge_rating)
    end
  end
end