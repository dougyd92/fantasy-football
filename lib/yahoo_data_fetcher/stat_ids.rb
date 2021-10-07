# frozen_string_literal: true

module YahooDataFetcher
  # From https://fantasysports.yahooapis.com/fantasy/v2/league/<league_id>/settings
  class Stats
    STAT_IDS = {
      PassYds: 4,
      PassTD: 5,
      Int: 33,
      RushAtt: 8,
      RushYds: 9,
      RushTD: 10,
      Targets: 78,
      Rec: 11,
      RecYds: 12,
      RecTD: 13,
      RetTD: 15,
      DST_RetTD: 49,
      Two_PT: 16,
      FumLost: 18,
      OffFumRetTD: 57,
      FG0_19: 19,
      FG20_29: 20,
      FG30_39: 21,
      FG40_49: 22,
      FG50_plus: 23,
      PATMade: 29,
      PtsAllow: 31,
      Sack: 32,
      FumRec: 34,
      DST_TD: 35,
      Safe: 36,
      BlkKick: 37,
      PtsAllow0: 50,
      PtsAllow1_6: 51,
      PtsAllow7_13: 52,
      PtsAllow14_20: 53,
      PtsAllow21_27: 54,
      PtsAllow28_34: 55,
      PtsAllow35_plus: 56,
      XPR: 82
    }

    def initialize(player)
      @stats = player['player_stats']['stats']['stat']
    end

    def get(stat_name)
      stat_id = STAT_IDS[stat_name]
      raise "Could not find statID for #{stat_name}" if stat_id.nil?
      @stats.select { |stat| stat['stat_id'].to_i == stat_id}.first&.dig('value').to_f
    end
  end
end

# data['league']['settings']['stat_categories']['stats']['stat'].map { |s| [s['display_name'].delete(' ').gsub('-', '_').to_sym, s['stat_id'].to_i] }.to_h