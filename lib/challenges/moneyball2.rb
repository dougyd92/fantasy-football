# frozen_string_literal: true

module Challenges
  # Highest total team points divided by total team salary.
  class Moneyball2
    def run(week, league_id)
      puts 'Moneyball2: Highest total team points divided by total team salary.'
      puts ''

      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams
      player_history = YahooDataFetcher::PlayerHistory.new(yahoo_client, week)

      team_results = []
      all_players = []

      teams.each do |team|
        total_salary = 0
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']
          next if position == 'BN'

          player_key = player['player_key']
          points = player['player_points']['total'].to_f

          player_salary = player_history.salary(player_key)
          total_salary += player_salary

          player_data = {
            name: player['name']['full'],
            pos: position,
            pts: points,
            ratio: points / player_salary.to_f,
            acquisition: player_history.salary_human_readable(player_key)
          }

          team_players << player_data
          all_players << player_data.merge({ team: team_name })
        end

        total_score = yahoo_client.fetch_team_score(team['team_key'], week)
        challenge_rating = total_score / total_salary.to_f

        team_results << {
          team_name: team_name,
          challenge_rating: challenge_rating
        }

        puts team_name
        puts 'Starting players:'

        tp(team_players,
           { name: { fixed_width: 22 } },
           :pos,
           ColumnFormatter.decimal(:pts, 2),
           ColumnFormatter.decimal(:ratio, 2),
           { acquisition: { fixed_width: 20 } })

        puts "Total score: #{total_score}"
        puts "Total salary for starters: #{total_salary}"
        puts "Moneyball ratio: #{format('%.3f', challenge_rating)} points scored per dollar spent"
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
      all_players = all_players.sort_by { |data| -data[:ratio] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end
      tp(all_players,
         :rank,
         { name: { fixed_width: 22 } },
         :pos,
         ColumnFormatter.decimal(:pts, 2),
         ColumnFormatter.decimal(:ratio, 2),
         { acquisition: { fixed_width: 20 } },
         { team: { fixed_width: 32 } })
    end
  end
end
