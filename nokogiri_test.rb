#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

html = 'http://www.nxedu.gov.cn:8080/maile/office/areaoffice.html'
@info = []

@page = Nokogiri::HTML(open(html), nil, 'UTF-8')
#puts page
@table = @page.xpath('//*[@id="page-form"]/div[2]/div[2]/table')
@page.xpath('//*[@id="009001"]/div').each do |link|
  puts 'in each do'
end

@page.xpath('//*[@id="page-form"]/div[2]/div[2]/table/tr').each do |row|
  puts row
  row.xpath()
end

