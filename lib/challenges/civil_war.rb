# frozen_string_literal: true

module Challenges
    # Highest combined scores from two starters playing against each other.
    class CivilWar
      def run(week, league_id)
        puts 'Civil War: Highest combined scores from two starters playing against each other.'
        puts ''
  
        yahoo_client = YahooDataFetcher::Client.new(league_id)
        teams = yahoo_client.fetch_teams
  
        team_results = []
        all_players = []

        # ToDo: would be nice to do this programmatically
        # [Visitor, Home]
        nfl_matchups = [
            ['Atl', 'Car'],
            ['Sea', 'TB'],
            ['Det', 'Chi'],
            ['Cle', 'Mia'],
            ['Den', 'Ten'],
            ['Min', 'Buf'],
            ['Hou', 'NYG'],
            ['Jax', 'KC'],
            ['NO', 'Pit'],
            ['Ind', 'LV'],
            ['Ari', 'LAR'],
            ['Dal', 'GB'],
            ['LAC', 'SF'],
            ['Was', 'Phi'],
        ]
  
        teams.each do |team|
            team_name = team['name']
            puts team_name

            players_by_team = Hash.new { |h, k| h[k] = [] }

            roster = yahoo_client.fetch_roster(team['team_key'], week)
            roster.each do |player|
                position = player['selected_position']['position']
                next if position == 'BN'

                nfl_team = player['editorial_team_abbr']
                player_name = player['name']['full']
                points = player['player_points']['total'].to_f

                players_by_team[nfl_team].push([player_name, points])
            end

            team_best_pts = 0.0
            team_best_pair = ''

            nfl_matchups.each do |home, away|
                home_players = players_by_team[home].sort_by { |player, pts| -pts }
                away_players = players_by_team[away].sort_by { |player, pts| -pts }

                if !home_players.empty? && !away_players.empty?
                    sum = home_players.first[1] + away_players.first[1]
                    pair = "#{away}@#{home}: #{away_players.first[0]} (#{away_players.first[1]}), #{home_players.first[0]} (#{home_players.first[1]})"
                    puts(pair)
                    if sum > team_best_pts
                        team_best_pts = sum.round(2)
                        team_best_pair = pair
                    end
                end
            end

            challenge_rating = team_best_pts

            team_results << {
                team_name: team_name,
                challenge_rating: challenge_rating,
                best_pair: team_best_pair
            }

            puts "Civil War rating: #{challenge_rating}"
            puts ''
        end
  
        puts('************** RESULTS **************')
        team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
          data[:rank] = i + 1
          data
        end
  
        tp(team_results, :rank, :team_name, :challenge_rating, best_pair: { fixed_width: 54 })
        puts ''

      end
    end
  end
  