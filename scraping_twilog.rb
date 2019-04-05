# coding: utf-8
require 'open-uri'
require 'nokogiri'
require 'natto'
require 'sqlite3'
#db = SQLite3::Database.new("../db/#{ARGV[0]}.db")
module HTMLParser
  class << self
    def check_url(url)
      begin
        Kernel.sleep(0.1)
        url=URI.encode(url)
        url=URI.parse(url)
        open(url,'User-Agent'=>'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)') 
        #open("http://twilog.org/patioglass/1") 
      rescue => e
        puts "#{e.backtrace}"
        puts "#{e.class.name}:#{e.message}"
      end
    end
    def get_document(url)
      Kernel.sleep(0.1)
      url=URI.encode(url)
      url=URI.parse(url)
      html=open(url,'User-Agent'=>'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)'){|f| f.read} 
      Nokogiri::HTML.parse(html,nil,'UTF-8')
    end
  end
end

module TwilogParser
  class << self 
    def get_status_list(screen_name,limit,&block)
      posts = Array.new
      limit.times do |i|
        doc=HTMLParser.get_document("http://twilog.org/#{screen_name}/#{i+1}")
        doc.xpath('//*[@class = "tl-text"]').each do |t|
          block.call(posts,t.text)
        end
        Kernel.sleep(20)
      end
      return posts
    end
    def get_words(screen_name,limit)
      nat = Natto::MeCab.new
      get_status_list(screen_name,limit) do |ary,txt|
        txt.gsub!(/@\w+/,"")
        txt.gsub!(/(http|https):\/\/([\w]+\.)+[\w]+(\/[\w\.\/?%&=]*)?/,"")
        puts txt
        nat.parse(txt) do |word|
          #if (word.surface =~ /\S+/)and (word.surface !~ /(@.*|_.*|\..*|\/.*|:.*|\(.*|\/.*|\).*|#.*|%.*|\s)/)and((word.surface.length != 1)or(word.surface !~ /[0-9]|[a-z]|[A-Z]|[あ-ん]|[ア-ン]/)) and (word.feature =~ /(名詞|形容詞|動詞|形容動詞)/) and word.surface.length < 8
              puts word.surface
              ary << word.surface
          #end
        end
      end
    end
  end
end

#filter

TwilogParser.get_words(ARGV[0],ARGV[1].to_i).each do |t|
  puts t
end
#end
#words.each do |word,num|
#  puts "#{word}:#{words[word]}"
#  {
#  "#{word}" => num,
#  }.each do |pair|
#    db.execute "insert into pword values ( ?, ? )", pair
#  end
#end
#db.execute "insert into wcount values (?)",wc
#db.execute( "select * from pword order by num asc" ) do |row|
#  p row
#end
#db.execute( "select * from wcount" ) do |row|
#  p row
#end

