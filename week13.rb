# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require_relative 'lib/yahoo_data_fetcher.rb'

week = 13
team_results = []

teams = YahooDataFetcher::Teams.new

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)
  puts("************** #{team_name} **************")

  weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_kicker_stats(week, team_index)
  # Grab the starter, as a team might also have a defense on their bench.
  starting_k = weekly_data.select { |player| player[:roster_position] == 'K' }.first

  stats = YahooDataFetcher::KickerStats.new(starting_k[:player_id]).most_recent

  # Here as a sanity check, since KickerStats doesn't accept week as a parameter
  game_identifier = "#{stats[:game_score]} #{'VS ' unless stats[:opponent].start_with?('@')}#{stats[:opponent]}"

  puts "#{starting_k[:player_name]} (#{game_identifier})"
  puts "  FGs: #{stats[:fg_attempted]}/#{stats[:fg_made]}"
  puts "  Longest: #{stats[:long]} yds"
  puts "\n"

  team_results << {
    team_name: team_name,
    long: stats[:long],
    kicker_name: starting_k[:player_name]
  }
end

puts('************** RESULTS **************')
team_results = team_results.sort_by { |data| -data[:long] }.each.with_index do |data, i|
  data[:rank] = i + 1
  data
end

tp(team_results, :rank, :team_name, :kicker_name, :long)
