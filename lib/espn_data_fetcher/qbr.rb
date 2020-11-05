# frozen_string_literal: true

module EspnDataFetcher
  class QBR
    def initialize(week)
      @data = fetch_qbrs(week)
    end

    def qbr_for_player(player_name)
      @data[player_name]
    end

    private

    def fetch_qbrs(week)
      doc = Nokogiri::HTML(URI.open("https://www.espn.com/nfl/qbr/_/view/weekly/week/#{week}"))

      player_names = doc.css('table .Table__TBODY').first.children.map { |row| row.css('a').first.text }

      qbrs = doc.css('table .Table__TBODY').last.children.map { |row| row.children[2].text.to_f }

      data = {}

      player_names.each_with_index do |player_name, i|
        data[player_name] = qbrs[i]
      end

      data
    end
  end
end
