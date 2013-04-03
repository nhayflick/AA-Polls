#!/usr/bin/env ruby

class Polls
  class << self
    def login
      name = get_non_empty_input "Polls: Please enter your username > "
      User.find_by_username(name) || User.create!(username: name)
    end

    def list_users
      User.includes(:team).all.each do |user|
        team = user.team ? user.team.name : 'None'
        puts "#{user.username.ljust(20)} - team: #{team}"
      end
    end

    def list_polls
      Poll.includes(:team).all.each do |poll|
        team = poll.team ? " => (" + poll.team.name + ")" : ''
        puts "#{poll.id.to_s.rjust(2)} - #{poll.title}#{team}"
      end
    end

    def print_poll(pid)
      poll = Poll.includes(:questions => [:choices => [:responses]]).find(pid)
      if poll.nil?
        puts "Invalid poll id"
      else
        puts poll.title
        poll.questions.each { |question| print_question(question) }
      end
    end

    def print_question(question)
      puts question.body
      question.choices.each do |choice|
        puts "#{choice.body} - #{choice.responses.count}"
      end
    end

    def list_user_helper(username, &proc)
      user = User.find_by_username(username)
      if user.nil?
        puts "Invalid username: #{username}"
      else
        proc.call(user)
      end
    end

    def list_user_polls(username)
      list_user_helper(username) do |user|
        user.polls.each do |poll|
          puts "#{poll.id.to_s.rjust(2)} - #{poll.title}"
        end
      end
    end

    def list_user_answers(username)
      list_user_helper(username) do |user|
        user.responses.includes(:choice, :question).each do |response|
          puts "#{response.question.body} - #{response.choice.body}"
        end
      end
    end

    def take_poll(user, poll_id)
      poll = Poll.includes(:team, :questions => [:choices]).find(poll_id)
      if poll.nil?
        puts "Invalid poll id"
      else
        puts poll.title
        unless poll.can_user_answer?(user)
          puts "This poll is for team #{poll.team.name} only"
          return
        end
        poll.questions.each { |question| answer_question(question, user) }
      end
    end

    def answer_question(question, user)
      return if question.has_answered_this_question?(user.id)
      puts question.body
      question.choices.each_with_index do |choice, index|
        puts "#{index + 1} - #{choice.body}"
      end
      choice = 0
      while choice == 0
        choice = gets.chomp.to_i
      end
      Response.create!(user_id: user.id, 
        choice_id: question.choices[choice - 1].id)
    end

    def create_poll(user)
      poll_title = get_non_empty_input "Select a name for your poll:"
      team_only = get_non_empty_input("Team only? (y/n) ").downcase[0] == 'y'
    
      poll = Poll.create!(creator_id: user.id, title: poll_title, 
        team_id: team_only ? user.team_id : nil)

      add_questions(poll)
    end

    def add_questions(poll, questions = 0)
      while true
        question_body = get_non_empty_input "Question #{questions + 1}:"
        question = poll.add_question(question_body)
        add_choices(question)
        add_str = "Add another question? (y/n) "
        break if get_non_empty_input(add_str).downcase[0] == 'n'
        questions += 1
      end
      questions
    end

    def add_choices(question, choices = 0)
      while true
        choice = get_non_empty_input "Choice #{choices + 1}:"
        question.add_choice(choice)
        add_str = "Add another choice? (y/n) "
        break if get_non_empty_input(add_str).downcase[0] == 'n'
        choices += 1
      end
      choices
    end

    def get_non_empty_input(s = nil)
      input = ""
      while input.empty?
        puts s unless s.nil?
        input = gets.chomp.strip
      end
      input
    end

    def modify_question_helper(user, poll_id, action, &proc)
      poll = Poll.includes(:questions).find(poll_id)
      if poll.nil?
        puts "That poll doesn't exist yet."
      elsif poll.creator_id != user.id
        puts "Only a poll's creator can #{action} questions."
      else 
        proc.call(poll)
      end
    end

    def delete_question(user, poll_id, question_index)
      modify_question_helper(user, poll_id, "delete") do |poll|
        q = poll.questions[question_index.to_i - 1]
        q.destroy unless q.nil?
      end
    end

    def add_question(user, poll_id)
      modify_question_helper(user, poll_id, "add") do |poll|
        add_questions(poll, poll.questions.count)
      end
    end

    def exec_command(user, input)
      case input[0]
      when 'users'            then list_users
      when 'polls'            then list_polls
      when 'user-polls'       then list_user_polls(input[1])
      when 'user-answers'     then list_user_answers(input[1])
      when 'poll'             then print_poll(input[1])
      when 'take-poll'        then take_poll(user, input[1])
      when 'create-poll'      then create_poll(user)
      when 'add-question'     then add_question(user, input[1])
      when 'delete-question'  then delete_question(user, input[1], input[2])
      when 'exit'             then return true
      when 'quit'             then return true
      else                    puts 'Invalid command'
      end
      false
    end


    def run
      user = login
      while true
        print "Polls: > "
        input = get_non_empty_input.split(' ')
        begin
          break if exec_command(user, input)
        rescue ActiveRecord::RecordInvalid => e
          puts e
        end
      end
    end
  end
end


Polls.run