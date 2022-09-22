# frozen_string_literal: true

module Challenges
    # Most points from a single player who had 0 TDs (excludes K and DEF)
    class VultureSquad
      def run(week, league_id)
        puts 'Vulture Squad: Most recieving+rushing TDs divided by receiving+rushing yards.'
        puts ''
  
        yahoo_client = YahooDataFetcher::Client.new(league_id)
        teams = yahoo_client.fetch_teams
  
        team_results = []
        all_players = []
  
        teams.each do |team|
            team_tds = 0  
            team_yds = 0
            team_players = []
            team_name = team['name']

            roster = yahoo_client.fetch_roster(team['team_key'], week)
            roster.each do |player|
            position = player['selected_position']['position']
            next if ['BN', 'DEF', 'K'].include?(position)

            stats = YahooDataFetcher::Stats.new(player)
            receiving_tds = stats.get(:RecTD)
            rushing_tds = stats.get(:RushTD)
            receiving_yds = stats.get(:RecYds)
            rushing_yds = stats.get(:RushYds)

            team_tds += receiving_tds + rushing_tds
            team_yds += receiving_yds + rushing_yds

            player_data = {
                name: player['name']['full'],
                receiving_tds: receiving_tds,
                rushing_tds: rushing_tds,
                receiving_yds: receiving_yds,
                rushing_yds: rushing_yds
            }

            team_players << player_data
            all_players << player_data.merge({ team: team_name })
            end

            challenge_rating = team_tds / team_yds.to_f

            team_results << {
                team_name: team_name,
                team_tds: team_tds,
                team_yards: team_yds,
                challenge_rating: challenge_rating
            }

            puts team_name
            puts 'Starting players:'

            tp(team_players,
                { name: { fixed_width: 22 } },
                :receiving_tds,
                :rushing_tds,
                :receiving_yds,
                :rushing_yds)

            puts "Team TDs (receiving+rushing): #{team_tds}"
            puts "Team yards (receiving+rushing): #{team_yds}"
            puts "Vulture Squad rating: #{challenge_rating}"
            puts ''
        end
  
        puts('************** RESULTS **************')
        team_results = team_results.sort_by { |data| -data[:challenge_rating] }.each.with_index do |data, i|
          data[:rank] = i + 1
          data
        end
  
        tp(team_results, :rank, :team_name, :team_tds, :team_yards, :challenge_rating)
        puts ''

      end
    end
  end
  