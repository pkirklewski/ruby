require 'open-uri'
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

def getByCity(city,state,n,howmanyt)

  #puts "This is city number #{n}:#{city.gsub('%2C',' ')}:#{state} from the getByCity method. Current number of threads: #{howmanyt}"

  # Grab source from www ===========================================================>
    begin
      waitIfNoInternet(1000000)
      source = open("http://yellowpages.aol.com/search?query=Religious+Goods&area=#{city}%2C+#{state}&invocationType=localTopBox.search").read
    rescue Exeption => ex
      puts "An error of type #{ex.class} happened arround line 29, message is #{ex.message}"
sleep 60    
end
  # End of: Grab source from www ===========================================================<

      # Counting number of pages ===========================================================<
        begin
          results = source[source.index('class="results_count"').to_i,source.index('</body>').to_i]
          results = results[0,results.index('</div>').to_i]
          results = results[results.index(' of ').to_i+4,results.length]
          results_txt = results[results.index(' of ').to_i+4,results.length]
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
puts "number of pages (line:77)#{number_of_pages}"        
end

      # End of: Counting number of pages ===========================================================>

    (1..number_of_pages).each {|_|

      page_counter = _

      if number_of_pages == 1 || results_count <= 20 && results_count > 0
        begin
          waitIfNoInternet(1000000)
          www = "http://yellowpages.aol.com/search?query=Religious+Goods&area=#{city}%2C+#{state}&invocationType=localTopBox.search"
        rescue Exeption => ex
          puts "An error of type #{ex.class} happened arround line 87, message is #{ex.message}"
        end
      else
        begin
          waitIfNoInternet(1000000)
          www = "http://yellowpages.aol.com/search?query=Religious+Goods&area=#{city}%2C+#{state}&invocationType=localTopBox.search&resPage=#{_}&relSicId=47001000&sPage=#{_}&nt=&nups=1"
        rescue Exeption => ex
          puts "An error of type #{ex.class} happened arround line 87, message is #{ex.message}"
        end

      end

#      puts "This is www: #{www}"
      source = open(www).read

      b = source.index('class="fn"').to_i + 11
      e = source.index('</body>').to_i
      source = source[b,e]

      licz = 0


      if number_of_pages == 1

        results_per_page = results_count

      else

        results_per_page = 20
      end


# LOOPING THROUGH RESULTS  LOOPING THROUGH RESULTS  LOOPING THROUGH RESULTS LOOPING THROUGH RESULTS LOOPING THROUGH RESULTS

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

        if licz == 20 # if this is the ned of file there is no more other entries besids the last one so class="fn" con not be used as reference of the end of entry
          entry = source[0,source.index('</li>').to_i+5]
        end

if entry[0,5]=="<?xml" # Testing if entry starts from the begginging of source, in outher words if the source has not been treamed for whatever reason

  if entry.include?("SORRY we") and entry.include?("find any results")
		
		errentry = "entry includes SORRY we coulbd't find any results for: #{www}"
		
		File.write('/root/test/development.log',"Start=========================================================================================================================",File.size('/root/test/development.log'),mode: 'a')
		File.write('/root/test/development.log',errentry,File.size('/root/test/development.log'),mode: 'a')
		File.write('/root/test/development.log',"",File.size('/root/test/development.log'),mode: 'a')
  else
  		posa =  entry.index('class="fn"').to_i+11
  		posb = entry.length - posa
  		entry = entry[posa,posb] #The entry should now start from the Church name at possion 0
  end

end

	  if entry.length > 0 # loooking after Church name
          suba = 0
          subb = entry.index('</a>').to_i
          church_name = entry[suba, subb]

          if church_name == ''
            File.write('/root/test/development.log',"Church name is empty for: #{www} Will now break.",File.size('/root/test/development.log'),mode: 'a')
            break # Should we break or Next ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
          end

              if church_name[0,5]=="<?xml" # Testing for what happens if the church name is ridiculous
                  File.write('/root/test/development.log',"church_name starting with <?xml which is ridiculous ! Prinitng entry: ",File.size('/root/test/development.log'),mode: 'a')
                  File.write('/root/test/development.log',"",File.size('/root/test/development.log'),mode: 'a')
                  File.write('/root/test/development.log',entry,File.size('/root/test/development.log'),mode: 'a')
                  File.write('/root/test/development.log',"End=====================================================================================",File.size('/root/test/development.log'),mode: 'a')
              end

        else
          church_name = "NULL"
	        File.write('/root/test/development.log',"Church name is NULL for: #{www} Will now break.",File.size('/root/test/development.log'),mode: 'a')
          break # Should we break or Next ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
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

=begin
        puts " "
        puts "church_name: #{church_name} "
        puts "church_tel: #{church_tel}"
        puts "church_www: #{church_www}"
        puts "church_address: #{church_address}"
        puts "church_locality: #{church_locality}"
        puts "church_region #{church_region}"
        puts "church_lat #{church_lat}"
        puts "church_lon #{church_lon}"
        puts " "
=end

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


        # Checking if the church_name is not something ridiculous ======================================>
        if church_name.length > 100 || church_name.length < 2 || church_name.include?("<") || church_name.include?(">")  || church_name.include?("=") || church_name.include?("</")
puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	  theerrormessage =  "!!!:( church_name[4,3]: #{church_name[4,3]}  Ridiculous Church name: current result proccessed: #{licz} City: #{city},#{state} CityNumber: #{n} n_of_pages: #{number_of_pages} page_counter: #{page_counter} church_name: #{church_name[0,110]}."          
#puts theerrormessage
#File.write('/root/test/development.log',theerrormessage)

puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	  
puts "Will now sleep 1000 then break"
puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
sleep 1000
break
	end
        # Checking if the church_name is not something ridiculous ======================================<


# MySQL Insert ========================================================================================>
        
	query = "insert into churches.relgoods values('','#{church_www}','#{church_name}','#{church_lat}','#{church_lon}','#{church_tel}','#{church_address}','#{church_locality}','#{city}','#{church_region}',NOW())"
		


        begin
          

  # MySQL Open Connection ===========================================================>
  waitIfNoInternet(1000000)
  con = Mysql.new('127.0.0.1', 'root', 'zaq1@WSX<>?', 'churches')
  # MySQL Open Connection ===========================================================<

	rs = con.query(query)
		con.close
		puts ":) #{city}:#{state} City#: #{n}  #{query}"          
        rescue Mysql::Error => e
          
	if e.error.include?('has gone away')
            sleep 1000
          end
		puts "!!!:( Error: #{e.error} City: #{city}:#{state} City#: #{n} Closing MySQL connection after writing a query: #{query}"          
		con.close
        end

# MySQL Insert ========================================================================================<



        source = source[source.index('class="fn">').to_i+11,source.index('</body>').to_i]

        if number_of_pages == page_counter and licz == reminder # if all pages and all records including the last page were scraped then grab another city
puts "END END END END END END END END END END END END END END END END Line 295 Closing MySQL connection and grabbing another City - ALL RECORDS BEEN SCRAPED =============================================="          
con.close
          break
        end

      } # results per page
#puts "#{_} of #{number_of_pages} Done city: #{city} City number: #{n}"
    } # pages
    con.close

end

# End of: Method responsible for grabbing the data for a particular City ##########################


class ScrapeOrganisations

  waitIfNoInternet(1000000)

# Load Cities from CSV ############################################################
  cities = CSV.read('/root/fetching-sites/uscitiesDone.csv')
  thread_limit = 10
  threads = []

  (0..cities.length-1).each { |n|

    #puts "========================================="
    #puts "Beginning #{cities[n][0]}, #{cities[n][1]}"

    city = cities[n][0]
    city = city.gsub(' ','%2C')
    state = cities[n][1]

    until threads.map {|t| t.status}.count("run") < thread_limit do
      sleep 5
    end
    howmanyt = threads.map{|th| th.status}.count("run")
    threads << Thread.new {getByCity(city,state,n,howmanyt)}



# End of Load Cities from CSV ############################################################


  } # cities


end

