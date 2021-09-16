# frozen_string_literal: true

module Challenges
  # TODO make this generic for any week
  class Week5
    def run(week, league_id)
      puts "run 2020week5 for week #{week} league #{league_id}"
            
      week = 5

      results = (1..YahooDataFetcher::Teams::NUM_TEAMS).map do |team_index|
        YahooDataFetcher::GameResults.fetch_game_results(week, team_index)
      end

      puts('************** RESULTS **************')

      results.sort_by { |result| result[:team_2_pts] - result[:team_1_pts] }.each_with_index do |result, index|
        print("In #{(index + 1).ordinalize} place: ")

        differential = result[:team_1_pts] - result[:team_2_pts]

        outcome = if differential.positive?
                    'beat'
                  elsif differential.negative?
                    'lost to'
                  else
                    'tied'
                  end

        print "#{result[:team_1_name]} #{outcome} #{result[:team_2_name]} by #{differential.abs.round(2)} points"
        puts " (#{result[:team_1_pts]} - #{result[:team_2_pts]})"
      end
    end
  end
end