require 'nokogiri'
require 'open-uri'
require 'mysql'
require 'csv'


def mysqlwrite(q)
  begin


con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
rs = con.query(q)
con.close
  rescue Exception => ex
puts "An error of type #{ex.class} happened arround line 29, message is #{ex.message}"
  end

  end

def mysqlread(q)

  con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
  rs = con.query(q)
  con.close
  return rs
end

class ScrapeUsMegachurches

  q = "select DISTINCT org_state from organisations.churchus where org_state not like 'NULL'"
  rs = mysqlread(q)

  rs.each_hash {|h|
  state =  "#{h['org_state']}"


  doc = Nokogiri::HTML.parse(open("http://hirr.hartsem.edu/cgi-bin/mega/db.pl?db=default&uid=default&view_records=1&ID=*&sb=4&State=#{state}")) do |config|
    config.noblanks
  end

  table = doc.xpath('//table/tr[count(td)=5]')

  rows = table.css('tr').map do |row|
    #p row.xpath('./td').map(&:text)[0,7].join(',')

    org_name = row.xpath('./td').map(&:text)[0].to_s
    org_name = org_name.gsub("\n","")
    org_name = org_name.gsub("\r"," Pastor: ")
    org_name = org_name.gsub("'","")
    org_state = row.xpath('./td').map(&:text)[2].to_s
    org_locality = row.xpath('./td').map(&:text)[1].to_s
    www = row.xpath('./td/b/a/@href')

#p "#{org_name} #{www} #{org_state} #{org_locality}"

    #q = "insert into organisations.churchus values('','#{www}','#{org_name}','','','NULL','','','#{org_locality}','#{org_locality}','#{state}','','','YES',NOW())"
    q = "insert into organisations.churchus(id, www, org_name, org_locality, org_city, org_state, ismegachurch, created_at) values('','#{www}','#{org_name}','#{org_locality}','#{org_locality}','#{state}','YES',NOW())"
    p q
    mysqlwrite(q)
end


  }
 #table = data_table.xpath('//table[@class="main"]') # if table has a class
=begin
  rows = table.css('tr').map do |row|
    p row.xpath('./td').map(&:text)[0,7].join(',')

    org_name = row.xpath('./td').map(&:text)[0]
    org_locality = row.xpath('./td').map(&:text)[3]
    www = row.xpath('./td').map(&:text)[5]
    state = row.xpath('./td').map(&:text)[4]
  q = "insert into organisations.churchca values('','#{www}','#{org_name}','','','','','','#{org_locality}','#{org_locality}','#{state}','','',NOW())"
mysqlwrite(q)

  end
=end
end
