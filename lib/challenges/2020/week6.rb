# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'active_support/core_ext/integer/inflections'
require_relative 'lib/yahoo_data_fetcher.rb'

week = 6
by_team = {}

teams = YahooDataFetcher::Teams.new

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)

  weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_offense_stats(week, team_index)

  starting_te = weekly_data.select { |player| player[:roster_position] == 'TE' }.first

  by_team[team_name] = {
    player_name: starting_te[:player_name],
    points: starting_te[:points]
  }
end

puts('************** RESULTS **************')
by_team.sort_by { |_, data| -data[:points] }.each_with_index do |(team, data), index|
  print("In #{(index + 1).ordinalize} place: #{team} - #{data[:player_name]} - ")
  puts("#{data[:points]} pts")
end
