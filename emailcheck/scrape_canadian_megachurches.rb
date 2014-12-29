require 'nokogiri'
require 'open-uri'
require 'mysql'

def mysqlwrite(q)
con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
rs = con.query(q)
con.close
end

class ScrapeCandaianMegachurches
  doc = Nokogiri::HTML.parse(open("http://hirr.hartsem.edu/cgi-bin/mega/db.pl?db=default&uid=default&view_records=1&ID=*&sb=4&State=AL")) do |config|
    config.noblanks
  end

  table = doc.xpath('//table/tr[count(td)=7]') #table = data_table.xpath('//table[@class="main"]') # if table has a class

  rows = table.css('tr').map do |row|
    p row.xpath('./td').map(&:text)[0,7].join(',')

    org_name = row.xpath('./td').map(&:text)[0]
    org_locality = row.xpath('./td').map(&:text)[3]
    state = row.xpath('./td').map(&:text)[4]
    www = row.xpath('./td/b/a/@href')
  q = "insert into organisations.churchca values('','#{www}','#{org_name}','','','','','','#{org_locality}','#{org_locality}','#{state}','','',NOW())"
p q
#mysqlwrite(q)

  end
end
