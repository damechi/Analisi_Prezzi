require 'optparse'
require File.dirname(__FILE__) + '/lib/DownloadPrezzi'

oggi = Date.today
options = {}

optparse = OptionParser.new do |opts|

   opts.banner = "Usage: main.rb -f MGP -s 21/02/2015 -e 23/02/2015"
   opts.separator  ""
   opts.separator  "Options"

   opts.on('-f', '--flusso     MGP', 'Flusso to download') do |flusso|
      flusso  = flusso.upcase
      mercati = [ "MGP","MI1","MI2","MI3","MI4","MI5"]
      if !flusso.include? flusso
         raise OptionParser::InvalidOption, "Flusso non corretto, devi inserire uno dei seguenti flussi MGP,MI1,MI2,MI3,MI4" 
      end
      options[:flusso] = flusso
   end

   opts.on('-s', '--startdate  22/01/201', 'Start date to download') do |startdate|
      options[:startdate] = Date.parse(startdate)
   end

   opts.on('-e', '--enddate    23/01/2015', 'End date to download') do |enddate|
      options[:enddate] = Date.parse(enddate)
   end

   opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
   end
end


begin
   optparse.parse!
   data = [:startdate, :enddate] 
   if options[:flusso].nil?    
      puts "\n"
      puts "Opzione Mancante: Devi inserire almeno un flusso (MGP,MI1,MI2,MI3,MI4)" 
      puts "\n"
      puts optparse
      sleep 5
      exit                                                          

   end  


   flusso = options[:flusso]
   data.select{ |param|
      if options[param].nil?
         if flusso == "MGP" || flusso == "MI1" || flusso == "MI2" 
            print "- #{param} impostato su #{(oggi+1).strftime('%d/%m/%Y')} \n"
            options[param]= oggi+1
         else
            print "- #{param} impostato su #{(oggi).strftime('%d/%m/%Y')} \n"
            options[param]= oggi
         end
      end
   }
      if options[:startdate] > options[:enddate]
      puts "\n"
      puts "La data di inizio deve essere minore della data fine"   
      puts "\n"
      puts optparse  
      sleep 5
      exit                                                           
   end   


rescue OptionParser::InvalidOption, OptionParser::MissingArgument
   puts $!.to_s       
   puts "\n"
   puts optparse 
   sleep 5
   exit                                                                   
end 

avvio(options)
sleep 5




