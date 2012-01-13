# WHOIS lookup and domain availability via RoboWhois.
# http://www.robowhois.com/
#
# Requires the following environment variables:
# - ROBOWHOIS_API_KEY
#
# robowhois? - Loaded!.
# [robo]whois account - Gets account details.
# [robo]whois <domain.ext> - Gets domain WHOIS summary.
# [robo]whois r[ecord] <domain.ext> - Gets domain WHOIS record.
# [robo]whois p[roperties] <domain.ext> - Gets domain WHOIS properties as JSON.
# [robo]whois a[vailability] <domain.ext> - Gets domain WHOIS availability as JSON.

module.exports = (robot) ->

  robot.hear /robowhois\?$/i, (msg) ->
    msg.send "Loaded!"


  robot.hear /(?:robo)?whois account$/i, (msg) ->
    request msg, "/account", (content) ->
      account = content.account

      output  = "#{account.email}"
      output += if account.credits? then " (#{account.credits_remaining} credits)" else " (unknown plan)"
      msg.send output


  robot.hear /(?:robo)?whois ([a-z0-9-]+\.[a-z0-9-]+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/properties", (content) ->
      properties = content.response.properties

      msg.send "Whois for #{domain} (#{content.response.daystamp})"
      output  = if properties["registered?"]
                  s = "The domain is registered."
                  if properties["created_on"]
                    s += "\nCreated on: #{new Date(properties["created_on"]).toDateString()}"
                  if properties["expires_on"]
                    s += "\nExpires on: #{new Date(properties["created_on"]).toDateString()}"
                  if properties["registrar"]
                    r  = properties["registrar"]
                    s += "\nRegistrar: #{r.name or r.organization} (#{r.id})"
                  if !properties["registrant_contacts"].length == 0
                    r  = properties["registrant_contacts"][0]
                    s += "\nRegistrant: #{r.name or r.organization} (#{r.id})"
                  s
                else if properties["available?"]
                  "The domain is available."
                else if !properties["registered?"] and !properties["available?"]
                  "The domain can't be registered."
      msg.send output


  robot.hear /(?:robo)?whois r(?:ecord)? (.+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/record", (content) ->
      response = content.response

      msg.send "Whois record for #{domain} (#{content.response.daystamp})"
      msg.send response.record


  robot.hear /(?:robo)?whois p(?:roperties)? (.+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/properties", (content) ->
      properties = content.response.properties

      msg.send "Whois properties for #{domain} (#{content.response.daystamp})"
      msg.send prettyPrint(properties)


  robot.hear /(?:robo)?whois a(?:vailability)? (.+)/i, (msg) ->
    domain = msg.match[1]
    request msg, "/whois/#{domain}/availability", (content) ->
      properties = content.response # .properties ?!?

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

