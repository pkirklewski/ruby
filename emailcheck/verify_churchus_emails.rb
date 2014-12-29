require 'mysql'
require 'email_verifier'
require 'thread'
require 'thwait'
#########################################################################################
      def mysqlread(q)

        con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
        rs = con.query(q)
        con.close

      return rs

      end
#########################################################################################
          def emailcheck(id,email)

          id = id
          email = email

begin
                if EmailVerifier.check(email)
                      #p ":) email: #{email} verified :)"
                      q = "UPDATE organisations.churchus_emails SET verified='YES' where id='#{id}'"
                      mysqlwrite(q)
                else
                  p "!!! email: #{email} id: #{id} is not responding"
                end
rescue
   p "!!! Some errors in emailchek method: id#{id} email:#{email}"
end

          end

#########################################################################################
              def mysqlwrite(q)

                p "From msqlwrite: #{q}"

                con = Mysql.new('192.168.1.111','root','zaq1@WSX<>?','organisations')
                con.query(q)
                con.close

              end
#########################################################################################

class MyEmailVerifier

  thread_limit = 50
  query="SELECT id,email FROM organisations.churchus_emails where verified IS NULL"
  threads = []
  done = Array.new

  rs = mysqlread(query)

  rs.each_hash{|h|

    begin
    id = h['id']
    email = h['email']
    rescue
      next
    end

        until threads.map {|thr| thr.status}.count("run") < thread_limit do # sleep as long as x < thread limit returns "false"
          sleep 5
          puts "sleeping 5 sec..."
        end

          threads << Thread.new {

              if !done.include?(email)
                  emailcheck(id,email)
                  done.insert(done.length,email)
              else
                p "!!! done already includes #{email}"
              end

          }


      }

  (0..100000).each {|sleeping|

    if threads.map {|thr| thr.status}.count("run") > 0 or threads.map {|thr| thr.status}.count("sleep") > 0

      sleep 5

        sleeping_threads = threads.map {|thr| thr.status}.count("sleep")
        running_threads = threads.map {|thr| thr.status}.count("run")

      puts "Will sleep 5 sec - sleeping threads: #{sleeping_threads} running threads: #{running_threads}"

    end
  }

end
