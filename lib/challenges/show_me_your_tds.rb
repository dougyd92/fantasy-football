# frozen_string_literal: true

module Challenges
  # Most total touchdowns scored on a team.
  class ShowMeYourTDs
    def run(week, league_id)
      puts 'Show Me Your TDs: Most total touchdowns scored on a team.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []
      all_players = []

      teams.each do |team|
        team_players = []
        team_name = team['name']
        team_total_tds = 0

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'

          stats = YahooDataFetcher::Stats.new(player)
          passing_tds = stats.get(:PassTD)
          rushing_tds = stats.get(:RushTD)
          receiving_tds = stats.get(:RecTD)
          kick_return_tds = stats.get(:RetTD) + stats.get(:DST_RetTD)
          fumble_ret_tds = stats.get(:OffFumRetTD) + stats.get(:DST_TD)

          player_total_tds = passing_tds + rushing_tds + receiving_tds + kick_return_tds + fumble_ret_tds
          team_total_tds += player_total_tds

          player_data = {
            name: player['name']['full'],
            pass: passing_tds,
            rush: rushing_tds,
            rec: receiving_tds,
            kick_ret: kick_return_tds,
            fumble_ret: fumble_ret_tds,
            total: player_total_tds
          }

          team_players << player_data
          all_players << player_data.merge({ team: team_name })
        end

        team_results << {
          team_name: team_name,
          challenge_rating: team_total_tds
        }

        puts team_name
        puts 'Starting players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :pass,
           :rush,
           :rec,
           :kick_ret,
           :fumble_ret,
           :total)

        puts "Total TDs: #{team_total_tds}"
        puts ''
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :challenge_rating)
      puts ''

      puts('************** All players **************')
      all_players = all_players.select{ |data| data[:total] > 0 }.sort_by { |data| -data[:total] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end
      tp(all_players,
         :rank,
         { name: { fixed_width: 22 } },
         :pass,
         :rush,
         :rec,
         :kick_ret,
         :fumble_ret,
         :total,
         { team: { fixed_width: 32 } })
    end
  end
end
