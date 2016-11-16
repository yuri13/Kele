require 'httparty'
require 'json'

class Kele
	include HTTParty
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
end
