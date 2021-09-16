# frozen_string_literal: true

module YahooDataFetcher
  class Teams
    NUM_TEAMS = 12

    def initialize(league_id)
      @data = fetch_teams_data
      @league_id = league_id
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
        team_page = Nokogiri::HTML(URI.open("https://football.fantasysports.yahoo.com/f1/#{@league_id}/#{team_index}").read)
        team_page.title.split('-')[1..].join('-').split('|').first.strip
      end
    end
  end
end
