#!/usr/bin/env ruby

require 'faraday'
require 'faraday/request/hmac'

conn = Faraday.new(:url => "http://localhost:9292") do |builder|
  builder.use      Faraday::Request::Hmac, 'secret', {
    :auth_scheme => 'HMAC',
    :auth_key => 'TESTKEYID',
    :auth_header_format => '%{auth_scheme} %{auth_key} %{signature}'
  }
  builder.response :raise_error
  builder.adapter  :net_http
end

puts '-'*100
puts conn.get('/databases', {}, 'accept' => 'application/json').body
puts '-'*100
puts conn.get('/databases/postgres', {}, 'accept' => 'application/json').body
puts '-'*100
puts conn.get('/roles', {}, 'accept' => 'application/json').body
puts '-'*100
puts conn.get('/roles/postgres', {}, 'accept' => 'application/json').body
puts '-'*100
