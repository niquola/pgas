#!/usr/bin/env ruby

require 'faraday'
require 'faraday/request/hmac'

conn = Faraday.new(:url => "http://localhost:9292") do |builder|
  builder.use      Faraday::Request::Hmac, "foobar", {:auth_scheme => 'hmac'}
  builder.response :raise_error
  builder.adapter  :net_http
end

res = conn.get "/databases.json", {}, 'Content-Type' => 'application/json'

puts res.body
