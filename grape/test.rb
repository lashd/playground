require 'httparty'
require 'json'

puts HTTParty.post("http://application.lashd.cloudfoundry.me/auth", :headers => {"Content-Type" => "application/json"},:body => {credentials:{username:"Bruce", password:"Arkham"}}.to_json).body