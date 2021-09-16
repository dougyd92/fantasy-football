# frozen_string_literal: true

module Challenges
  # TODO make this generic for any week
  class Week3
    NUM_QB = 1
    NUM_RB = 2
    NUM_WR = 3
    NUM_TE = 1
    NUM_FLEX = 1
    NUM_K = 1
    NUM_DEF = 1

    def ideal_roster(weekly_data)
      player_by_position = weekly_data.each_with_object({}) do |player, hash|
        hash[player[:player_position]] ||= []
        hash[player[:player_position]] << player
      end

      player_by_position.each do |_, arr|
        arr.sort_by! { |player| -player[:points] }
      end

      flex_candidates = [
        player_by_position['RB'][NUM_RB],
        player_by_position['WR'][NUM_WR],
        player_by_position['TE'][NUM_TE]
      ].compact.sort_by { |player| -player[:points] }

      player_by_position['QB'].take(NUM_QB) +
        player_by_position['RB'].take(NUM_RB) +
        player_by_position['WR'].take(NUM_WR) +
        player_by_position['TE'].take(NUM_TE) +
        flex_candidates.take(NUM_FLEX) +
        player_by_position['K'].take(NUM_K) +
        player_by_position['DEF'].take(NUM_DEF)
    end

    def run(week, league_id)
      puts "run 2020week3 for week #{week} league #{league_id}"

      by_team = {}

      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)
        puts("************** #{team_name} **************")

        weekly_data = YahooDataFetcher::WeeklyRosterStats.fetch_full_roster_stats(3, team_index)

        ideal_roster = ideal_roster(weekly_data)

        actual_roster = weekly_data.reject { |player| player[:roster_position] == 'BN' }

        ideal_pts = ideal_roster.map { |player| player[:points] }.sum
        actual_pts = actual_roster.map { |player| player[:points] }.sum

        shouldnta = actual_roster - ideal_roster
        shoulda = ideal_roster - actual_roster

        pts_differential = actual_pts - ideal_pts

        puts "Points scored (actual): #{actual_pts.round(2)}"
        puts "Points scored (ideal lineup): #{ideal_pts.round(2)}"
        puts "Difference: #{pts_differential.round(2)}"

        puts "You should have started #{shoulda.map do |player|
                                          "#{player[:player_name]} (#{player[:points]})"
                                        end.join(', ')}"
        puts "instead of #{shouldnta.map { |player| "#{player[:player_name]} (#{player[:points]})" }.join(', ')}"

        puts "\n"
        by_team[team_name] = pts_differential
      end

      puts('************** RESULTS **************')
      by_team.sort_by { |_, pts_differential| -pts_differential }.each_with_index do |(team, pts_differential), index|
        puts("In #{(index + 1).ordinalize} place: #{team}, with a point differential of #{pts_differential.round(2)}")
      end
    end
  end
end
