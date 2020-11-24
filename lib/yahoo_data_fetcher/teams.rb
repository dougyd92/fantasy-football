# frozen_string_literal: true

module YahooDataFetcher
  class Teams
    NUM_TEAMS = 12

    def initialize
      @data = fetch_teams_data
    end

    def index_to_name(index)
      @data[index - 1]
    end

    def name_to_index(name)
      @data.index(name) + 1
    end

    private

    def fetch_teams_data
      (1..NUM_TEAMS).collect do |team_index|
        team_page = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/810182/#{team_index}").read)
        team_page.title.split('-').last.split('|').first.strip
      end
    end
  end
end
