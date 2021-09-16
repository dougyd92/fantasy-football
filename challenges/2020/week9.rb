# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'active_support/core_ext/integer/inflections'
require_relative 'lib/yahoo_data_fetcher.rb'

week = 9
by_team = {}
teams = YahooDataFetcher::Teams.new

MULTIPLIERS_BY_POSITION = {
  QB: {
    passing: 0,
    rushing: 1,
    receiving: 5
  },
  WR: {
    passing: 5,
    rushing: 3,
    receiving: 0
  },
  RB: {
    passing: 5,
    rushing: 0,
    receiving: 1
  },
  TE: {
    passing: 5,
    rushing: 5,
    receiving: 0
  }
}.freeze

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)
  puts("************** #{team_name} **************")

  challenge_points = 0
  scoring_summaries = []
  roster_stats = YahooDataFetcher::WeeklyRosterStats.fetch_offense_stats(week, team_index)

  roster_stats.each do |player|
    next if player[:roster_position] == 'BN'

    multipliers = MULTIPLIERS_BY_POSITION[player[:player_position].to_sym]
    score = player[:passing_yds] * multipliers[:passing] +
            player[:rushing_yds] * multipliers[:rushing] +
            player[:receiving_yds] * multipliers[:receiving]

    challenge_points += score

    if score.positive?
      player_scores = []
      player_scores << "#{player[:passing_yds]} pass yds" if player[:passing_yds] * multipliers[:passing] != 0
      player_scores << "#{player[:rushing_yds]} rush yds" if player[:rushing_yds] * multipliers[:rushing] != 0
      player_scores << "#{player[:receiving_yds]} receiving yds" if player[:receiving_yds] * multipliers[:receiving] != 0
      scoring_summaries << "#{player[:player_name]} (#{player[:player_position]}) #{player_scores.join(', ')}"
    end

    print("#{player[:player_name].ljust(21)} (#{player[:player_position]}) | ")
    print("passing: #{player[:passing_yds].to_s.rjust(3)} * #{multipliers[:passing]} | ")
    print("rushing: #{player[:rushing_yds].to_s.rjust(3)} * #{multipliers[:rushing]} | ")
    print("receiving: #{player[:receiving_yds].to_s.rjust(3)} * #{multipliers[:receiving]} | ")
    puts("challenge points: #{score.to_s.rjust(2)}")
  end

  puts("\nTotal challenge points for team: #{challenge_points} \n\n")

  by_team[team_name] = {
    challenge_points: challenge_points,
    msg: "(#{scoring_summaries.join(', ')})"
  }
end

puts('************** RESULTS **************')
by_team.sort_by { |_, data| -data[:challenge_points] }.each_with_index do |(team, data), index|
  print("#{(index + 1).ordinalize} place: #{team.ljust(20)} - #{data[:challenge_points]} challenge points ")
  puts(data[:msg])
end
