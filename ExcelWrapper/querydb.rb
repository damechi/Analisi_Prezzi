require 'sqlite3'
# TODO: Inserire il path dinamico per il DB dei prezzi
DBNAME = (Pathname.new(__dir__).parent+"DB/prezzi.sqlite").to_s

class Db
   attr_accessor :db
   def initialize
      @db = nil
   end

   def connect()
      begin
         @db = SQLite3::Database.open DBNAME
         return self
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
   attr_accessor :query
   def genera_query
      ore = *("1".."24").map{|x| "Ora"+x }
      @query      = "SELECT Giorno,Data,Flusso,Zona,#{ore.join(",")} FROM Prezzi WHERE"
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
         popup("Devi selezionare almeno una data", "Selezione data", 64)
         exit 0
      end

   end

   def parse_giorno
      g = "" 
      if @giorno.nil?
         return nil 
      else
         @giorno.each do |x|
            g = g+"OR Giorno = '#{x}' "
         end
      end
      return g.sub("OR", "")
   end

   def parse_mercato
      m = "" 

      if mercati.size == 2
         return "Flusso = '#{@mercati.keys[0]}' OR Flusso ='#{@mercati.keys[1]}'"
      elsif  mercati.size == 1
         return "Flusso = '#{@mercati.keys[0]}'"
      else
         popup("Devi selezionare almeno un mercato", "Selezione mercato", 64)
         exit 0
      end

   end

   def parse_zona
      z = "" 
      if @zone.nil?
         popup("Devi selezionare almeno una zona", "Selezione zona", 64)
         exit 0
      else
         @zone.each do |x|
            z = z+"OR Zona = '#{x}' "
         end
      end
      return z.sub("OR", "")
   end

   def inputbox(message, title='')
      sc = WIN32OLE.new("ScriptControl")
      sc.language = "VBScript"
      sc.eval("Inputbox(\"#{message}\",  \"#{title}\")")
   end

   def popup(message, title='', tipo_messaggio)
      wsh = WIN32OLE.new("WScript.Shell")
      wsh.popup(message, 0, title, tipo_messaggio)
   end


end

#query = Query.new
#db = Db.new
#db.connect
#ap db.exec_query(query.genera_query)


