# frozen_string_literal: true

module YahooDataFetcher
  class PlayerHistory
    def initialize(client, week)
      @client = client
      @players = {}

      apply_draft_results
      apply_transactions_through_week(week)
    end

    def apply_draft_results
      draft_results = @client.fetch_draft_results
      draft_results.each do |dr|
        @players[dr['player_key']] = {
          team: dr['team_key'],
          salary: dr['cost'].to_i,
          acquistion: 'drafted',
          keeper: false
        }
      end

      # TODO: figure out more elegant pagination
      keepers = @client.fetch_keepers(0) + @client.fetch_keepers(25)
      keepers.each do |k|
        @players[k['player_key']][:keeper] = true
      end
    end

    def apply_transactions_through_week(week)
      cutoff_date_string = @client.fetch_weeks.select { |w| w['week'] == week.to_s }.first['end']
      cutoff_datetime = Time.strptime(cutoff_date_string, '%Y-%m-%d') + 24 * 60 * 60 # go until midnight Monday night

      transactions = @client.fetch_transactions
      transactions.sort_by { |tx| tx['timestamp'].to_i }
                  .select { |tx| Time.at(tx['timestamp'].to_i) < cutoff_datetime }
                  .each do |tx|

        next if tx['status'] != 'successful' # Vetoed trades

        case tx['type']
        when 'add/drop'
          tx['players']['player'].each do |txp|
            case txp['transaction_data']['type']
            when 'add'
              @players[txp['player_key']] = {
                team: txp['transaction_data']['destination_team_key'],
                salary: tx['faab_bid'].to_i,
                acquistion: txp['transaction_data']['source_type'],
                keeper: false
              }
            when 'drop'
              @players.delete(txp['player_key'])
            else
              raise "Encountered an unexpected transaction type: #{tx}"
            end
          end
        when 'add'
          txp = tx['players']['player']
          @players[txp['player_key']] = {
            team: txp['transaction_data']['destination_team_key'],
            salary: tx['faab_bid'].to_i,
            acquistion: txp['transaction_data']['source_type'],
            keeper: false
          }          
        when 'drop'
          txp = tx['players']['player']
          @players.delete(txp['player_key'])        
        when 'trade'
          tx['players']['player'].each do |txp|
            @players[txp['player_key']][:team] = txp['transaction_data']['destination_team_key']
            @players[txp['player_key']][:acquistion] = 'trade'
            @players[txp['player_key']][:trade_source_team_name] = txp['transaction_data']['source_team_name']
            @players[txp['player_key']][:keeper] = false
          end
        when 'commish'
          # Not sure what these are, but they don't seem to involve players
          nil
        else
          raise "Encountered an unexpected transaction type: #{tx}"
        end
      end
    end

    def salary(player_key)
      @players[player_key][:salary]
    end

    def salary_human_readable(player_key)
      player_salary = salary(player_key)
      case acquistion(player_key)
      when 'drafted'
        if keeper?(player_key)
          "Kept for $#{player_salary}"
        else
          "Drafted for $#{player_salary}"
        end
      when 'waivers'
        "Waivers; $#{player_salary} bid"
      when 'freeagents'
        'Waivers; free agent'
      when 'trade'
        "Traded; $#{player_salary} salary carries over"
      else
        raise "Encountered an unexpected acquisition type: #{@players[player_key]}"
      end
    end

    def acquistion(player_key)
      @players[player_key][:acquistion]
    end

    def keeper?(player_key)
      @players[player_key][:keeper]
    end
  end
end
