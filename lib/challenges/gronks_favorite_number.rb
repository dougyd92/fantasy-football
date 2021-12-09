# frozen_string_literal: true

module Challenges
  # TE with closest to 69 all-purpose yards
  class GronksFavoriteNumber
    def run(week, league_id)
      puts "Gronk's Favorite Number: TE with closest to 69 all-purpose yards"
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        total_yds = 0
        player_name = ''

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next unless position == 'TE'

          player_name = player['name']['full']
          stats = YahooDataFetcher::Stats.new(player)
          total_yds = stats.get(:RushYds) + stats.get(:RecYds)
          break
        end
        
        gronk_number = (69 - total_yds).abs()

        puts team_name
        puts "TE: #{player_name}"
        puts "Total yards: #{total_yds}"
        puts "Sixty-nine: 69"
        puts "Absolute difference: #{gronk_number}"
        puts ''

        team_results << {
          team_name: team_name,
          te: player_name,
          yds: total_yds,
          "69": 69,
          diff: gronk_number
        }
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| data[:diff] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, 
        :rank, 
        :team_name, 
        :te,
        :yds,
        "69",
        :diff
      )
      puts ''
    end
  end
end
