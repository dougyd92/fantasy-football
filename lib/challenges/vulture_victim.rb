# frozen_string_literal: true

module Challenges
  # Most points from a single player who had 0 TDs (excludes K and DEF)
  class VultureVictim
    def run(week, league_id)
      puts 'Vulture Victim: Most points from a single player who had 0 TDs (excludes K and DEF).'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []
      all_players = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if ['BN', 'DEF', 'K'].include?(position)

          points = player['player_points']['total'].to_f

          stats = YahooDataFetcher::Stats.new(player)
          passing_tds = stats.get(:PassTD)
          rushing_tds = stats.get(:RushTD)
          receiving_tds = stats.get(:RecTD)
          other_tds = stats.get(:RetTD) + stats.get(:DST_RetTD) + stats.get(:OffFumRetTD) + stats.get(:DST_TD)

          player_total_tds = passing_tds + rushing_tds + receiving_tds + other_tds
          eligible = player_total_tds.zero?

          player_data = {
            name: player['name']['full'],
            pass: passing_tds,
            rush: rushing_tds,
            rec: receiving_tds,
            other: other_tds,
            pts: points,
            eligible: eligible
          }

          team_players << player_data
          all_players << player_data.merge({ team: team_name }) if eligible
        end

        best_player = team_players.select { |p| p[:eligible] }.max_by { |p| p[:pts] }

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
           :pass,
           :rush,
           :rec,
           :other,
           :pts,
           :eligible)

        if best_player
          puts "Best vulture victim: #{best_player[:name]} with #{best_player[:pts]} points"
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
         :pass,
         :rush,
         :rec,
         :other,
         :pts,
         { team: { fixed_width: 32 } })
    end
  end
end
