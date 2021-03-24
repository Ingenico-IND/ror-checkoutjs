class ApplicationController < ActionController::Base
	require 'json'
	require 'net/http'
	require 'socket'
	protect_from_forgery with: :exception

	def call_api(url, data)
			uri = URI(url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
			request.body = data
			response = http.request(request)
			return response
		end
	
end


