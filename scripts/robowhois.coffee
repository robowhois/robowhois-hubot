# Description:
#   WHOIS lookup and domain availability via RoboWhois
#
# Dependencies:
#   None
#
# Configuration:
#   ROBOWHOIS_API_KEY
#
# Commands:
#   hubot robowhois? - Loaded!.
#   hubot [robo]whois account - Gets account details.
#   hubot [robo]whois <domain.ext> - Gets domain WHOIS summary.
#   hubot [robo]whois record <domain.ext> - Gets domain WHOIS record.
#   hubot [robo]whois properties <domain.ext> - Gets domain WHOIS properties as JSON.
#
# Notes:
#   None
#
# Author:
#   Simone Carletti <weppos@weppos.net> (http://www.simonecarletti.com/)

module.exports = (robot) ->

  robot.respond /robowhois\?$/i, (msg) ->
    msg.send "Loaded!"


  robot.respond /(?:robo)?whois account$/i, (msg) ->
    request msg, "/account", (content) ->
      account = content.account

      output  = "#{account.email}"
      output += if account.credits? then " (#{account.credits_remaining} credits)" else " (unknown plan)"
      msg.send output


  robot.respond /(?:robo)?whois ([a-z0-9-]+\.[a-z0-9-]+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/properties", (content) ->
      properties = content.response.properties

      msg.send "Whois for #{domain} (#{content.response.daystamp})"
      output  = if properties["registered?"]
                  s = "The domain is registered."
                  if properties["created_on"]
                    s += "\nCreated on: #{new Date(properties["created_on"]).toDateString()}"
                  if properties["expires_on"]
                    s += "\nExpires on: #{new Date(properties["expires_on"]).toDateString()}"
                  if properties["registrar"]
                    r  = properties["registrar"]
                    s += "\nRegistrar: #{r.name or r.organization}"
                    s += " (#{r.id})" if r.id?
                  contacts = properties["registrant_contacts"]
                  if contacts? && contacts.length > 0
                    r  = properties["registrant_contacts"][0]
                    s += "\nRegistrant: #{r.name or r.organization}"
                    s += " (#{r.id})" if r.id?
                  s
                else if properties["available?"]
                  "The domain is available."
                else if !properties["registered?"] and !properties["available?"]
                  "The domain can't be registered."
      msg.send output


  robot.respond /(?:robo)?whois record (.+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/record", (content) ->
      response = content.response

      msg.send "Whois record for #{domain} (#{content.response.daystamp})"
      msg.send response.record


  robot.respond /(?:robo)?whois properties (.+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/properties", (content) ->
      properties = content.response.properties

      msg.send "Whois properties for #{domain} (#{content.response.daystamp})"
      msg.send prettyPrint(properties)


request = (msg, path, callback) ->
  apiKey = process.env.ROBOWHOIS_API_KEY
  auth   = new Buffer("#{apiKey}:X").toString("base64");

  msg.http("http://api.robowhois.com#{path}")
    .headers(Authorization: "Basic #{auth}", Accept: "application/json")
    .headers('User-Agent': 'Hubot')
    .get() (err, res, body) ->
      content = JSON.parse(body)
      if res.statusCode != 200
        msg.send "Error: #{content.error.name}"
        return
      else
        callback content

prettyPrint = (json) ->
  JSON.stringify(json, null, 4)
