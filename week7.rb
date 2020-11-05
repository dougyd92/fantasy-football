# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'active_support/core_ext/integer/inflections'
require_relative 'lib/yahoo_data_fetcher.rb'

week = 7
puts('************** RESULTS **************')

(1..YahooDataFetcher::Teams::NUM_TEAMS)
  .map { |team_index| YahooDataFetcher::GameResults.fetch_game_results(week, team_index) }
  .sort_by { |result| result[:team_1_projected_pts] - result[:team_1_pts] }
  .each_with_index do |result, index|
    difference = result[:team_1_pts] - result[:team_1_projected_pts]

    print("#{(index + 1).ordinalize} place: ")
    print "#{result[:team_1_name]} scored #{difference.abs.round(2)} "
    print "#{difference.positive? ? 'over' : 'under'} projections "
    print "(#{result[:team_1_projected_pts]} projected, #{result[:team_1_pts]} actual) \n"
  end
