# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'active_support/core_ext/integer/inflections'
require_relative 'lib/yahoo_data_fetcher.rb'

by_team = {}

teams = YahooDataFetcher::Teams.new

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)
  puts("************** #{team_name} **************")

  week_2_data = YahooDataFetcher::WeeklyRosterStats.fetch_stats(2, team_index)

  total_targets = 0
  total_receptions = 0

  week_2_data.each do |player|
    next unless player[:position] == 'WR'

    player_name = player[:player_name]
    targets = player[:receiving_targets]
    receptions = player[:receiving_receptions]

    puts "#{player_name} caught #{receptions} of #{targets} targets"

    total_targets += targets
    total_receptions += receptions
  end

  catch_pct = (100 * total_receptions / total_targets.to_f).round(2)

  puts "\n#{team_name}'s WRs had an overall catch percentage of #{catch_pct}% (#{total_receptions} / #{total_targets})\n\n"
  by_team[team_name] = {
    receptions: total_receptions,
    targets: total_targets,
    catch_pct: catch_pct
  }
end

puts('************** RESULTS **************')
by_team.sort_by { |_, data| -data[:catch_pct] }.each_with_index do |(team, data), index|
  print("In #{(index + 1).ordinalize} place: #{team}, who had an overall catch percentage of #{data[:catch_pct]}%")
  puts(" (#{data[:receptions]} / #{data[:targets]})")
end
