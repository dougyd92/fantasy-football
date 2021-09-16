# frozen_string_literal: true

module Challenges
  # TODO: make this generic for any week
  class Week16
    def run(week, league_id)
      puts "run 2020week16 for week #{week} league #{league_id}"

      week = 16
      team_results = []

      draft_results = YahooDataFetcher::DraftResults.new
      teams = YahooDataFetcher::Teams.new

      (1..YahooDataFetcher::Teams::NUM_TEAMS).each do |team_index|
        team_name = teams.index_to_name(team_index)
        puts("************** #{team_name} **************")

        players = []
        long_haul_pts = 0
        roster = YahooDataFetcher::WeeklyRosterStats.fetch_full_roster_stats(week, team_index)

        roster.each do |player|
          next unless draft_results.player_drafted_by_team?(player[:player_id], team_name)

          # Double check that player wasn't dropped and re-added
          player_history = YahooDataFetcher::PlayerHistory.new(player[:player_id])
          next unless player_history.owned_since_draft?

          player_data = {
            name: player[:player_name],
            pos: player[:player_position],
            pts: player[:points]
          }

          if player[:roster_position] == 'BN'
            player_data[:w17] = 'Bench'
          else
            long_haul_pts += player[:points]
            player_data[:w17] = 'Starter'
          end

          players << player_data
        end

        tp(players, { name: { fixed_width: 22 } }, :pos, :pts, :w17)

        long_haul_pts = long_haul_pts.round(2)

        puts("\nPlayers owned since draft: #{players.count}")
        puts("Points by starters owned since draft: #{long_haul_pts}\n\n")

        team_results << {
          team_name: team_name,
          long_haul_pts: long_haul_pts
        }

        sleep(10) # Try not to exceed rate limit
      end

      puts('************** RESULTS **************')
      team_results = team_results.sort_by { |data| -data[:long_haul_pts] }.each.with_index do |data, i|
        data[:rank] = i + 1
        data
      end

      tp(team_results, :rank, :team_name, :long_haul_pts)
    end
  end
end
