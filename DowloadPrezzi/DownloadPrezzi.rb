require "Date"
require "ap"
require "byebug"
require File.dirname(__FILE__) + '/lib/Ftp'
require File.dirname(__FILE__) + '/lib/Db'
require File.dirname(__FILE__) + '/lib/Xml'

DATA = Date.today

class Flusso
   attr_accessor :path_xml_flusso, :tipo_flusso, :value, :data, :flusso
   def initialize(tipo_flusso)
      @path_xml_flusso = nil
      @tipo_flusso     = tipo_flusso
      @value           = Hash.new 
      @data            = nil
      #@flusso          = nil
   end
end

class Download_Ipex
   attr_accessor :flusso
   def initialize(tipo_flusso)
      #@flussi = ["MGP_Prezzi" , "MGP_Quantita",  "MGP_Transiti" , "MGP_DomandaOfferta",  "MGP_Fabbisogno", "MGP_LimitiTransito", "MGP_Liquidita" ,  "MGP_StimeFabbisogno", "MGP_OffertePubbliche"]
      @flusso  = Flusso.new(tipo_flusso)
   end

   def download_file
      ftp = Crawel.new(DATA)
      ftp.login
      @flusso.path_xml_flusso = (ftp.download_file @flusso.tipo_flusso) 
      ftp.close_connection
      unless flusso.path_xml_flusso 
         raise "File XML #{@flusso.tipo_flusso} non scaricato dal server FTP" 
      end
   end

   def parse_xml
      xml = Xml.new
      case @flusso.tipo_flusso
      when /MGP/ then  @flusso.data = (DATA+1)
      when /MI1/ then  @flusso.data = (DATA+1)
      when /MI2/ then  @flusso.data = (DATA+1)
      when /MI3/ then  @flusso.data = (DATA)
      when /MI4/ then  @flusso.data = (DATA)
      end
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
      db.scrivi_log_in_db(stato, @flusso.tipo_flusso, messaggio)
   end

   def check_presenza_prezzi
      db = Db.new
      db.connect("Log")
      result = (db.get_value(@flusso.tipo_flusso, (DATA+1).strftime("%Y-%m-%d")))
      if result.empty?
         return 0
      else
          return (db.get_value(@flusso.tipo_flusso, DATA.strftime("%Y-%m-%d")))[0]
      end
   end

   def get_all_value
      db = Db.new
      db.connect("Log")
      db.get_all_value 
   end
end



tipo_flusso = ARGV[0]
begin
   ipex =  Download_Ipex.new(tipo_flusso)
   if ipex.check_presenza_prezzi[3] == 0
      ipex.download_file
      ipex.parse_xml
      ipex.inserimento_dati_db
      ipex.inserisci_log_in_db(1, "OK" )  
   end
rescue Exception => e
   ipex.inserisci_log_in_db(0, e.backtrace.inspect)
end
