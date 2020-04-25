require 'httparty'
require 'nokogiri'
require 'terminal-table'

class JobCount
  attr_reader :count, :lang, :city, :state, :radius
  def initialize(lang = '', city = '', state = '', radius='')
    @lang = CGI.escape(lang) #escape string for URL transportation
    @city = city
    @state = state
    @radius = radius
    doc = HTTParty.post("https://indeed.com/jobs?q=#{@lang}&l=#{@city}%2C+#{@state}&radius=#{@radius}")
    @count = Nokogiri::HTML(doc).css("#searchCountPages").inner_html.split(' ')[-2] || 0
  end

  def lang
    CGI.unescape(@lang)
  end
end

class Results
  attr_accessor :rows
  def initialize(rows=[])
    @rows = rows
  end

  def add_row(*row)
    @rows << Array(row)
  end

  def generate
    @table = Terminal::Table.new :title => "Job Results", :headings => ["Language", "Count"], :rows => @rows
  end

  def show
    puts @table
  end
end

def get_user_input
  r = Results.new
  loop do
    puts "Enter programming language: "
    lang = gets.chomp
    puts "Enter city: "
    city = gets.chomp
    puts "Enter State: "
    state = gets.chomp
    count = JobCount.new(lang,city,state)
    r.add_row(count.lang,count.count)

    puts "More entries?"
    ans = gets.chomp.downcase
    break if ans == 'n'|| ans == 'no'
  end
  r.generate
  r.show
end

get_user_input
