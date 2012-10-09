#!/usr/bin/env ruby

require 'faraday'
require 'faraday/request/hmac'
require 'active_support/json'

conn = Faraday.new(:url => "http://localhost:9292") do |builder|
  builder.use      Faraday::Request::Hmac, 'secret', {
    :auth_scheme => 'HMAC',
    :auth_key => 'TESTKEYID',
    :auth_header_format => '%{auth_scheme} %{auth_key} %{signature}'
  }

  builder.request  :url_encoded
  builder.response :raise_error
  builder.adapter  :net_http
end

# puts '-'*100
# puts conn.get('/databases', {}, 'accept' => 'application/json').body
# puts '-'*100
# puts conn.get('/databases/postgres', {}, 'accept' => 'application/json').body
# puts '-'*100
# puts conn.get('/roles', {}, 'accept' => 'application/json').body
# puts '-'*100
# puts conn.get('/roles/postgres', {}, 'accept' => 'application/json').body
# puts '-'*100

res = conn.post('/databases') do |req|
  req.body = { :database_name => "foo3", :comment => "" }
  req.headers["Accept"] = "application/json"
end

puts res.body
puts '-'*100
