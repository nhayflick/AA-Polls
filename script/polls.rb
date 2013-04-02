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
        puts "#{user.username.rjust(15)} - team: #{team}"
      end
    end

    def list_polls
      Poll.includes(:team).all.each do |poll|
        team = poll.team ? " => (" + poll.team.name + ")" : ''
        puts "#{poll.id.to_s.rjust(2)} - #{poll.title}#{team}"
      end
    end

    def show_poll(poll_id)
      poll = Poll.includes(:questions => [:choices => [:responses]]).find(poll_id)
      if poll.nil?
        puts "Invalid poll id"
      else
        puts poll.title
        poll.questions.each do |question|
          puts question.body
          question.choices.each do |choice|
            puts "#{choice.body} - #{choice.responses.count}"
          end
        end
      end
    end

    def list_user_polls(username)
      user = User.find_by_username(username)
      if user.nil?
        puts "Invalid username: #{username}"
      else
        user.polls.each do |poll|
          puts "#{poll.id.to_s.rjust(2)} - #{poll.title}"
        end
      end
    end

    def list_user_answers(username)
      user = User.find_by_username(username)
      if user.nil?
        puts "Invalid username: #{username}"
      else
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

        poll.questions.each do |question|
          next if question.has_answered_this_question?(user.id)
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
      end
    end

    def create_poll(user)
      poll_title = get_non_empty_input "Select a name for your poll:"
      team_only = get_non_empty_input("Team only? (y/n) ").downcase[0] == 'y'
    
      poll = Poll.create!(creator_id: user.id, title: poll_title, 
        team_id: team_only ? user.team_id : nil)

      create_questions(poll)
    end

    def create_questions(poll, questions = 0)
      while true
        question_body = get_non_empty_input "Question #{questions + 1}:"
        question = poll.add_question(question_body)
        create_choices(question)
        break if get_non_empty_input("Add another question? (y/n) ").downcase[0] == 'n'
        questions += 1
      end
      questions
    end

    def create_choices(question)
      choices = 0
      while true
        choice = get_non_empty_input "Choice #{choices + 1}:"
        question.add_choice(choice)
        break if get_non_empty_input("Add another choice? (y/n) ").downcase[0] == 'n'
        choices += 1
      end
      choices
    end

    def get_non_empty_input(s = nil)
      puts s unless s.nil?
      input = ""
      while input.empty?
        input = gets.chomp.strip
      end
      input
    end

    def delete_question(user, poll_id, question_index)
      poll = Poll.includes(:questions).find(poll_id)
      if poll.nil?
        puts "That poll doesn't exist yet."
      elsif poll.creator_id != user.id
        puts "Only a poll's creator can delete questions."
      else 
        poll.questions[question_index.to_i - 1].destroy unless poll.questions[question_index.to_i - 1].nil?
      end
    end

    def add_question(user, poll_id)
      poll = Poll.includes(:questions).find(poll_id)
      if poll.nil?
        puts "That poll doesn't exist yet."
      elsif poll.creator_id != user.id
        puts "Only a poll's creator can add questions."
      else 
        create_questions(poll, poll.questions.count)
      end
    end

    def run
      user = login
      while true
        print "Polls: > "
        input = get_non_empty_input.split(' ')
        case input[0]
        when 'users'            then list_users
        when 'polls'            then list_polls
        when 'user-polls'       then list_user_polls(input[1])
        when 'user-answers'     then list_user_answers(input[1])
        when 'poll'             then show_poll(input[1])
        when 'take-poll'        then take_poll(user, input[1])
        when 'create-poll'      then create_poll(user)
        when 'add-question'     then add_question(user, input[1])
        when 'delete-question'  then delete_question(user, input[1], input[2])
        when 'exit'             then break
        when 'quit'             then break
        else                    puts 'Invalid command'
        end
      end
    end
  end
end


Polls.run