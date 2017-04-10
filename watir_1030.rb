require 'rubygems'
require 'mechanize'
# require 'rubygems'
# require 'selenium-webdriver'
require 'watir'
# require 'phantomjs'

# Dependencies / Install Notes
# 1. Must download geckodriver.exe for selenium-webdriver
# 2. Must install Xvfb in order to use Headless Gem

# test params
# ruby watir_1030.rb memca 04/12/2017 04/14/2017 USD
puts "test"

# declare arguments
ARGV.each do|a|
  puts "Argument: #{a}"
end

property_code = ARGV[0]
start_date = ARGV[1]
end_date = ARGV[2]
currency = ARGV[3]

begin
  browser = Watir::Browser.new :phantomjs
rescue Exception => e
  puts e
end

browser.goto "https://www.marriott.com/reservation/availability.mi?propertyCode=#{property_code}&isRateCalendar=false"

browser.text_field(:id, 'fromDate').set(start_date)
browser.text_field(:id, 'toDate').set(end_date)

browser.button(:name => 'btn-submit').click
until browser.div(:class => "room-rate-results").exists? do sleep 1 end

# save html page
File.open('./html/1234.html', 'w') {|f| f.write browser.html }

website_rates_page = browser.text

html_doc = browser.div(:class => "results-container")

if browser.a(:id => 'accordion-link').exists?
  browser.a(:id => 'accordion-link').click
end
# it seems like the page will render 1 of 2 ways. Seperated by room type or rate type.
 # split by room type || # split by rate type  html_doc.divs(:class => 'sub-section-ers') ||
page_by_room_type = html_doc.divs(:class => 'room-rate-results')
page_by_rate_Type = html_doc.divs(:class => 'sub-section-ers')
page_by_room_type ||= page_by_rate_Type
results_per_rate_type = page_by_room_type

all_rate_results = []

results_per_rate_type.each do |r|
  # collect divs of actual rates
  every_result = r.divs(:class => 'rph-row')
  every_result.each do |row|
    # select rate type depending on which page comes up (split by rate type or room type)
    rate_type = if r.h3(:class => 't-bg-lghtstGry l-padding-three-quarters').exists?
        r.h3(:class => 't-bg-lghtstGry l-padding-three-quarters', :index => 0).text
      else
        r.h3(:class => 'description t-description').text
      end # rate_type if statement

    data =
      {
        :rate_type => rate_type,
        :room_type => row.h3(:class => 'description').text,
        :rate => row.div(:class => 't-price').span(:index => 0).text
      }

      all_rate_results << data
  end # every result
end # results_per_rate_type.each

rates_results = File.new("./html/1234.txt", "w+")
all_rate_results.each do |rf|
  rate_results_text = "1234\::1030\::55\::#{start_date}\::1\::#{rf[:rate_type]} - #{rf[:room_type]}\::#{rf[:rate]}\::#{currency}\::SUCC_RTE\n"
  rates_results.puts rate_results_text
end # all_rate_results.each
rates_results.close()
# browser.close
