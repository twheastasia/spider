#!/usr/bin/ruby

require 'mechanize'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'CSV'
require 'find'

html = 'http://www.nxedu.gov.cn:8080/maile/office/areaoffice.html'
@agent = Mechanize.new

#process table cell into an array 
def getTableCells tableTr, area
  details = tableTr.collect do |row|
    detail = {}
      [
        ["id", 'td[1]/text()'],
        ["school_name", 'td[2]/text()'],
        ["school_address", 'td[3]/text()'],
        ["school_type", 'td[4]/text()'],
        ["school_url", 'td[5]/a/text()'],
      ].each do |name , xpath|
        detail[name] = row.at_xpath(xpath).to_s.strip
      end
      detail["school_area"] = area
      detail
    end
    details.each do |eachRecord|
    details.delete_if{|y| y["id"] == ""}
  end
  return details
end

#generate a csv file which include schools' info
def generateCSV data
  CSV.open("schools.csv", "wb") do |csv|
    csv << [ "school_name", "school_address", "school_type", "school_url", "school_area"]
    data.each do |cell|
      csv << [ cell["school_name"], cell["school_address"], cell["school_type"], cell["school_url"], cell["school_area"]]
    end
  end
end

#get table info from web (open a url)
def getTable url
  page = Nokogiri::HTML(open(url), nil, 'UTF-8')
  tableTr = page.xpath('//*[@id="page-form"]/div[2]/div[2]/table//tr')
  return tableTr
end

#load from loacl file
def getTableFromLocalHtml fileName
  f = File.open(fileName)
  doc = Nokogiri::HTML(f, nil, 'utf-8')
  f.close
  tableTr = doc.xpath('//*[@id="page-form"]/div[2]/div[2]/table//tr')
  return tableTr
end

#load html file from local (a reserve way)
def loadLocalHtml 
  details = []
  Dir.glob('./htmls/*') do |file|
    tableTr = getTableFromLocalHtml(file)
    puts file
    detail = getTableCells(tableTr, File.basename(file).sub(".html",""))
    details += detail
  end
  generateCSV(details)
end

#@tableTr = getTableFromLocalHtml("2.html")
#@tableTr = getTable(html)
#details = getTableCells(@tableTr, "ningxia")
#generateCSV(details)
#
loadLocalHtml
