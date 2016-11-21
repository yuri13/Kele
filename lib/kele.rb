require 'httparty'
require 'json'
require 'roadmap'

class Kele
	include HTTParty
	include Roadmap
	base_uri "https://www.bloc.io/api/v1"
	attr_accessor :auth_token

	def initialize email, password
		response = self.class.post '/sessions', body: {email: email, password: password}
		if response['auth_token'].nil?
			raise ArgumentError, response['message']
		else
			@auth_token = response['auth_token']
		end
	end

	def get_me
		response = self.class.get '/users/me', headers: {'authorization' => @auth_token}
		JSON.parse(response.body)
	end

  def get_mentor_availability mentor_id
		response = self.class.get "/mentors/#{mentor_id}/student_availability", headers: {'authorization' => @auth_token}
		JSON.parse(response.body)
	end

	def get_messages
		if page_id == -1
			page_id = 1
			response = get_response page_id
			response_array = []
			while !response.parsed_response["items"].empty?
				response_array << JSON.parse(response.body)
				page_id += 1
				response = get_response page_id
			end
			response_array
		else
			response = get_response page_id
			JSON.parse(response.body)
		end
	end

	def create_message(user_id, recipient_id, token, subject, stripped)
        message_data = {body: {user_id: user_id, recipient_id: recipient_id, token: nil, subject: subject, stripped: stripped}, headers: { "authorization" => @auth_token }}
        self.class.post(base_api_endpoint("messages"), message_data)
    end

  def create_submission(checkpoint_id, assignment_branch, assignment_commit_link, comment, enrollment_id)
      submisson_data = {body: {checkpoint_id: checkpoint_id, assignment_branch: assignment_branch, assignment_commit_link: assignment_commit_link, comment: comment, enrollment_id: enrollment_id}, headers: { "authorization" => @auth_token }}
      self.class.post(base_api_endpoint("checkpoint_submissions"), submisson_data)
  end




	private
	def get_response page_id
		self.class.get "/message_threads", headers: {'authorization' => @auth_token}, body: {'page' => page_id.to_s}
	end

	def base_api_endpoint(end_point)
			"https://www.bloc.io/api/v1/#{end_point}"
	end

end
