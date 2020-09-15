# frozen_string_literal: true

module YahooDataFetcher
  class DraftResults
    attr_reader :data
    def initialize
      @data = fetch_draft_data
    end

    def price_for_player(player_id)
      @data[player_id][:price]
    end

    def player_drafted_by_team?(player_id, team_name)
      return false if @data[player_id].nil?

      @data[player_id][:team_name] == team_name
    end

    private

    # "$1,234" => 1234
    def parse_price(price_text)
      price_text.gsub(/\D/, '').to_i
    end

    def fetch_draft_data
      draft_results = Nokogiri::HTML(open('https://football.fantasysports.yahoo.com/f1/810182/draftresults'))
      rows = draft_results.css('table')[0].css('tbody tr')

      data = {}

      rows.each do |row|
        player_id = row.children[3].css('a').first['href'].split('/').last
        data[player_id] = {
          player_name: row.children[3].css('a').text,
          price: parse_price(row.children[5].text),
          team_name: row.children[7].text
        }
      end

      data
    end
  end
end
