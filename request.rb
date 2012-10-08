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

res = conn.get "/databases.json"#, {}, 'Content-Type' => 'application/json'

puts res.body
