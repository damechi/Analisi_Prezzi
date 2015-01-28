gem 'rautomation', '=0.6.3'
require 'watir'
require 'Date'


class Crawel
   attr_accessor :giorno_flusso
   def initialize
      @giorno_flusso = (Date.today+1).strftime("%d/%m/%G")
   end

   def login
      #Check se sito PRT è gia aperto, se non ancora aperto lo apro
        @ie = Watir::IE.find(:title, /GME - Gestore dei Mercati Energetici SpA/)
      if @ie.nil?
         @ie = Watir::Browser.start("http://www.mercatoelettrico.org/It/Tools/Accessodati.aspx?ReturnUrl=%2fIt%2fEsiti%2fMGP%2fEsitiMGP.aspx")
      end
      @ie.speed = :fast
      @ie.maximize
      @ie.bring_to_front

      #Eseguio il Login
      @ie.checkbox(:name, "ctl00$ContentPlaceHolder1$CBAccetto1").set
      @ie.checkbox(:name, "ctl00$ContentPlaceHolder1$CBAccetto2").set
      @ie.button(:name => 'ctl00$ContentPlaceHolder1$Button1').click
   end

   def download_tutto_ipex
      @ie.link(:class, "ctl00_ContentPlaceHolder1_MenuDown_1 menuitem ctl00_ContentPlaceHolder1_MenuDown_3").click
      @ie.link(:class, "ctl00_ContentPlaceHolder1_MenuDownload1_MenuIpex_1 menuitem ctl00_ContentPlaceHolder1_MenuDownload1_MenuIpex_3").click
      @ie.text_field(:name, "ctl00$ContentPlaceHolder1$tbDataStart").set("#{@giorno_flusso}")
      @ie.button(:id => 'ctl00_ContentPlaceHolder1_btnScarica').clicktut
   end

end
   
