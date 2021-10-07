# frozen_string_literal: true

module Challenges
  # Highest yards-per-carry combined across RBs
  class RunningMaxEfficiency
    def run(week, league_id)
      puts 'Running at Maximum Efficiency: Highest yards-per-carry combined across RBs'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []
      all_players = []

      teams.each do |team|
        team_players = []
        team_name = team['name']
        total_carries = 0
        total_rushing_yards = 0

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next unless position == 'RB'

          stats = YahooDataFetcher::Stats.new(player)
          carries = stats.get(:RushAtt)
          rushing_yards = stats.get(:RushYds)
          yards_per_carry = rushing_yards/carries

          total_carries += carries
          total_rushing_yards += rushing_yards

          player_data = {
            name: player['name']['full'],
            carries: carries,
            rushing_yards: rushing_yards,
            ypc: yards_per_carry
          }

          team_players << player_data
          all_players << player_data.merge({ team: team_name })
        end

        challenge_rating = total_rushing_yards / total_carries

        team_results << {
          team_name: team_name,
          challenge_rating: challenge_rating,
        }

        puts team_name
        puts 'Starting RBs:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :carries,
           :rushing_yards,
           ColumnFormatter.decimal(:ypc, 2))

        puts "Total carries: #{total_carries}"
        puts "Total rushing yards: #{total_rushing_yards}"
        puts "Combined RB efficiency: #{format('%.3f', challenge_rating)} YPC"
        puts ''
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, ColumnFormatter.decimal(:challenge_rating, 3))
      puts ''

      puts('************** All players **************')
      all_players = all_players.sort_by { |data| -data[:ypc] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end
      tp(all_players,
         :rank,
         { name: { fixed_width: 22 } },
         :carries,
         :rushing_yards,
         ColumnFormatter.decimal(:ypc, 3),
         { team: { fixed_width: 32 } })
    end
  end
end
