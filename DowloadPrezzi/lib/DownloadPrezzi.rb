require "Date"
require File.dirname(__FILE__) + '/Ftp'
require File.dirname(__FILE__) + '/Db'
require File.dirname(__FILE__) + '/Xml'

#DATA = Date.today-1

class Flusso
   attr_accessor :path_xml_flusso, :tipo_flusso, :value, :data, :flusso
   def initialize(tipo_flusso, data)
      @path_xml_flusso = nil
      @tipo_flusso     = tipo_flusso
      @value           = Hash.new 
      @data            = data
   end
end

class Download_Ipex
   attr_accessor :flusso, :data
   def initialize(tipo_flusso, data)
      #@flussi = ["MGP_Prezzi" , "MGP_Quantita",  "MGP_Transiti" , "MGP_DomandaOfferta",  "MGP_Fabbisogno", "MGP_LimitiTransito", "MGP_Liquidita" ,  "MGP_StimeFabbisogno", "MGP_OffertePubbliche"]
      @flusso  = Flusso.new(tipo_flusso, data)
      @data    = data
   end

   def download_file
      ftp = Crawel.new(@data)
      ftp.login
      @flusso.path_xml_flusso = (ftp.download_file "#{@flusso.tipo_flusso}_prezzi")
      ftp.close_connection
      unless flusso.path_xml_flusso
         raise "File XML #{@flusso.tipo_flusso} non scaricato dal server FTP"
      end
   end

   def parse_xml
      xml = Xml.new
      @flusso.value = xml.parse_file @flusso.path_xml_flusso
   end

   def inserimento_dati_db
      db = Db.new
      db.connect("Prezzi")
      db.scrivi_dati_in_db(@flusso)
   end

   def inserisci_log_in_db(stato, messaggio)
      db = Db.new
      db.connect("Log")
      db.scrivi_log_in_db(stato, @flusso.tipo_flusso, messaggio, @data)
   end

   def check_presenza_prezzi
      db = Db.new
      db.connect("Log")
      result = (db.get_value(@flusso.tipo_flusso, (@data).strftime("%Y-%m-%d")))
      if result.empty?
         return 0
      else
         return (db.get_value(@flusso.tipo_flusso, @data.strftime("%Y-%m-%d")))[0]
      end
   end

   def get_all_value
      db = Db.new
      db.connect("Log")
      db.get_all_value
   end
end

def avvio(options)
   flusso               = options[:flusso]
   startdate            = options[:startdate]
   enddate              = options[:enddate]

   (startdate .. enddate).map{|data|
      begin
         ipex =  Download_Ipex.new(flusso, data)
         if ipex.check_presenza_prezzi[3] == 0
            ipex.download_file
            ipex.parse_xml
            ipex.inserimento_dati_db
            ipex.inserisci_log_in_db(1, "OK" )
         else
            puts "Flusso #{flusso} per #{data.strftime("%d/%m/%Y")} gia presente"
         end
      rescue Exception => e
         ipex.inserisci_log_in_db(0, e.to_s )#e.backtrace.inspect
      end
   }

end
