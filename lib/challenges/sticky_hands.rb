# frozen_string_literal: true

module Challenges
  # Highest catch percentage combined across WRs
  class StickyHands
    def run(week, league_id)
      puts 'Sticky Hands: Highest catch percentage combined across WRs'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []
      all_players = []

      teams.each do |team|
        team_players = []
        team_name = team['name']
        total_targets = 0
        total_receptions = 0

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next unless position == 'WR'

          stats = YahooDataFetcher::Stats.new(player)
          targets = stats.get(:Targets)
          receptions = stats.get(:Rec)
          catch_pct = receptions/targets

          total_targets += targets
          total_receptions += receptions

          player_data = {
            name: player['name']['full'],
            targets: targets,
            receptions: receptions,
            catch_pct: catch_pct
          }

          team_players << player_data
          all_players << player_data.merge({ team: team_name })
        end

        challenge_rating = total_receptions / total_targets

        team_results << {
          team_name: team_name,
          challenge_rating: challenge_rating,
        }

        puts team_name
        puts 'Starting WRs:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :targets,
           :receptions,
           ColumnFormatter.decimal(:catch_pct, 2))

        puts "Total targets: #{total_targets}"
        puts "Total receptions: #{total_receptions}"
        puts "Combined WR catch percentage: #{format('%.2f', challenge_rating*100)}%"
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
      all_players = all_players
        .sort_by { |data| data[:catch_pct].nan? ? Float::INFINITY : -data[:catch_pct] }
        .each.with_index do |data, i|
          data[:rank] = i + 1
          data
      end
      
      tp(all_players,
         :rank,
         { name: { fixed_width: 22 } },
         :targets,
         :receptions,
         ColumnFormatter.decimal(:catch_pct, 3),
         { team: { fixed_width: 32 } })
    end
  end
end
