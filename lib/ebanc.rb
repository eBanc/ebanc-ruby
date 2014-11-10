require 'uri'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'json'

class Ebanc
	def initialize(api_key, gateway_id)
		@api_key = api_key
		@api_version = 2
		@gateway_id = gateway_id
		@server = 'https://' + gateway_id + '.ebanccorp.com'
		@ebanc_url = @server + '/api/v' + @api_version.to_s
		@use_ssl = true
		@error_message = ''
	end
	
	# Class Getters and Setters
	
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
	
	def error
		@error_message
	end
	
	#--------------------------------
	# API endpoints
	#--------------------------------
	
	# Customers
	def customers
		m_customers = query_api(@ebanc_url + '/customers')
		
		if m_customers['customers'].length == 0
			@error_message = 'No customers found'
		end
		
		m_customers['customers']
	end
	
	def create_customer(customer = {})
		if customer[:first_name] && customer[:last_name] && customer[:routing_number] && customer[:account_number]
			params = URI.encode_www_form([["first_name", customer[:first_name]], ["last_name", customer[:last_name]], ["routing_number", customer[:routing_number]], ["account_number", customer[:account_number]]])
			
			customer = query_api(@ebanc_url + '/customers', 'post', params)
			
			if customer['base']
				@error_message = customer['base'].first
				return false
			else
				return customer
			end
		else
			@error_message = 'Not all needed fields were included'
			return false
		end
	end
	
	def update_customer(customer = {})
		if customer[:uuid] && customer[:first_name] && customer[:last_name]
			params = URI.encode_www_form([["first_name", customer[:first_name]], ["last_name", customer[:last_name]], ["routing_number", customer[:routing_number]], ["account_number", customer[:account_number]]])
			
			if customer[:routing_number]
				params = params + '&' + URI.encode_www_form([["routing_number", customer[:routing_number]]])
			end
			
			if customer[:account_number]
				params = params + '&' + URI.encode_www_form([["account_number", customer[:account_number]]])
			end
			
			if customer(customer[:uuid])
				customer = query_api(@ebanc_url + '/customers/' + customer[:uuid], 'patch', params)
				return customer
			else
				return false
			end
		else
			@error_message = 'Not all needed fields were included'
			return false
		end
	end
	
	def customer(uuid)
		m_customer = query_api(@ebanc_url + '/customers/' + uuid)
		
		if m_customer.length == 0
			@error_message = 'Customer not found'
			return false
		else
			return m_customer
		end
	end
	
	# Transactions
	def transactions
		m_transactions = query_api(@ebanc_url + '/transactions')
		
		if m_transactions['transactions'].length == 0
			@error_message = 'No transactions found'
		end
		
		m_transactions['transactions']
	end
	
	def create_transaction(transaction = {})
		#if we are creating this transaction by passing in the information
		if transaction[:first_name] && transaction[:last_name] && transaction[:routing_number] && transaction[:account_number] && transaction[:amount]
			params = URI.encode_www_form([["first_name", transaction[:first_name]], ["last_name", transaction[:last_name]], ["routing_number", transaction[:routing_number]], ["account_number", transaction[:account_number]], ["amount", transaction[:amount]]])
			
			if transaction[:category]
				params = params + '&' + URI.encode_www_form([["category", transaction[:category]]])
			end
			
			if transaction[:memo]
				params = params + '&' + URI.encode_www_form([["memo", transaction[:memo]]])
			end
			
			if transaction[:type] && transaction[:type] == 'credit'
				params = params + '&' + URI.encode_www_form([["type", 'credit']])
			else
				params = params + '&' + URI.encode_www_form([["type", 'debit']])
			end
			
			m_transation = query_api(@ebanc_url + '/transactions', 'post', params)
			
			if m_transation['base']
				@error_message = m_transation['base'].first
				return false
			else
				return m_transation
			end
		else
			@error_message = 'Not all needed fields were included'
			return false
		end
	end
	
	def create_transaction_from_customer(transaction = {})
		#if we are creating this transaction by passing in the information
		if transaction[:customer_uuid] && transaction[:amount]
			params = URI.encode_www_form([["customer_uuid", transaction[:customer_uuid]], ["amount", transaction[:amount]]])
			params = 'customer_uuid=' + transaction[:customer_uuid] + '&amount=' + transaction[:amount]
			
			if transaction[:category]
				params = params + '&' + URI.encode_www_form([["category", transaction[:category]]])
			end
			
			if transaction[:memo]
				params = params + '&' + URI.encode_www_form([["memo", transaction[:memo]]])
			end
			
			if transaction[:type] && transaction[:type] == 'credit'
				params = params + '&' + URI.encode_www_form([["type", 'credit']])
			else
				params = params + '&' + URI.encode_www_form([["type", 'debit']])
			end
			
			m_transation = query_api(@ebanc_url + '/transactions', 'post', params)
			
			if m_transation['base']
				@error_message = m_transation['base'].first
				return false
			else
				return m_transation
			end
		else
			@error_message = 'Not all needed fields were included'
			return false
		end
	end
	
	def transaction(uuid)
		m_transaction = query_api(@ebanc_url + '/transactions/' + uuid)
		
		if m_transaction.length == 0
			@error_message = 'Transaction not found'
			return false
		else
			return m_transaction
		end
	end
	
	#--------------------------------
	# Utility Methods
	#--------------------------------
	private
	
	def query_api(url, req_type='get', fields=nil)
		@error_message = '';
		
		uri = URI.parse(url)
		https = Net::HTTP.new(uri.host,uri.port)
		https.use_ssl = @use_ssl
		req = nil
		
		if req_type == 'patch'
			req = Net::HTTP::Patch.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
		elsif req_type == 'post'
			req = Net::HTTP::Post.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
		else
			req = Net::HTTP::Get.new(uri.path, initheader = {'Authorization' => "Token token=\"" + @api_key + "\""})
		end
		
		if fields
			req.body = fields
		end
		res = https.request(req)
		
		if res.code == 401
			raise "eBanc API access denied"
		end
		
		JSON.parse res.body
	end
end