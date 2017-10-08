require 'net/http'
require 'json'
# Add func
module Puppet::Parser::Functions
  newfunction(:get_mirrors, :type => :rvalue) do |args|
    url = args[0]
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    JSON.parse(data)['preferred']
  end
end
