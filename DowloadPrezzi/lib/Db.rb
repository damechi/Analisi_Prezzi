# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'sqlite3'

MESINAMES = [nil] + %w(Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre)

# Nomi dei Mesi abbreviati in Italiano.
ABBR_MESINAMES = [nil] + %w(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic)

# Il nome dei giorni della settimana, in Italiano.  I giorni della settimana
# si contano da 0 a 6 (eccetto nella settimana commerciale); una
# rappresentazione numerica del giorno in questo array ci da il nome del giorno.

# Il nome del giorno in Italiano.
GIORNINAMES = %w(Domenica Lunedi Martedi Mercoledi Giovedi Venerdi Sabato)

# Abbreviati : Nomi dei Giorni, in Italiano.
ABBR_GIORNINAMES = %w(Dom Lun Mar Mer Gio Ven Sab)

QUARTER = [1, 2, 3, 4]

DBNAME = "P:/Dropbox/progetti/20141006 - Analisi_Prezzi/Ruby/prezzi.sqlite"

class Db
   attr_accessor :db
   def initialize
      @db = nil
   end

   def connect(table)
      begin
         @db = SQLite3::Database.open DBNAME
         if table == "Prezzi"
            @db.execute "CREATE TABLE IF NOT EXISTS #{table}(Id INTEGER PRIMARY KEY AUTOINCREMENT, Data DATE, Giorno INTEGER, Flusso TEXT, Zona TEXT, #{((1..24).map{|x| "Ora"+x.to_s+" REAL"}).join(",")} , UNIQUE(Data, Flusso, Zona))"
         else
            @db.execute "CREATE TABLE IF NOT EXISTS Log(Id INTEGER PRIMARY KEY AUTOINCREMENT, Data DATE, Flusso TEXT, Stato INTEGER, Messaggio TEXT, UNIQUE(Data, Flusso))"
         end
         #@db.results_as_hash = true
      rescue SQLite3::Exception => e 
         puts "Exception occurred"
         puts e
         @db.close if @db
      end
   end

   def scrivi_dati_in_db(flusso)
      data        =  flusso.data.strftime("%Y-%m-%d")
      giorno      =  flusso.data.wday
      tipo_flusso =  flusso.tipo_flusso
      (flusso.value).each do |x,y|
         zona   = x
         prezzi = y 
         @db.execute "INSERT OR REPLACE INTO Prezzi (Data, Giorno , Flusso, Zona, #{((1..24).map{|x| "Ora"+x.to_s}).join(",")}) VALUES('#{data}', #{giorno}, '#{tipo_flusso}', '#{zona}', #{prezzi.join(",")})"
      end



      # p  "INSERT OR REPLACE INTO Prezzi (Data, Giorno , Flusso, Zona, #{((1..24).map{|x| "Ora"+x.to_s}).join(",")}) VALUES('2014-10-11', '1', 'MGP', 'NORD', #{value.join(",")})"
      # @db.execute "INSERT OR REPLACE INTO Prezzi (Data, Giorno , Flusso, Zona, #{((1..24).map{|x| "Ora"+x.to_s}).join(",")}) VALUES('2014-10-11', '1', 'MGP', 'NORD', #{value.join(",")})"
   end
   #
   # def connect_log
   #    begin
   #       @db = SQLite3::Database.open DBLOG
   #       @db.execute "CREATE TABLE IF NOT EXISTS Log(Id INTEGER PRIMARY KEY AUTOINCREMENT, Data DATE, Flusso TEXT, Stato INTEGER, Messaggio TEXT, UNIQUE(Data, Flusso))"
   #       #@db.results_as_hash = true
   #    rescue SQLite3::Exception => e 
   #       puts "Exception occurred"
   #       puts e
   #       @db.close if @db
   #    end
   # end
   #
   def scrivi_log_in_db(stato, flusso, messaggio)
      #@db.execute "INSERT OR REPLACE INTO Log(Data, Flusso, Stato , Messaggio) VALUES ('#{DATA.strftime("%Y-%m-%d")}', '#{flusso}', '#{stato}', '#{messaggio}')"
      #@db.execute "INSERT OR REPLACE INTO Log(Data, Flusso, Stato , Messaggio) VALUES ('#{DATA.strftime("%Y-%m-%d")}', '#{flusso}', '#{stato}', '#{messaggio}')"
      @db.execute( "INSERT OR REPLACE INTO Log (Data, Flusso, Stato , Messaggio) VALUES ( ?, ? , ? , ? )", [DATA.strftime("%Y-%m-%d"), flusso, stato, messaggio])
   end



   def get_value(flusso, data)
    
      @db.execute("SELECT * FROM Log WHERE Flusso LIKE '#{flusso}' AND Data LIKE '#{data}'")
     
   end

   def get_all_value
        p @db.execute("SELECT * FROM Log")
   end

end
