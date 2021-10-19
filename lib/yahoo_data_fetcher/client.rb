# frozen_string_literal: true

module YahooDataFetcher
  class Client
    # 597209
    def initialize(league_id)
      @auth_token = refresh_auth_token
      @league_id = league_id
    end

    def fetch_draft_results
      data = make_request("league/nfl.l.#{@league_id}/draftresults")
      data['league']['draft_results']['draft_result']
    end

    def fetch_keepers(start)
      data = make_request("league/nfl.l.#{@league_id}/players;status=K;start=#{start}")
      data['league']['players']['player']
    end

    def fetch_player_season_long_stats(player_key)
      data = make_request("/player/#{player_key}/stats;type=season")
      data['player']
    end

    def fetch_roster(team_key, week)
      data = make_request("/team/#{team_key}/roster;week=#{week}/players/stats")
      data['team']['roster']['players']['player']
    end

    def fetch_settings
      data = make_request("league/nfl.l.#{@league_id}/settings")
      data['league']['settings']
    end

    def fetch_team_score(team_key, week)
      data = make_request("/team/#{team_key}/stats;type=week;week=#{week}")
      data['team']['team_points']['total'].to_f
    end

    def fetch_teams
      data = make_request("league/nfl.l.#{@league_id}/teams")
      data['league']['teams']['team']
    end

    def fetch_transactions
      data = make_request("league/nfl.l.#{@league_id}/transactions")
      data['league']['transactions']['transaction']
    end

    def fetch_weeks
      data = make_request('game/nfl/game_weeks')
      data['game']['game_weeks']['game_week']
    end

    private

    def refresh_auth_token
      response = RestClient.post(
        'https://api.login.yahoo.com/oauth2/get_token',
        {
          grant_type: 'refresh_token',
          redirect_uri: 'oob',
          client_id: ENV['YAHOO_API_CLIENT_ID'],
          client_secret: ENV['YAHOO_API_CLIENT_SECRET'],
          refresh_token: ENV['YAHOO_API_REFRESH_TOKEN']
        },
        {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      )
      JSON.parse(response.body)['access_token']
    end

    def make_request(query)
      response = RestClient.get(
        "https://fantasysports.yahooapis.com/fantasy/v2/#{query}",
        {
          'Content-Type': 'application/x-www-form-urlencoded',
          Authorization: "Bearer #{@auth_token}"
        }
      )
      Hash.from_xml(response.body)['fantasy_content']
    end
  end
end
