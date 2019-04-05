require "twitter"
require "dotenv"
Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
end
def get_reply_seriese(client,rid,level=0)
  return [] if rid.nil? or level>30
  sleep 1
  ary=[]
  rstatus=client.status(rid)
  ary.push(rstatus)
  return ary+get_reply_seriese(client,rstatus.in_reply_to_status_id,level+1)
end
max_id=open("MAX_ID","r").read.to_i
min_id=max_id
File.open("dataset.dat","a") do |output|
  loop do
  client.search("@ -rt", lang: "ja").each do |status|
    rid = status.in_reply_to_status_id
    unless rid.nil?
      if min_id > status.id
        puts("STOP")
        sleep 3000
        exit
      end
      if max_id < status.id
        max_id=status.id
        File.open("MAX_ID","w") do |f|
          f.write(max_id.to_s)
        end
      end
      p rid
      begin
        rstatus = client.status(rid)   
        ary=[]
        ary<<status
        ary=ary.concat(get_reply_seriese(client,rid))
        ary.reverse!
      rescue Twitter::Error::TooManyRequests => error
        puts error
        puts error.rate_limit.reset_in
        sleep error.rate_limit.reset_in
        retry
      rescue => e
        if e
        puts e
        end
      else
        puts "--------------"
        output.write("<seriese>\n")
        ary.each do |status|
          text=status.text.gsub(/@\w+/,'')
          output.write("<text>#{text}</test>\n")
          puts text
          puts "<<"
        end
        output.write("</seriese>\n")
      end
    end
  end
  print("wait...")
  sleep 6000
  end
end
