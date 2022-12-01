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
    when 'civil_war'
      CivilWar.new
    when 'das_boot'
      DasBoot.new
    when 'dynamic_duo'
      DynamicDuo.new
    when 'famous_jameis'
      FamousJameis.new
    when 'gronk'
      GronksFavoriteNumber.new
    when 'long_haul'
      LongHaul.new
    when 'moneyball2'
      Moneyball2.new
    when 'playoff_push'
      PlayoffPush.new
    when 'running_max'
      RunningMaxEfficiency.new
    when 'sandbagger'
      Sandbagger.new
    when 'show_me_your_tds'
      ShowMeYourTDs.new
    when 'shutout'
      Shutout.new
    when 'sleeper_hit'
      SleeperHit.new
    when 'smart_start'
      SmartStart.new
    when 'smarter_than_yahoo'
      SmarterThanYahoo.new
    when 'stats101'
      Stats101.new
    when 'sticky_hands'
      StickyHands.new
    when 'total_yards'
      TotalYards.new
    when 'vulture_squad'
      VultureSquad.new      
    when 'vulture_victim'
      VultureVictim.new
    end
  end
end
