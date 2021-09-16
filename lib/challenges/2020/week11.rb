# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require_relative 'lib/yahoo_data_fetcher.rb'

week = 11
team_results = []

teams = YahooDataFetcher::Teams.new

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)
  puts("************** #{team_name} **************")

  weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_offense_stats(week, team_index)

  rows = []
  total_yds = 0

  weekly_data.select { |player| player[:roster_position] == 'RB' }.each do |player|
    rows << {
      player_name: player[:player_name],
      rushing_yards: player[:rushing_yds]
    }

    total_yds += player[:rushing_yds]
  end

  tp(rows, { player_name: { fixed_width: 22 } }, :rushing_yards)
  puts("\n")

  team_results << {
    team_name: team_name,
    total_rushing_yards: total_yds
  }
end

puts('************** RESULTS **************')
team_results = team_results.sort_by { |data| -data[:total_rushing_yards] }.each.with_index do |data, i|
  data[:rank] = i + 1
  data
end

tp(team_results, :rank, :team_name, :total_rushing_yards)
