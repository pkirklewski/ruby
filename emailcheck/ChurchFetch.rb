require 'open-uri'
require 'nokogiri'
require 'csv'
require 'mysql'
require 'internet_connection'


def waitIfNoInternet(sec)

    (0..sec).each { |s|

        if InternetConnection.off?
          puts "No Internet connection. Waiting #{s} seconds."
          sleep 1
        else
          break
        end
    }

end

# Method responsible for grabbing the data for a particular City ##################################

def getByCity(city,state)

end

# End of: Method responsible for grabbing the data for a particular City ##########################

class ScrapeChurches


waitIfNoInternet(1000000)

# Load Cities from CSV ############################################################
  cities = CSV.read('/root/fetching-sites/uscitiesDone.csv')

  (0..cities.length-1).each { |n|

    puts "========================================="
    puts "Beginning #{cities[n][0]}, #{cities[n][1]}"

    city = cities[n][0]
    city = city.gsub(' ','%2C')r
    state = cities[n][1]

# End of Load Cities from CSV ############################################################


# MySQL Open Connection ===========================================================>
    con = Mysql.new('127.0.0.1', 'root', 'zaq1@WSX<>?', 'churches')
# MySQL Open Connection ===========================================================<

    begin
  source = open("http://yellowpages.aol.com/search?query=Church&area=#{city}%2C+#{state}&invocationType=localTopBox.search").read
rescue Exeption => ex
  puts "An error of type #{ex.class} happened arround line 29, message is #{ex.message}"
end

# counting number of pages
    begin
      results = source[source.index('class="results_count"').to_i,source.index('</body>').to_i]
      results = results[0,results.index('</div>').to_i]
      results = results[results.index(' of ').to_i+4,results.length]
      results = results.strip
      results_count = results.to_i

      if results_count > 20
        reminder = results_count % 20
      end

      if reminder > 0
        number_of_pages = (results_count / 20 ) + 1
      else
        number_of_pages = results_count / 20
      end

      if number_of_pages > 25 # There is never more than 25 pages
        number_of_pages = 25
      end

    rescue
      if results_count <= 20
        number_of_pages = 1
      else
        number_of_pages = 25
      end
    end

# If there is is less then 20 results number_of_pages  = 1
    if number_of_pages == 0 and results_count > 0 and results_count <= 20
      number_of_pages = 1
    end

# counting number of pages

# remove this after testing ========================================>
=begin
    if n < 249
      break
    end
=end
# remove this after testing ========================================>

    (1..number_of_pages).each {|_|

      page_counter = _

      if number_of_pages == 1 || results_count <= 20 && results_count > 0
        begin
        www = "http://yellowpages.aol.com/search?query=Church&area=#{city}%2C+#{state}&invocationType=localTopBox.search"
          rescue Exeption => ex
            puts "An error of type #{ex.class} happened arround line 87, message is #{ex.message}"
          end
      else
            begin
            www = "http://yellowpages.aol.com/search?query=Church&area=#{city}%2C+#{state}&invocationType=localTopBox.search&resPage=#{_}&relSicId=47001000&sPage=#{_}&nt=&nups=1"
            rescue Exeption => ex
              puts "An error of type #{ex.class} happened arround line 87, message is #{ex.message}"
            end

        end
# Error happens here ??????????????????????????????????????????????????????????????????????????????/
      puts "This is www: #{www}"

=begin
      if ex.class.equal?('NilClass') == false
        puts "This is the exception class: #{ex.class}"
        puts "This is the exception message: #{ex.message}"
      end
=end

      source = open(www).read
# Error happens here ??????????????????????????????????????????????????????????????????????????????/


      b = source.index('class="fn"').to_i + 11
      e = source.index('</body>').to_i
      source = source[b,e]

      licz = 0


      if city == "Atquasuk" #"Eagle%2CRiver"
        puts "stop it"
      end

      if number_of_pages == 1

        results_per_page = results_count



      else

        results_per_page = 20
      end


      (1..results_per_page).each { |_|
        licz = licz + 1



        if number_of_pages == 1 && licz == results_count
          entry = source[0,source.index('</body>').to_i+11]
        else

          if number_of_pages == page_counter and licz == reminder
            entry = source[0,source.index('</body>').to_i+11]
          else
            entry = source[0,source.index('class="fn"').to_i+11]
          end

        end

        if licz == 20
          entry = source[0,source.index('</li>').to_i+5]
        end

        if 1==1
          suba = 0
          subb = entry.index('</a>').to_i
          church_name = entry[suba, subb]

                if church_name == ''
                  break
                end

        else
          church_name = "NULL"
          break
        end

        if entry.index('class="tel">')
          suba = entry.index('class="tel">').to_i
          entry = entry[suba, entry.index('</div></li>').to_i]
          suba = entry.index('class="tel">').to_i
          subb = entry.index('</span>').to_i
          church_tel = entry[suba+12,subb-12]
        else
          church_tel = "NULL"
        end


        if entry.index('class="official-site"')
          suba = entry.index('class="official-site"').to_i
          entry = entry[suba, entry.index('</div></li>').to_i]
          suba = entry.index('class="official-site"').to_i
          subb = entry.index('</span>').to_i
          suba = entry.index('href="').to_i
          subb = entry.index('" onclick').to_i
          church_www = entry[suba+6,subb-28]
        else
          church_www = "NULL"
        end

        if entry.index('class="street-address"')
          suba = entry.index('class="street-address">').to_i
          entry = entry[suba, entry.index('</div></li>').to_i]
          suba = entry.index('class="street-address">').to_i
          subb = entry.index('</span>').to_i
          church_address = entry[suba+23,subb-23]
        else
          church_address = "NULL"
        end

        if entry.index('class="locality"')
          suba = entry.index('class="locality">').to_i
          entry = entry[suba, entry.index('</div></li>').to_i]
          suba = entry.index('class="locality">').to_i
          subb = entry.index('</span>').to_i
          church_locality = entry[suba+17,subb-17]
        else
          church_locality = "NULL"
        end

        if entry.index('class="region"')
          suba = entry.index('class="region">').to_i
          entry = entry[suba, entry.index('</div></li>').to_i]
          suba = entry.index('class="region">').to_i
          subb = entry.index('</span>').to_i
          church_region = entry[suba+15,subb-15]
        else
          church_region = "NULL"
        end

        if entry.index('"lat":"')
          suba = entry.index('"lat":"').to_i
          entry = entry[suba, entry.index('","').to_i]
          suba = entry.index('"lat":"').to_i
          subb = entry.index('","').to_i
          church_lat = entry[suba+7,subb-7]
        else
          church_lat = "NULL"
        end

        if entry.index('"lon":"')
          suba = entry.index('"lon":"').to_i
          entry = entry[suba, entry.index('","cb').to_i]
          suba = entry.index('"lon":"').to_i
          subb = entry.index('","cb').to_i
          church_lon = entry[suba+7,subb-7]
        else
          church_lon = "NULL"
        end

        puts " "
        puts "church_name: #{church_name} " # "#{_} of #{number_of_pages} Done city: #{city} City number: #{n}"
        puts "church_tel: #{church_tel}"
        puts "church_www: #{church_www}"
        puts "church_address: #{church_address}"
        puts "church_locality: #{church_locality}"
        puts "church_region #{church_region}"
        puts "church_lat #{church_lat}"
        puts "church_lon #{church_lon}"
        puts " "

# FIX tel ============================<
church_tel = church_tel.gsub('-','')
church_tel = church_tel.gsub(' ','')
church_tel = church_tel.gsub('/','')
church_tel = church_tel.gsub('#','')

if church_tel.length == 10
church_tel = "001#{church_tel}"
end

# FIX tel ============================<

# FIX church_name ====================>

church_name = church_name.gsub("'","`")
church_address = church_address.gsub("'","`")
church_locality = church_locality.gsub("'","`")
city = city.gsub("'","")

# FIX church_name ====================<


# MySQy Insert ========================================================================================
query = "insert into churches.us values('','#{church_www}','#{church_name}','#{church_lat}','#{church_lon}','#{church_tel}','#{church_address}','#{church_locality}','#{city}','#{church_region}',NOW())"
puts query
rs = con.query(query)
# MySQL Insert ========================================================================================



        if church_name.length > 100 || church_name.length < 2 || church_name.include?("<") || church_name.include?(">")  || church_name.include?("=") || church_name.include?("</")
          puts "church_name.length > 100 || church_name.length < 3 - stop it"
        end
        source = source[source.index('class="fn">').to_i+11,source.index('</body>').to_i]

        if number_of_pages == page_counter and licz == reminder # if all pages and all records including the last page were scraped then grab another city
          break
        end

      } # results per page
      puts "#{_} of #{number_of_pages} Done city: #{city} City number: #{n}"
    } # pages
  } # cities

con.close
end
