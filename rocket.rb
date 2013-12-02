require 'pry'
require 'csv'

class Score
  def initialize
    @win_records = {}
  end

  def team_info
    puts 'What was team 1\'s name?'
    team_1 = gets.chomp
    puts 'What was team 1\'s score?'
    team_1_score = gets.chomp.to_i
    puts 'What was team 2\'s name?'
    team_2 = gets.chomp
    puts 'What was team 2\'s score?'
    team_2_score = gets.chomp.to_i
    identify_winner(team_1, team_1_score, team_2, team_2_score)
  end

  def identify_winner(team_1, team_1_score, team_2, team_2_score)
    if team_1_score > team_2_score
      puts "#{team_1} is the victor!"
      record_game(team_1, team_2)
    else
      puts "#{team_2} is the victor!"
      record_game(team_2, team_1)
    end
    again?
  end

  def record_game(winner, loser)
    @win_records[winner] = @win_records.fetch(winner){|team|[0,0]}
    @win_records[winner][0] += 1
    @win_records[loser] = @win_records.fetch(loser) {|team|[0,0]}
    @win_records[loser][1] += 1
  end

  def again?
    puts "Would you like to look up another game result?"
    answer = gets.chomp.downcase
    if answer == "yes"
      team_info
    elsif answer == "no"
      save_csv
      display_log
    else
      puts "Invalid input. Please type -yes- or -no-."
      again?
    end
  end

  def update_records
    CSV.foreach('scores.csv', headers: true) do |row| 
      @win_records[row["team"]] = [row["wins"].to_i,row["losses"].to_i]
    end
    team_info
  end

  def save_csv
    File.open('scores.csv', 'w') do |score|
      score.puts "team,wins,losses"
      @win_records.keys.each do |team|
        score.puts "#{team},#{@win_records[team][0]},#{@win_records[team][1]}"
      end
    end
  end

  def display_log
    teams = []
    CSV.foreach('scores.csv', headers: true) do |row| 
      teams << {team: row['team'], wins: row['wins'], losses: row['losses']}
    end
    counter = 1
    teams.each do |team|
      puts "In Game #{counter}, #{team[:team]} is the victor!"
      counter += 1
    end
    league_counter = 1
    puts "\n*** League Standings ***"
    sorted_teams = teams.sort do |team1,team2|
      team2[:wins] != team1[:wins] ? team2[:wins] <=> team1[:wins] : team2[:losses] <=> team1[:losses]
    end
    sorted_teams.each do |team|
      puts "#{league_counter}. #{team[:team]}: #{team[:wins]}W, #{team[:losses]}L"
      league_counter += 1
    end
    exit
  end
end

score = Score.new
score.update_records