# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'active_support/core_ext/integer/inflections'
require_relative 'lib/yahoo_data_fetcher.rb'

week = 10
by_team = {}
teams = YahooDataFetcher::Teams.new

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)
  puts("************** #{team_name} **************")

  puts('Starting roster:')
  roster = YahooDataFetcher::WeeklyRosterStats.fetch_full_roster_stats(week, team_index)

  max_points = 0
  best_player_summary = 'None'

  roster.each do |player|
    next if player[:roster_position] == 'BN'

    player_history = YahooDataFetcher::PlayerHistory.new(player[:player_id])

    message = "#{player[:player_name].ljust(21)} " +
              "(#{player[:player_position]}) ".ljust(6) +
              "#{player[:points].to_s.rjust(5)} | " +
              "#{player_history.most_recent_event}"

    puts(message)

    if player_history.acquired_in_trade? && player[:points] > max_points
      max_points = player[:points]
      best_player_summary = message
    end
  end

  by_team[team_name] = {
    points: max_points,
    msg: best_player_summary
  }

  puts("\nBest player acquired via trade:")
  puts(best_player_summary)
  puts("\n")

  sleep(10) # Try not to exceed rate limit
end

puts('************** RESULTS **************')
by_team.sort_by { |_, data| -data[:points] }.each_with_index do |(team, data), index|
  print("#{(index + 1).ordinalize} place: #{team.ljust(20)} - #{data[:msg]}\n")
end
