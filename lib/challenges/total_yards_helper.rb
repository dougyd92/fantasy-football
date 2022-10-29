# frozen_string_literal: true

module Challenges
  # Utility class to print yards for each player
  class TotalYards
    def run(week, league_id)
      puts "Yards and jersey numbers for each player"
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams

      team_results = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if ['DEF', 'K'].include?(position)

          player_name = player['name']['full']
          jersey_number = player["uniform_number"]

          stats = YahooDataFetcher::Stats.new(player)
          passing_yds = stats.get(:PassYds)
          rushing_yds = stats.get(:RushYds)
          receiving_yds = stats.get(:RecYds)

          player_total_yds = passing_yds + rushing_yds + receiving_yds

          player_data = {
            name: player_name,
            number: jersey_number,
            total: player_total_yds,
            pass: passing_yds,
            rush: rushing_yds,
            rec: receiving_yds
          }
          team_players << player_data
        end
      
        puts ''
        puts team_name
        puts 'Players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :number,
           :total,
           :pass,
           :rush,
           :rec
           )
      end

      puts ''
    end
  end
end
