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
      @db.execute(query)
   end

end


class Query
   attr_accessor :start_date, :end_date, :giorno, :mercato1, :mercato2, :zona, :query
   def initialize
      @start_date = "2015-01-27" 
      @end_date   = nil 
      @giorno     = nil
      @mercato1   = "MGP"
      @mercato2   = nil
      @zona       = ["SUD"] 
      @query      = "SELECT * FROM Prezzi WHERE"
   end

   def genera_query
      query_date     = parse_date
      query_giorno   = parse_giorno
      query_mercato  = parse_mercato 
      query_zona     = parse_zona

      @query = @query + " AND " + "("+query_date+")"  if query_date != nil  

      @query = @query + " AND " + "("+query_giorno+")" if query_giorno != nil

      @query = @query + " AND " + "("+query_mercato+")" if query_mercato != nil

      @query = @query + " AND " + "("+query_zona+")" if query_zona != nil

      return @query.sub("AND", "")

   end

   def parse_date
      if (@start_date != nil) && (@end_date != nil)
         return "Data BETWEEN '#{@start_date}' AND '#{@end_date}'"
      elsif @start_date != nil
         return " Data = '#{@start_date}'"
      elsif @end_date != nil
         return "Data = '#{@end_date}'"
      else
         return nil
      end

   end

   def parse_giorno
      g = "" 
      if @giorno.nil?
         return nil 
      else
         @giorno.each do |x|
            g = g+"OR Giorno = #{x} "
         end
      end
      return g.sub("OR", "")
   end

   def parse_mercato
      m = "" 
      if (@mercato1 != nil) && (@mercato2 != nil)
         return "Flusso = '#{@mercato1}' OR Flusso ='#{@mercato2}'"
      elsif @mercato1 != nil
         return "Flusso = '#{@mercato1}'"
      elsif @mercato2 != nil
         return "Flusso = '#{@mercato2}'"
      else
         return nil
      end

   end

   def parse_zona
      z = "" 
      if @zona.nil?
         return nil
      else
         @zona.each do |x|
            z = z+"OR Zona = '#{x}' "
         end
      end
      return z.sub("OR", "")
   end


end

query = Query.new
db = Db.new
db.connect
ap db.exec_query(query.genera_query)
