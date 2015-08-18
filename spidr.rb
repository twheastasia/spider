#!/usr/bin/ruby
#
require 'spidr'

#Spidr.start_at('www.baidu.com')
Spidr.site('http://www.nxedu.gov.cn:8080/maile/office/areaoffice.html') do |spider|

  spider.every_url{|url| puts url}
end
