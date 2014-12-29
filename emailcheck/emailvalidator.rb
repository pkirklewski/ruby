require 'mysql'
require 'email_verifier'

con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','churches')
query="select id,www from churches.us where www NOT like 'NULL'"
rs = con.query(query)
con.close
b = Array.new

rs.each_hash {|h|

  #puts "loop:#{h}"

id = h['id']
www = h['www']
  www = www.sub('http://','')
  www = www.sub('www.','')
  #uts www

if www == "anchorageuuf.org"
  next
end

  a = ['sfdsfuh','info','contact','contactus','pastor','office','youth','board','prayer','pray']

if !b.include?(www)

  emails = ""

 (0..a.length-1).each { |i|
   email = "#{a[i]}@#{www}"

#puts email

      begin

          if EmailVerifier.check(email)

                 if email.include?("sfdsfuh")
                   email = "info@#{www}"
                   #puts b.length
                   b[b.length] = www

                   emails = email
                   #puts "#{emails} #{id}"

=begin
                   (0..b.length-1).each{ |x|
                     puts "#{x} #{b[x]}"
                   }
=end

                   break
                 else

                      if !b.include?(www)
                        b[b.length] = www
                      end

                      if emails.length < 1 # If first email then no delimiter needed
                        emails = "#{email}"
                      else
                        emails = emails + ";" + email # If not a fist email then delimiter needed
                      end


                      #puts b.length

                 end

           end

      rescue

      end

}
  if !emails.empty?
    puts "#{emails}"
    qinsert = "UPDATE churches.uswwww  SET email_generated='#{emails}' where id=#{id}"
    #puts qinsert
    rs = con.query(qinsert)
  end

else
  #puts "b already includes #{www}"
end
}

con.close
