# frozen_string_literal: true

require_relative 'config/environment'

options = {}
OptionParser.new do |parser|
  parser.on('-c', '--challenge CHALLENGE', String, 'Name of the challenge to run') do |value|
    options[:challenge] = value
  end

  parser.on('-w', '--week WEEK', Integer, 'Which week of the season to run the challenge for') do |value|
    options[:week] = value
  end

  parser.on('-l', '--league LEAGUE', Integer, 'League ID (each season has a unique ID)') do |value|
    options[:league_id] = value
  end
end.parse!

challenge = if options[:challenge].nil?
              Challenges.ask_user_for_challenge
            else
              Challenges.get_challenge_by_name(options[:challenge])
            end

if options[:week].nil?
  puts 'For which week would you like to run the challenge?'
  options[:week] = gets.chomp.to_i
end

if options[:league_id].nil?
  puts 'For which league would you like to run the challenge?'
  options[:league_id] = gets.chomp.to_i
end

challenge.run(options[:week], options[:league_id])
