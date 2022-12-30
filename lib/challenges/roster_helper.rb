# frozen_string_literal: true

require 'csv'

module Challenges
  # Utility to pull rosters with player salaries.
  class RosterHelper
    def run(week, league_id)
      yahoo_client = YahooDataFetcher::Client.new(league_id)
      teams = yahoo_client.fetch_teams
      player_history = YahooDataFetcher::PlayerHistory.new(yahoo_client, week)

      rows = []

      teams.each do |team|
        team_players = []
        team_name = team['name']

        roster = yahoo_client.fetch_roster(team['team_key'], week)
        roster.each do |player|
          position = player['selected_position']['position']

          player_key = player['player_key']

          player_name = player['name']['full']
          acquistion = player_history.acquistion(player_key)
          salary = player_history.salary(player_key)
          readable = player_history.salary_human_readable(player_key)

          rows << [team_name, player_name, salary, acquistion, readable]
        end

      end

      csv_string = CSV.generate do |csv|
        csv << ["team_name", "player_name", "salary", "acquisition_type", "acquisition_deatils"]
        rows.map { |r| csv << r }
      end
      puts csv_string                                   
    end
  end
end