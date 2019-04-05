require "yaml"
require 'io/console'
require "net/https"
require "json"
require 'launchy'
CLIENT_NAME='mastodon-app'
CA_FILE=OpenSSL::X509::DEFAULT_CERT_FILE
INSTANCE="mstdn.jp"
CLIENT_NAME='rnd_client'

def get_client_id
  https=Net::HTTP.new(INSTANCE,443)
  https.use_ssl=true
  https.ca_file=CA_FILE
  https.verify_mode=OpenSSL::SSL::VERIFY_PEER
  https.verify_depth=5
  req=Net::HTTP::Post.new('/api/v1/apps')
  req.set_form_data({client_name: CLIENT_NAME,
               redirect_uris: 'urn:ietf:wg:oauth:2.0:oob',
               scopes: 'read write follow',})
  resp=https.request(req)
  p resp.body
  data=JSON.parse(resp.body)
  p data
  YAML.dump(data,File.open("client.yml",'w'))
  return data
end

#client=YAML.load_file("client.yml")
client=get_client_id()
CLIENT_ID=client["client_id"]
CLIENT_SECRET=client["client_secret"]
p CLIENT_ID
p CLIENT_SECRET
https=Net::HTTP.new(INSTANCE,443)
https.use_ssl=true
https.ca_file=CA_FILE
https.verify_mode=OpenSSL::SSL::VERIFY_PEER
https.verify_depth=5
Launchy.open "https://#{INSTANCE}/oauth/authorize?scope=read+write+follow&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&client_id=#{CLIENT_ID}"
print "paste the code :"
code=gets.chomp!

req=Net::HTTP::Post.new("/oauth/token")
req.set_form_data({
  grant_type: 'authorization_code',
  redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  code: code
})
resp=https.request(req)
p resp.body
data=JSON.parse(resp.body)
p data
YAML.dump(data,File.open('token.yml','w'))

