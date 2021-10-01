# frozen_string_literal: true

module YahooDataFetcher
  # From https://fantasysports.yahooapis.com/fantasy/v2/league/<league_id>/settings
  class StatIds
    PASSING_YARDS = '4'.freeze
    PASSING_TDS = '5'.freeze
    INTERCEPTIONS = '6'.freeze
    RUSHING_ATTEMPTS = '8'.freeze
    RUSHING_YARDS = '9'.freeze
    RUSHING_TDS = '10'.freeze
    RECEPTIONS = '11'.freeze
    RECEIVING_YARDS = '12'.freeze
    RECEIVING_TDS = '13'.freeze
    TARGETS = '78'.freeze
  end
end
