# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'active_support/core_ext/integer/inflections'
require './yahoo_data_fetcher/game_results.rb'
require './yahoo_data_fetcher/draft_results.rb'
require './yahoo_data_fetcher/teams.rb'

best_for_team = {}
all_players = {}

draft_results = YahooDataFetcher::DraftResults.new
teams = YahooDataFetcher::Teams.new

(1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
  team_name = teams.index_to_name(team_index)
  puts("************** #{team_name} **************")

  week_1_data = YahooDataFetcher::GameResults.fetch_game_data(1, team_index)

  best_value = 0
  best_player = ''

  week_1_data.each do |player|
    player_name = player[:player_name]
    player_id = player[:player_id]
    points = player[:points].to_f

    print "#{player_name} scored #{points}"

    if player[:position] == 'K'
      puts('; kickers are excluded for this challenge')
    elsif player[:position] == 'DEF'
      puts('; defenses are excluded for this challenge')
    elsif draft_results.player_drafted_by_team?(player_id, team_name)
      cost = draft_results.price_for_player(player_id)
      value_ratio = points / cost

      puts(" and was drafted by #{team_name} for $#{cost} => #{value_ratio.round(2)} points per dollar")

      all_players[player_id] = {
        player_name: player_name,
        cost: cost,
        points: points,
        value_ratio: value_ratio,
        team_name: team_name
      }

      if value_ratio > best_value
        best_value = value_ratio
        best_player = player_name
      end
    else
      puts(" but was not drafted by #{team_name}")
    end
  end

  puts "\n#{team_name}'s best player was #{best_player} with a points-to-dollar ratio of #{best_value.round(2)}\n\n"

  best_for_team[team_name] = {
    player_name: best_player,
    value_ratio: best_value
  }
end

puts('************** RESULTS **************')
best_for_team.sort_by { |_, data| -data[:value_ratio] }.each_with_index do |(team, data), index|
  puts("In #{(index + 1).ordinalize} place: #{team}, who had #{data[:player_name]} with a points-to-dollar ratio of #{data[:value_ratio].round(2)}")
end

all_players = all_players.sort_by { |_, data| -data[:value_ratio] }

puts("\n************** All Players **************")
all_players.each_with_index do |(_, data), index|
  puts("#{(index + 1)}) #{data[:value_ratio].round(2)} points-per-dollar: #{data[:player_name]} scored #{data[:points]}, was drafted for #{data[:cost]} by #{data[:team_name]}")
end
