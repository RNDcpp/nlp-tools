require "websocket-client-simple"
require "net/https"
require "json"
require "yaml"
INSTANCE="mstdn.jp"
CLIENT_NAME='mastodon-app'
CA_FILE=OpenSSL::X509::DEFAULT_CERT_FILE
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

