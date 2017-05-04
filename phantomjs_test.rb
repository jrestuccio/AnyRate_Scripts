require 'watir'

# declare arguments
ARGV.each do|a|
  puts "Argument: #{a}"
end

property_code = ARGV[0]
start_date = ARGV[1]
end_date = ARGV[2]
currency = ARGV[3]

begin
  browser = Watir::Browser.new :phantomjs, :args => ['--ssl-protocol=tlsv1']
rescue Exception => e
  puts e
end

begin
  url = "https://www.marriott.com/reservation/availability.mi?propertyCode=#{property_code}&isRateCalendar=false"
  # url = 'https://www.webpagetest.org'
  p url
  browser.goto url
rescue Exception => e
  p e
end
puts browser.title
