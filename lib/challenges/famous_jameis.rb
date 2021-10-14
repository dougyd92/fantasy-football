# frozen_string_literal: true

module Challenges
  # Most TD passes + INTs by a QB.
  class FamousJameis
    def run(week, league_id)
      puts '30 for 30 (Famous Jameis): Most TD passes + INTs by a QB.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []
      all_players = []
      
      teams.each do |team|
        challenge_rating = 0
        team_players = []
        team_name = team['name']

        puts team_name
        
        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next unless position == 'QB'

          weekly_stats = YahooDataFetcher::Stats.new(player)
          passing_tds = weekly_stats.get(:PassTD)
          interceptions = weekly_stats.get(:QbInt)
          total = passing_tds + interceptions

          season_stats = YahooDataFetcher::Stats.new(yahoo_client.fetch_player_season_long_stats(player["player_key"]))
          season_passing_tds = season_stats.get(:PassTD)
          season_interceptions = season_stats.get(:QbInt)

          player_data = {
            name: player['name']['full'],
            tds: passing_tds,
            ints: interceptions,
            total: total
          }

          challenge_rating = total 
          team_players << player_data
          all_players << player_data.merge({ team: team_name })

          puts "Starting QB: #{player['name']['full']}"
          puts "Passing TDs: #{passing_tds}"
          puts "INTs: #{interceptions}"
          puts "Total: #{total}"
          
          puts "Extrapolating from this week, they are on track to throw for #{passing_tds*17} TDs and #{interceptions*17} INTs this season"
        
          # This assumes the challenge is being run in week 5
          # TODO: adjust for the actual number of weeks elapsed
          puts "Extrapolating from all games so far, they are on track to throw for #{season_passing_tds*17/5.0} TDs and #{season_interceptions*17/5.0} INTs this season"
          puts ''
        end

        team_results << {
          team_name: team_name,
          challenge_rating: challenge_rating
        }
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
         :tds,
         :ints,
         :total,
         { team: { fixed_width: 32 } })
    end
  end
end
