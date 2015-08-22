#!/usr/bin/ruby

require 'rubygems'
require 'watir'
require 'watir-webdriver'
require 'CSV'

#url to be tested
HTML = 'http://www.nxedu.gov.cn:8080/maile/office/areaoffice.html'
@allrows = []    #the final result 
#xpath
KINDGARDEN_XPATH = '//*[@id="search-box-center"]/table/tbody/tr[1]/td[4]/div/ul/li[2]'
PRIMARY_SCHOOL_XPATH = '//*[@id="search-box-center"]/table/tbody/tr[1]/td[4]/div/ul/li[3]'
JUNIOR_SCHOOL_XPATH = '//*[@id="search-box-center"]/table/tbody/tr[1]/td[4]/div/ul/li[4]'
#html element id of city and distinct 
CITY_DISTINCT_ARRAY = [
                       {"city_id" => "009001", "distinct_id" => [""]},
                       {"city_id" => "009002", "distinct_id" => ["009002001", "009002002", "009002003", "009002004", "009002005", "009002006", "009002007"]},
                       {"city_id" => "009003", "distinct_id" => ["009003001", "009003002", "009003003", "009003004"]},
                       {"city_id" => "009004", "distinct_id" => ["009004001", "009004002", "009004003", "009004004", "009004005", "009004006"]},
                       {"city_id" => "009005", "distinct_id" => ["009005001", "009005002", "009005003", "009005004", "009005005", "009005006"]},
                       {"city_id" => "009006", "distinct_id" => ["009006001", "009006002", "009006003", "009006004"]},
                       {"city_id" => "009007", "distinct_id" => [""]}
]

#grab data from table
def collectSchoolInfoFromTable browser, province, city, distinct
  sleep 1
  details = []
  browser.table(:class, "result-table").rows.each do |row|
    if(row.[](1).exists?)
      detail = {}
      # puts row.[](1).text
      detail["school_name"] = row.[](1).text
      detail["school_address"] = row.[](2).text
      detail["school_type"] = row.[](3).text
      detail["school_url"] = row.[](4).text
      detail["school_province"] = province
      detail["school_city"] = city
      detail["school_distinct"] = distinct
      details.push detail
    end
  end
  details.shift
  puts details
  @allrows += details
end

#click some html element to get result table, just like a man is handling the website
def searchSchoolTalbes cityId, distinctId, schoolTypeXpath
  #click distinct 
  if distinctId != ""
    distinct_name = @browser.li(:id, distinctId).text
  else
    distinct_name = ""
  end
  #choose a school type
  sleep 2
  @browser.div(:class, "cls-combox").click
  sleep 2
  @browser.li(:xpath, schoolTypeXpath).click
  sleep 1
  #query
  @browser.button(:id, "btn_query").click
  sleep 3

  city_name = @browser.li(:id, cityId).text

  #get new data which is in the next page 
  collectSchoolInfoFromTable @browser, "宁夏回族自治区", city_name, distinct_name
  pageNumber = @browser.span(:xpath, '//*[@id="page-form"]/div[2]/div[3]/div[1]/span[2]').text
  nextPage = pageNumber.split("/")[0].to_i / pageNumber.split("/")[1].to_i
  sleep 5
  begin
    @browser.link(:xpath, '//*[@id="page-form"]/div[2]/div[3]/div[2]/a[3]').click
    sleep 5
    collectSchoolInfoFromTable @browser,  "宁夏回族自治区", city_name, distinct_name
    pageNumber = @browser.span(:xpath, '//*[@id="page-form"]/div[2]/div[3]/div[1]/span[2]').text
    nextPage = pageNumber.split("/")[0].to_i / pageNumber.split("/")[1].to_i
  end while nextPage < 1
end

def searchSchoolThreeTypes cityId, distinctId
  #click city 
  sleep 2
  @browser.li(:id, cityId).click
  sleep 2
  #click distinct 
  if distinctId != ""
    @browser.li(:id, distinctId).click
    sleep 2
  end

  searchSchoolTalbes cityId, distinctId, KINDGARDEN_XPATH
  searchSchoolTalbes cityId, distinctId, PRIMARY_SCHOOL_XPATH
  searchSchoolTalbes cityId, distinctId, JUNIOR_SCHOOL_XPATH
end

#generate a csv file which include schools' info
def generateCSV data
  CSV.open("schools_form_watir.csv", "wb") do |csv|
    csv << [ "school_name", "school_address", "school_type", "school_url", "school_province", "school_city", "school_distinct"]
    data.each do |cell|
      csv << [ cell["school_name"], cell["school_address"], cell["school_type"], cell["school_url"], cell["school_province"], cell["school_city"], cell["school_distinct"]]
    end
  end
  puts "Done!"
end


@browser = Watir::Browser.new :chrome
@browser.goto HTML

CITY_DISTINCT_ARRAY.each do |data|
  data["distinct_id"].each do |cell|
    searchSchoolThreeTypes data["city_id"], cell
  end
end

generateCSV @allrows
