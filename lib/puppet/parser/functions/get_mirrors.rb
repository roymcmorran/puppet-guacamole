require 'rest-client'
require 'json'
module Puppet::Parser::Functions
  newfunction(:get_mirrors, :type => :rvalue) do
    url = 'https://www.apache.org/dyn/closer.cgi?as_json=1'
    res = RestClient.get(url)
    data = JSON.parse(res.body)
    data['preferred']
   end
end