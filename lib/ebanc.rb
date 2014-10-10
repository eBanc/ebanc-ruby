require 'uri'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'json'

module Ebanc
	class APIClient
		def initialize(api_key, gateway_id)
			@api_key = api_key
			@api_version = 2
			@gateway_id = gateway_id
			@server = 'https://gateway' + gateway_id + '.ebanccorp.com'
			@ebanc_url = @server + '/api/v' + @api_version.to_s
			@use_ssl = true
		end
		
		def server=(value)
			@ebanc_url = value + '/api/v' + @api_version.to_s
			@server = value
		end
		
		def server
			@server
		end
		
		def use_ssl=(value)
			@use_ssl = value
		end
		
		def use_ssl
			@use_ssl
		end
		
		def api_version=(value)
			@ebanc_url = @server + '/api/v' + value.to_s
			@api_version = value
		end
		
		def api_version
			@api_version
		end
		
		def customers
			JSON.parse(open(@ebanc_url + '/customers', "Authorization" => "Token token=\"" + @api_key + "\"").read, symbolize_names: true)
		end
		
		def create_customer(customer)
			if customer[:first_name] && customer[:last_name] && customer[:routing_number] && customer[:account_number]
				params = URI.encode_www_form([["first_name", customer[:first_name]], ["last_name", customer[:last_name]], ["routing_number", customer[:routing_number]], ["account_number", customer[:account_number]]])
				
				uri = URI.parse(@ebanc_url + '/customers')
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = @use_ssl
				req = Net::HTTP::Post.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
				req.body = params
				res = https.request(req)
				if res.code == 201
					return res.body
				else
					return false
				end
			else
				return false
			end
		end
		
		def update_customer(customer)
			if customer[:uuid] && customer[:first_name] && customer[:last_name] && customer[:routing_number] && customer[:account_number]
				params = URI.encode_www_form([["first_name", customer[:first_name]], ["last_name", customer[:last_name]], ["routing_number", customer[:routing_number]], ["account_number", customer[:account_number]]])
				
				uri = URI.parse(@ebanc_url + '/customers/' + uuid)
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = @use_ssl
				req = Net::HTTP::Post.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
				req.body = params
				res = https.request(req)
				if res.code == 201
					return res.body
				else
					return false
				end
			else
				return false
			end
		end
		
		def get_customer(uuid)
			JSON.parse(open(@ebanc_url + '/customers/' + uuid, "Authorization" => "Token token=\"" + @api_key + "\"").read, symbolize_names: true)
		end
		
		def transactions
			JSON.parse(open(@ebanc_url + '/transactions', "Authorization" => "Token token=\"" + @api_key + "\"").read, symbolize_names: true)
		end
		
		def create_transaction(customer)
			#if we are creating this transaction by passing in the information
			if customer[:first_name] && customer[:last_name] && customer[:routing_number] && customer[:account_number] && customer[:amount]
				params = URI.encode_www_form([["first_name", customer[:first_name]], ["last_name", customer[:last_name]], ["routing_number", customer[:routing_number]], ["account_number", customer[:account_number]], ["amount", customer[:amount]]])
				
				if customer[:category]
					params = params + '&' + URI.encode_www_form([["category", customer[:category]]])
				end
				
				if customer[:memo]
					params = params + '&' + URI.encode_www_form([["memo", customer[:memo]]])
				end
				
				uri = URI.parse(@ebanc_url + '/customers')
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = @use_ssl
				req = Net::HTTP::Post.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
				req.body = params
				res = https.request(req)
				if res.code == 201
					return res.body
				else
					return false
				end
			else
				return false
			end
		end
		
		def create_transaction_from_customer(customer)
			#if we are creating this transaction by passing in the information
			if customer[:customer_uuid] && customer[:amount]
				params = URI.encode_www_form([["customer_uuid", customer[:customer_uuid]], ["amount", customer[:amount]]])
				params = 'customer_uuid=' + customer[:customer_uuid] + '&amount=' + customer[:amount]
				
				if customer[:category]
					params = params + '&' + URI.encode_www_form([["category", customer[:category]]])
				end
				
				if customer[:memo]
					params = params + '&' + URI.encode_www_form([["memo", customer[:memo]]])
				end
				
				uri = URI.parse(@ebanc_url + '/customers')
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = @use_ssl
				req = Net::HTTP::Post.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
				req.body = params
				res = https.request(req)
				if res.code == 201
					return res.body
				else
					return false
				end
			else
				return false
			end
		end
		
		def get_transaction(uuid)
			JSON.parse(open(@ebanc_url + '/transactions' + uuid, "Authorization" => "Token token=\"" + @api_key + "\"").read, symbolize_names: true)
		end
	end
end