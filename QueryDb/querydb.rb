require 'sqlite3'
require 'ap'
# TODO: Inserire il path dinamico per il DB dei prezzi
DBNAME = "P:/Dropbox/progetti/20141006 - Analisi_Prezzi/Ruby/DB/prezzi.sqlite"

class Db
   attr_accessor :db
   def initialize
      @db = nil
   end

   def connect()
      begin
         @db = SQLite3::Database.open DBNAME
         #@db.results_as_hash = true
      rescue SQLite3::Exception => e 
         puts "Exception occurred"
         puts e
         @db.close if @db
      end
   end




   def get_value(flusso, data)
    
      @db.execute("SELECT * FROM Log WHERE Flusso LIKE '#{flusso}' AND Data LIKE '#{data}'")
     
   end

   def exec_query(query)
        ap @db.execute(query)
   end

end




class Query
   attr_accessor :start_date, :end_date, :giorno, :mercato1, :mercato2, :zona, :query
   def initialize
      @start_date = "2015-01-27"
      @end_date   = "2015-01_28"
      @giorno     = [1,2,3]
      @mercato1   = "MGP"
      @mercato2   = "MI1"
      @zona       = ["NORD", "CSUD"]
      @query      = "SELECT * FROM Prezzi "
   end

   def genera_query
      @query = @query + parse_date + parse_giorno
   end

   def parse_date
      if (@start_date != nil) && (@end_date != nil)
         return "WHERE Data BETWEEN '#{@start_date}' AND '#{@end_date}' "
      elsif @start_date != nil
         return "WHERE Data = '#{@start_date}' "
      else
         return "WHERE Data = '#{@end_date}' "
      end
      return nil
   end

   def parse_giorno
      g = "" 
      if @giorno.empty? 
         return "" 
      else
         @giorno.each do |x|
            g = g+" OR Giorno = #{x} "

         end
      end
      return g
   end
end

query = Query.new
p query.genera_query

db = Db.new
db.connect
db.exec_query(query.query)
