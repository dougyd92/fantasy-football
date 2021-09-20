module Challenges
  def self.ask_user_for_challenge
    puts 'Which challenge would you like to run?'
    options = constants.select { |c| const_get(c).is_a? Class }.sort
    options.each_with_index do |opt, i|
      puts "#{i} - #{opt}"
    end
    selection = gets.chomp.to_i
    const_get(options[selection]).new
  end

  def self.get_challenge_by_name(challenge_name)
    case challenge_name.downcase
    when 'moneyball2'
      Moneyball2.new
    end
  end
end
