# frozen_string_literal: true

module Challenges
  # Least difference between optimal and actual lineup.
  class SmartStart
    def run(week, league_id)
      puts 'Smart Start: Least difference between optimal and actual lineup.'
      puts ''

      # yahoo_client = YahooDataFetcher::Client.new(597209)
      yahoo_client = YahooDataFetcher::Client.new(league_id)
      load_league_settings(yahoo_client)
      
      team_results = []
      teams = yahoo_client.fetch_teams
      teams.each do |team|
        # team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        actual_points = yahoo_client.fetch_team_score(team['team_key'], week)
        actual_lineup = roster
          .reject { |player| player['selected_position']['position'] == 'BN' }
          .map{ |player| [player["name"]["full"], player['player_points']['total'].to_f] }

        ideal_points, ideal_lineup = ideal_lineup_wrapper(roster)

        shoulda_started = ideal_lineup - actual_lineup
        shouldnta_started = actual_lineup - ideal_lineup

        point_difference = (ideal_points - actual_points).round(3)

        team_results << {
          team_name: team_name,
          challenge_rating: point_difference
        }

        puts team_name
        puts "Points scored (actual): #{actual_points.round(2)}"
        puts "Points scored (ideal lineup): #{ideal_points.round(2)}"
        puts "Difference: #{point_difference.round(2)}"

        if shoulda_started.count > 0
          puts "You should have started #{shoulda_started.map{ |player| "#{player[0]} (#{player[1]} pts)" }.join(', ')}"
          puts "instead of #{shouldnta_started.map{ |player| "#{player[0]} (#{player[1]} pts)" }.join(', ')}"
        else
          puts "Perfect lineup!"
        end
        puts ''
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| data[:challenge_rating] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :challenge_rating)
      puts ''
    end

    def load_league_settings(yahoo_client)
      settings = yahoo_client.fetch_settings
      position_counts = settings['roster_positions']['roster_position'].map do |position| [position['position'], position['count']] end.to_h
      @num_qb = position_counts['QB'].to_i
      @num_wr = position_counts['WR'].to_i
      @num_rb = position_counts['RB'].to_i
      @num_te = position_counts['TE'].to_i
      @num_wrt = position_counts['W/R/T'].to_i
      @num_k = position_counts['K'].to_i
      @num_def = position_counts['DEF'].to_i
    end

    def ideal_lineup_wrapper(raw_roster)
      raw_roster.each do |player|
        if player['eligible_positions']['position'].is_a? Array
          player['eligible_positions']['position'].reject! { |p| p == 'W/R/T'}
        end
      end
      
      # Resolve players with dual eligibility
      # e.g. Cordarrelle Patterson - WR,RB; Taysom Hill - QB, TE
      # Normally, a greedy algorithm works fine to find the best lineup,
      # but dual eligibility players mess this up. So, for those we need
      # to test every combination.
      possible_rosters = resolve_eligible_positions(raw_roster, [])

      max_points = 0
      best_lineup = []
      possible_rosters.each do |roster|
        lineup, points = ideal_starting_lineup(roster)
        if points > max_points
          max_points = points
          best_lineup = lineup
        end
      end
      [max_points, best_lineup]
    end

    def deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end

    def resolve_eligible_positions(roster, possible_rosters)
      roster.each_with_index do |player, i|
        possible_positions = player['eligible_positions']['position']
        if possible_positions.is_a? Array
          possible_positions.each do |pos|
            modified_roster = deep_copy(roster)
            modified_roster[i]['eligible_positions']['position'] = pos
            resolve_eligible_positions(modified_roster, possible_rosters)
          end
          return possible_rosters
        end
      end
      possible_rosters.push(roster)
      possible_rosters
    end

    def ideal_starting_lineup(roster)
      player_by_position = {
        'QB' => [],
        'WR' => [],
        'RB' => [],
        'TE' => [],
        'K' => [],
        'DEF' => []
      }

      roster.each do |player|
        player_by_position[player['eligible_positions']['position']] << player
      end

      player_by_position.each do |_, arr|
        arr.sort_by! { |player| -player['player_points']['total'].to_f }
      end
      
      flex_candidates = [
        player_by_position['WR'].drop(@num_wr),
        player_by_position['RB'].drop(@num_rb),
        player_by_position['TE'].drop(@num_te)
      ].flatten.sort_by { |player| -player['player_points']['total'].to_f }

      starters = player_by_position['QB'].take(@num_qb) +
        player_by_position['WR'].take(@num_wr) +
        player_by_position['RB'].take(@num_rb) +
        player_by_position['TE'].take(@num_te) +
        flex_candidates.take(@num_wrt) +
        player_by_position['K'].take(@num_k) +
        player_by_position['DEF'].take(@num_def)
      
      point_total = starters.sum{ |player| player['player_points']['total'].to_f }
      starters_reduced = starters.map{ |player| [player["name"]["full"], player['player_points']['total'].to_f] }

      [starters_reduced, point_total]
    end
  end
end

# my_roster = [
#   {"eligible_positions" => {"position" => ['QB']}},
#   {"eligible_positions" => {"position" => ['QB', 'TE']}},
#   {"eligible_positions" => {"position" => ['WR', 'RB']}},
#   {"eligible_positions" => {"position" => ['A', 'B', 'C']}},
#   {"eligible_positions" => {"position" => ['D']}}
# ]