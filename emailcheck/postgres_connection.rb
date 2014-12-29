require 'pg'

require "postgres"
conn = PGconn.connect("localhost", 5432, "", "", "test1")
# or: conn = PGconn.open('dbname=test1')
res = conn.exec("select * from a;")