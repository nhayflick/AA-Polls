# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or create!d alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

Team.create!(name: 'aa')

User.create!(username: 'nate', team_id: 1)
User.create!(username: 'peter', team_id: 1)
User.create!(username: 'otherperson')

Poll.create!(creator_id: 1, title: 'Team Poll', team_id: 1)
Poll.create!(creator_id: 3, title: 'Public Poll')

Question.create!(poll_id: 1, body: 'What is Active Record?')
Question.create!(poll_id: 1, body: 'Do you like polls?')
Choice.create!(question_id: 1, body: 'A RoR thing') 	#1
Choice.create!(question_id: 1, body: 'A sure thing') 	#2
Choice.create!(question_id: 1, body: 'No idea') 		#3
Choice.create!(question_id: 1, body: 'Active Record') 	#4
Choice.create!(question_id: 2, body: 'Yes')				#5
Choice.create!(question_id: 2, body: 'No')			 	#6

Question.create!(poll_id: 2, body: 'Where is your favorite lunch place?')
Question.create!(poll_id: 2, body: 'Where is the best place to sleep?')

Choice.create!(question_id: 3, body: 'Lee\'s')		 	#7
Choice.create!(question_id: 3, body: 'Lightening Foods')#8
Choice.create!(question_id: 3, body: 'Subway')		 	#9
Choice.create!(question_id: 3, body: 'AA kitchen') 		#10

Choice.create!(question_id: 4, body: 'AA sofa')		 	#11	
Choice.create!(question_id: 4, body: 'AA office')	 	#12
Choice.create!(question_id: 4, body: 'AA toilet')	 	#13
Choice.create!(question_id: 4, body: 'AA kitchen')	 	#14

Response.create!(user_id: 1, choice_id: 7)
Response.create!(user_id: 1, choice_id: 12)
Response.create!(user_id: 2, choice_id: 7)
Response.create!(user_id: 2, choice_id: 11)