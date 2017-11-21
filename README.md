Ruby bindings for the eBanc API
===============================

Installation
------------

Ebanc Ruby bindings are available as a gem, to install it just install the gem:

    gem install ebanc

If you're using Bundler, add the gem to Gemfile.

    gem 'ebanc'
Run `bundle install`.

Requirements
------------

* Ruby 1.9.3 or above.
* uri, open-uri, net/http, net/https, json

Usage
-----

#### Initalize

You initalize the API client in the following way:

    require 'ebanc'

    api_key = 'keykeykey'
    gateway_id = 'gatewayid'

    ebanc = Ebanc.new(api_key, gateway_id)


#### Customers

Get a list of all this account's customers

    customers = ebanc.customers

Get a specific customer's details:

    ebanc.customer('73607e90-2bdb-0132-80aa-1040f38cff7c')

Create a customer and get the uuid:

    customer = ebanc.create_customer(first_name: 'Billy', last_name: 'Bob', account_number: '123456', routing_number: '123456789')

    if customer
        puts 'Created custoemr' + customer['first_name'] + ' ' + customer['last_name'] + ' with the UUID of ' + customer['uuid']
    else
        puts ebanc.error
    end

Update a customer:

    #Update only the required fields first_name and last_name
    customer = ebanc.update_customer(uuid: '73607e90-2bdb-0132-80aa-1040f38cff7c',first_name: 'Billy', last_name: 'Bob')

    #Making updates to the account and routing numbers is optional
    customer = ebanc.update_customer(uuid: '73607e90-2bdb-0132-80aa-1040f38cff7c',first_name: 'Billy', last_name: 'Bob', account_number: '123456', routing_number: '123456789')

    if customer
        puts 'Created custoemr' + customer['first_name'] + ' ' + customer['last_name'] + ' with the UUID of ' + customer['uuid']
    else
        puts ebanc.error
    end


#### Transactions

Get a list of all this account's last 50 transactions

    ebanc = Ebanc.new(api_key, gateway_id)
    transactions = ebanc.transactions

Get a the latest information about a specific transaction

    ebanc = Ebanc.new(api_key, gateway_id)
    transaction = ebanc.transaction('73607e90-2bdb-0132-80aa-1040f38cff7c')

##### Creating Transactions

When creating a transaction you can either pass in all customer details or simply pass in the uuid for an already created customer. Sometimes it makes sense to just pass in all of the details. This is usually in the case of a single transaction. Other times it makes more sense to store the customer details and just store that uuid on your server to pass in at payment time. This is a good approch when you will have returning customers or need to setup some kind of a schedule, but don't want to store that sensitive information on your server.

Create Transaction by passing in all details.

    transaction = ebanc.create_transaction(first_name: 'Billy', last_name: 'Bob', account_number: '123456', routing_number: '123456789', amount: '$500.00')

    if transaction
        puts 'Created transaction ' + transaction['first_name'] + ' ' + transaction['last_name'] + ' with the UUID of ' + transaction['uuid']
    else
        puts ebanc.error
    end

###### Types, Categories and, Memos

Transaction type can be a debit or credit. If you do not pass in a transaction type, debit is defaulted.

A category and memo can be used together or seperate to help you with reporting later. The category helps group transaction types together (Example: "Online orders" and "In-store orders"). The memo helps discribe that specific transaction (Example: Put in the ID number of order from your eCommerce or POS system to tie that transaction to the correct order).

Create Transaction by passing in all details and optional category and/or memo:

    first_name       = 'Steve'
    last_name        = 'Bobs'
    routing_number   = '123456789'
    account_number   = '123456'
    amount           = '150.92'
    transaction_type = 'debit'
    category         = 'Online Orders'
    memo             = 'Order# 1234'
    
    transaction = ebanc.create_transaction(first_name: first_name, last_name: last_name, account_number: account_number, routing_number: routing_number, amount: amount, type: transaction_type, category: category, memo: memo)
    
    if transaction
      puts 'Transaction for ' + transaction['amount'] + ' with the UUID of ' + transaction['uuid'] + ' was created'
    else
      puts ebanc.error
    end

###### Customer UUID

Create Transaction by passing in customer UUID:

    uuid   = '03ae8670-27d3-0132-54de-1040f38cff7c'
    amount = '51.50'
    
    transaction = ebanc.createTransactionForCustomer(uuid, amount)
    
    if transaction
      puts 'Transaction for ' + transaction['amount'] + ' with the UUID of ' + transaction['uuid'] + ' was created'
    else
      puts ebanc.error
    end

Create Transaction by passing in customer UUID and optional type, category and/or memo:

    uuid              = '03ae8670-27d3-0132-54de-1040f38cff7c'
    amount            = '51.50'
    transaction_ type = 'debit'
    $category         = 'Online Orders'
    $memo             = 'Order# 1234'
    
    transaction = ebanc.createTransactionForCustomer(uuid: uuid, amount: amount, type: transaction_type, category: category, memo: memo)
    
    if transaction
      puts 'Transaction for ' + transaction['amount'] + ' with the UUID of ' + transaction['uuid'] + ' was created'
    else
      puts ebanc.error
    end
