# frozen_string_literal: true

require 'net/http'

module YahooDataFetcher
  class PlayerHistory
    attr_reader :data

    def initialize(player_id, league_id)
      @data = fetch_player_history(player_id)
      @league_id = league_id
    end

    def fetch_player_history(player_id)
      response = Net::HTTP.get_response(URI.parse("https://football.fantasysports.yahoo.com/f1/#{@league_id}/playernote?init=0&view=history&pid=#{player_id}"))
      doc = Nokogiri::HTML(JSON.parse(response.body)['content'])
      rows = doc.css('tr')[1..]
      rows.map do |row|
        {
          date: row.children[1].text,
          event: row.children[3].text
        }
      end
    end

    def most_recent_event
      @data.first[:event]
    end

    def acquired_in_trade?
      most_recent_event.start_with?('Traded')
    end

    def owned_since_draft?
      most_recent_event.start_with?('Drafted')
    end
  end
end
