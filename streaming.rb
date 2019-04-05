require 'yaml'
require 'net/https'
require 'websocket-client-simple'
require 'json'
class WebSocketResponseTimeError < StandardError; end

INSTANCE="mstdn.jp"
token=YAML.load_file("token.yml")
ACCESS_TOKEN=token["access_token"]
url="https://#{INSTANCE}/api/v1/streaming?access_token=#{ACCESS_TOKEN}&stream=public"
begin
  $time=0
  File.open("dataset.txt","a") do |output|
    begin 
      ws = WebSocket::Client::Simple.connect(url)
    rescue => e
      puts "#{e}"
    else
      ws.on :message do |msg|
        $time=0
        puts "!message"
        data=JSON.parse(msg.data)
        if data["event"]=="update"
          status=JSON.parse(data["payload"])
          account=status["account"]
          puts "#{account["display_name"]}@#{account["username"]}:"
          puts status["content"]
          puts account["id"]
          output.write("<toot><user>#{account["id"]}</user><text>#{status["content"]}</text></toot>\n")
        end
      end

      ws.on :open do
        $time=0
        puts "streaming open"
      end

      ws.on :close do |e|
        $time=0
        puts "close"
        p e
        exit 1
      end

      ws.on :error do |e|
        $time=0
        puts "error"
        p e
      end
    end
    loop do
      sleep 1
      raise WebSocketResponseTimeError if $time > 120
      puts "time#{$time}"
      $time+=1
    end
  end
rescue WebSocketResponseTimeError => e
  puts "time limit"
  retry
end
