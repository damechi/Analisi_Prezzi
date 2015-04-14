require 'ox'
require 'pp'

class Xml
   attr_accessor :prezzi
   def initialize
      @giorno_flusso_d1        = (Date.today+1).strftime("%G%m%d")
      @giorno_flusso_d         = (Date.today).strftime("%G%m%d")
      @giorno_flusso_d_meno_7  = (Date.today-7).strftime("%G%m%d")
      @prezzi = {}
   end

   def parse_file file
      file_content = File.read(file)
      doc = Ox.parse(file_content)
      doc.NewDataSet.nodes.delete_at(0)
      doc.NewDataSet.nodes.each{|x|
         x.nodes.each{|y|
            if  (y.value != "Data") && (y.value != "Ora" ) && (y.value != "Mercato")
               if @prezzi["#{y.value}"] == nil
                  #case file
                  #when ->(n) { n.fnmatch?("*MI3*")} then  @prezzi["#{y.value}"] = Array.new(16, "null")
                  #when ->(n) { n.fnmatch?("*MI4*")} then  @prezzi["#{y.value}"] = Array.new(12, "null")
                  #when ->(n) { n.fnmatch?("*MI5*")} then  @prezzi["#{y.value}"] = Array.new(12, "null")
                  #@else  @prezzi["#{y.value}"] = [] 
                  @prezzi["#{y.value}"] = [] 
                  #end
               end
               @prezzi["#{y.value}"] << ((y.nodes[0].sub(",",".")).to_f).round(2)
            end
         }
      }
      @prezzi.delete_if do |k,v|
         ["BSP","SVIZ","SLOV","ROSN","PRGP","MFTV","GREC","FRAN","FOGN","CORS","COAC","AUST","NAT"].include? k
      end
      @prezzi.each { |k,v|
          if @prezzi[k].length != 24
             @prezzi[k] = Array.new(24-@prezzi[k].length,"null")+@prezzi[k]

          end
      }
      return @prezzi
   end
end

