# frozen_string_literal: true

module Challenges
  # Highest total, after removing the highest and lowest scorers.
  class Stats101
    def run(week, league_id)
      puts 'Stats 101: Highest total, after removing the highest and lowest scorers.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        highest_score = -Float::INFINITY
        highest_scoring_player = ''
        lowest_score = Float::INFINITY
        lowest_scoring_player = ''

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'

          player_name = player['name']['full']
          points = player['player_points']['total'].to_f

          if points > highest_score
            highest_score = points
            highest_scoring_player = player_name
          end

          if points < lowest_score
            lowest_score = points
            lowest_scoring_player = player_name
          end

          player_data = {
            name: player_name,
            pos: position,
            pts: points,
          }

          team_players << player_data
        end

        total_score = yahoo_client.fetch_team_score(team['team_key'], week)
        adjusted_score = (total_score - highest_score - lowest_score).round(2)
        orig_ppp = (total_score/10).round(2)
        adj_ppp = (adjusted_score/10).round(2)
        diff_ppp = (adj_ppp - orig_ppp).round(2)

        puts team_name
        puts 'Starting players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :pos,
           :pts
        )

        puts "Highest score: #{highest_score} by #{highest_scoring_player}"
        puts "Lowest score: #{lowest_score} by #{lowest_scoring_player}"
        puts "Original team score: #{total_score} (#{orig_ppp} points per player)"
        puts "Adjusted team score: #{adjusted_score} (#{adj_ppp} points per player)"
        puts "Difference: #{(adjusted_score - total_score).round(2)} (#{diff_ppp} points per player)"
        puts ''

        team_results << {
          team_name: team_name,
          adjusted_score: adjusted_score,
          orig_score: total_score,
          high: highest_score,
          low: lowest_score,
          adj_ppp: adj_ppp,
          orig_ppp: orig_ppp,
          diff_ppp: diff_ppp
        }
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:adjusted_score] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, 
        :rank, 
        :team_name, 
        :adjusted_score, 
        :orig_score, 
        :high, 
        :low, 
        :adj_ppp, 
        :orig_ppp,
        :diff_ppp)
      puts ''
    end
  end
end
