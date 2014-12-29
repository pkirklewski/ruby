require 'mysql'
require 'open-uri'
require 'nokogiri'

#########################################################################################
def mysqlread(q)

  begin
    con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
    rs = con.query(q)
    con.close
    return rs
  rescue
    return false
  end

end
#########################################################################################
def mysqlwrite(q)
  con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
  rs = con.query(q)
  con.close
end
#########################################################################################
def add_array(a,b,domain)

  c = Array.new


  (0..a.length-1).each {|h|

    if !c.include?(a[h]) and a[h].include?(domain) and !a[h].include?('javascript')
      c.insert(c.length,a[h])
    end

  }


  (0..b.length-1).each {|h|

    if !c.include?(b[h]) and b[h].include?(domain) and !b[h].include?('javascript')
      c.insert(c.length,b[h])
    end

  }

  return c

end
#########################################################################################
def gatherlinks(source,domain)
  allinks = Array.new
  allinks.insert(allinks.length,"http://www.#{domain}") # making sure the basic domain is always there

  doc = Nokogiri::HTML.parse(source) do |config|
    config.noblanks
  end


  links = doc.css('a').map { |link| link['href'] }

  # clean the links. Remove anchors and repeating links as well as javascript crap

  (0..links.length-1).each{|h|

      begin
                if !allinks.include?(links[h]) and links[h].include?(domain) and !links[h].include?('javascript')
                  allinks.insert(allinks.length,links[h])
                end

                if links[h].include?('javascript')
                  # clean javascript
                  cleaned_link = links[h]
                  cleaned_link =  cleaned_link[cleaned_link.index('http://'),cleaned_link.length - cleaned_link.index('http')]
                  cleaned_link = cleaned_link[0,cleaned_link.index("'")]

                  allinks.insert(allinks.length,cleaned_link)
                  # end of lean javascript
                end
      rescue
            next
      end

  }
  return allinks
end
#########################################################################################
def sitemap(source)

  if source.index('sitemap')
    b = 'sitemap'
    return b
  end

  if source.index('site-map')
    b = 'site-map'
    return b
  end

  return false
end
#########################################################################################
def cleandomain(www)
  domain = www.gsub('http://','')
  domain = domain.gsub('www.','')
  domain = domain.gsub('/','')
  domain = domain.gsub(':','')
  domain = domain.gsub('#','')
  return domain
end
#########################################################################################

def countwords(source,word)
  number_of_words = 0

  (0..100).each{|i|

    if source.index(word)
      number_of_words += 1
      source = source[source.index(word)+word.length,source.length]
    else
      return number_of_words
    end

  }

 # p "number of words: #{number_of_words}"
  return number_of_words
end

#########################################################################################

def get_email_from_www(id,www)

  domain = cleandomain(www)

  begin # can we do something about the FORBIDDEN redirections ?
    source = open(www).read
  rescue
  end

  links_main_www = gatherlinks(source,domain)

  sitemap_true =  sitemap(source)

  if sitemap_true
    sitemap_link = "http://www.#{domain}/#{sitemap_true}"

    begin
      source = open(sitemap_link).read
      links_sitemap_www = gatherlinks(source,domain)
    rescue
    end

    alllinks = add_array(links_main_www,links_sitemap_www,domain)

  else

    alllinks = links_main_www

  end

  # if there is a link called "staff" then scan this site for additional links too
  #p " alllinks length without staff #{alllinks.length}"
(1..alllinks.length).each {|j|

if alllinks[j].include?('staff')

  #p "j:#{j} v:#{alllinks[j]}"
  www = alllinks[j]
  source = open(www).read

  staffarr = gatherlinks(source,domain)
  alllinks = add_array(alllinks,staffarr,domain)
end

}

#p " alllinks length with staff #{alllinks.length}"

  # End of: if there is a link called "staff" then scan this site for additional links too

  done = Array.new
  emails = ""
  source = ""

 (0..alllinks.length-1).each{|e|

   mywww = "#{alllinks[e]}"

    begin

      timeout(10) do
       source = open(mywww).read.to_s
        #p source

      end

    rescue Exeption => ex
      puts "An error of type #{ex.class} happened arround line 25, message is #{ex.message}"
      next
    end

   howmanyemails = countwords(source,"mailto:")

=begin
if mywww.include?("changepointalaska")

  #p "Checking:#{e} out of: #{alllinks.length}  #{mywww} howmanyemails: #{howmanyemails}"
   if mywww.include?("pastors-and-staff")
     #p "Checking: #{mywww} howmanyemails: #{howmanyemails}"
   end
   end
=end

   if howmanyemails == 0
     next
   end

(1..howmanyemails).each{|m|

     begin
       if source.include?('Terms of use') or source.include?('the site or service will not give, sell, or otherwise transfer addresses maintained')
       p "!!! TERMS OF USE  present !!!!!!!!!!!!! #{id} #{www}"
       end
     if source.include?('the site or service will not give, sell, or otherwise transfer addresses maintained')
       p "!!! CAN-SPAM  present !!!!!!!!!!!!! #{id} #{www}"
     end

   rescue
     next
   end

   if source.include?('mailto:')

      a = source[source.index('mailto:').to_i, 100]
      if a == nil
        next
      else
                if a.include?('@')
                 username = a[7,a.index('@')-7]
                   if username == nil
                     next
                   else
                     if username.include?('.')
                       domain = a[a.index('@'),100]
                       domain = domain[0,domain.index('.')+4]
                       b = "#{username}#{domain}"
                     else
                       b = a[7,a.index('.').to_i-3]
                     end
                  end

                end

                if a.include?('%40')
                    a = a.gsub('%40','@')
                    username = a[7,a.index('@')-7]
                    if username == nil
                      next
                    else
                      if username.include?('.')
                        domain = a[a.index('@'),100]
                        domain = domain[0,domain.index('.')+4]
                        b = "#{username}#{domain}"
                      else
                        b = a[7,a.index('.').to_i-3]
                      end
                    end

                end

      end

      if b != nil

        if b.include?('?')
          b = b[0,b.index('">').to_i-7]
            if b == nil
              next
            end
        end
begin
        if b.include?('target') or b.include?('class')
          b = b[0,b.index('"').to_i]
            if b == nil
              next
            end
        end

rescue
  p "!!! Error ??? line 237"
end
        b = b.gsub('%40','@')

                if done.include?(b) or b.include?('webadmin') or b.include?('admin')  or b.include?('Webmaster')  or b.include?('webmaster')

                else
                  done.insert(e,b)

                  if emails.length > 0

                    begin
                      if !emails.include?(b) # making sure there are no duplictes
                        emails = "#{emails};#{b}"
                      end
                    rescue
                    end

                  else
                    emails = b
                  end

                  #puts "done length: #{done.length}"
                end
      end

   else
    #puts "!!! #{www} - no email found"
   end
if howmanyemails > 1
  start =   source.index("mailto:").to_i+7
  len = source.length - start

  source = source[start,len]

end

} # how many emails
 } # alllinks

   if emails.include?("@") and emails.length >= 6 # Checking if emails contains any email addresses
     puts "id: #{id} len:#{emails.length} emails:#{emails}"
     q = "UPDATE organisations.churchus SET email_www='#{emails}' where id=#{id}"

 mysqlwrite(q)
   end

end

class EmailFromWWW

  q = "SELECT id,www FROM organisations.churchus where www not like 'NULL' and ismegachurch='YES'" #http://www.christcentralchurch.org

  rs = mysqlread(q)

  thread_limit = 40
  threads = []

  rs.each_hash{|h|

    id = h['id']
    www = h['www']

    # get_email_from_www(id,www) # for test only !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    until threads.map {|thr| thr.status}.count("run") < thread_limit do # sleep as long as x < thread limit returns "false"

      sleeping_threads = threads.map {|thr| thr.status}.count("sleep")
      running_threads = threads.map {|thr| thr.status}.count("run")
      puts "Thread limit exceeded: Will sleep 5 sec - sleeping threads: #{sleeping_threads} running threads: #{running_threads}"
      sleep 5
    end

   threads << Thread.new { get_email_from_www(id,www) }

  }

  (0..100000).each {|sleeping|

    if threads.map {|thr| thr.status}.count("run") > 0 or threads.map {|thr| thr.status}.count("sleep") > 0
      sleeping_threads = threads.map {|thr| thr.status}.count("sleep")
      running_threads = threads.map {|thr| thr.status}.count("run")
     puts "Some threads are still running: Will sleep 5 sec - sleeping threads: #{sleeping_threads} running threads: #{running_threads}"
      sleep 5
    end
  }

    end