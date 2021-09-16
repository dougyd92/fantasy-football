# frozen_string_literal: true

module YahooDataFetcher
  class WeeklyRosterStats
    def self.fetch_offense_stats(week, team_index, league_id)
      player_data = []

      roster_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/#{league_id}/#{team_index}/team?&week=#{week}"))
      rows = roster_doc.css('table#statTable0 tbody').children
      rows.each do |row|
        player_data.append(
          {
            roster_position: row.children[0].text,
            player_name: row.children[1].css('div.ysf-player-name').children.first.text,
            player_position: row.children[1].css('div.ysf-player-name').children[2].text.split('-').last.strip,
            player_id: row.children[1].css('div.ysf-player-name').children.first['href'].split('/').last,
            points: row.children[6].text.to_f,
            projected_pts: row.children[7].text.to_f,
            passing_yds: row.children[9].text.to_i,
            passing_tds: row.children[10].text.to_i,
            interceptions: row.children[11].text.to_i,
            rushing_attempts: row.children[12].text.to_i,
            rushing_yds: row.children[13].text.to_i,
            rushing_tds: row.children[14].text.to_i,
            receiving_targets: row.children[15].text.to_i,
            receiving_receptions: row.children[16].text.to_i,
            receiving_yds: row.children[17].text.to_i,
            receiving_tds: row.children[18].text.to_i
          }
        )
      end

      player_data
    end

    def self.fetch_kicker_stats(week, team_index, league_id)
      player_data = []

      roster_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/#{league_id}/#{team_index}/team?&week=#{week}"))
      rows = roster_doc.css('table#statTable1 tbody').children
      rows.each do |row|
        player_data.append(
          {
            roster_position: row.children[0].text,
            player_name: row.children[1].css('div.ysf-player-name').children.first.text,
            player_position: row.children[1].css('div.ysf-player-name').children[2].text.split('-').last.strip,
            player_id: row.children[1].css('div.ysf-player-name').children.first['href'].split('/').last,
            points: row.children[5].text.to_f,
            projected_pts: row.children[6].text.to_f
          }
        )
      end

      player_data
    end

    def self.fetch_defense_stats(week, team_index, league_id)
      player_data = []

      roster_doc = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/#{league_id}/#{team_index}/team?&week=#{week}"))
      rows = roster_doc.css('table#statTable2 tbody').children
      rows.each do |row|
        next if row.children[5].text == 'Bye'

        player_name = row.children[1].css('div.ysf-player-name').children.first.text
        next if player_name == '(Empty)'

        player_data.append(
          {
            roster_position: row.children[0].text,
            player_name: player_name,
            player_position: row.children[1].css('div.ysf-player-name').children[2].text.split('-').last.strip,
            player_id: row.children[1].css('.playernote').first['data-ys-playerid'],
            points: row.children[5].text.to_f,
            projected_pts: row.children[6].text.to_f,
            pts_vs: row.children[8].text.to_i,
            sacks: row.children[9].text.to_i,
            safeties: row.children[10].text.to_i,
            interceptions: row.children[11].text.to_i,
            fumbles: row.children[12].text.to_i,
            tds: row.children[13].text.to_i,
            blocked_kicks: row.children[14].text.to_i,
            return_tds: row.children[15].text.to_i
          }
        )
      end

      player_data
    end

    def self.fetch_full_roster_stats(week, team_index)
      fetch_offense_stats(week, team_index) +
        fetch_kicker_stats(week, team_index) +
        fetch_defense_stats(week, team_index)
    end
  end
end
