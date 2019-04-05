require 'yaml'
require 'net/https'
require 'websocket-client-simple'
require 'json'
INSTANCE="mstdn.jp"
token=YAML.load_file("token.yml")
ACCESS_TOKEN=token["access_token"]
CLIENT_NAME='mastodon-app'
CA_FILE=OpenSSL::X509::DEFAULT_CERT_FILE
INSTANCE="mstdn.jp"
CLIENT_NAME='rnd_client'

def get_toot_list(uid,&block)
  https=Net::HTTP.new(INSTANCE,443)
  https.use_ssl=true
  https.ca_file=CA_FILE
  https.verify_mode=OpenSSL::SSL::VERIFY_PEER
  https.verify_depth=5
  max_id=nil
  loop do 
    if max_id 
      req=Net::HTTP::Get.new("/api/v1/search?q=rakugaki")
    else
      req=Net::HTTP::Get.new("/api/v1/search?q=rakugaki")
    end
    req["Authorization"]="Bearer #{ACCESS_TOKEN}"
    resp=https.request(req)
    puts resp
    data=JSON.parse(resp.body)
    break if data.length==0
    data.each do |status|
      yield [status,https]
      max_id=status["id"]
    end
    sleep 5
  end
end
get_toot_list(334003) do |s|
  status=s[0]
  https=s[1]
  puts status["content"]
  if rid=status["in_reply_to_id"]
    req=Net::HTTP::Get.new("/api/v1/statuses/#{rid}")
    req["Authorization"]="Bearer #{ACCESS_TOKEN}"
    resp=https.request(req)
    rstatus=JSON.parse(resp.body)
    puts rstatus["content"]
    puts status["content"]
  end
end
