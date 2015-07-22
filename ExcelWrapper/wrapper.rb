require 'win32ole'
require "Pathname"
require_relative "querydb.rb"

class Excel < Query
   attr_accessor :excel, :workbook, :start_date, :end_date, :giorno, :mercato1, :mercato2, :zone, :mercati 
   def initialize
      @excel       = conneti_excel
      @workbook    = conneti_workbook
      @start_date  = assegna_variabile("start_date")
      @end_date    = assegna_variabile("end_date")
      @zone        = assegna_variabile("zone")
      @giorno      = assegna_variabile_giorno
      self.hash_mercati = ["mercato1","mercato2"]

   end

   def avvio
      db = connetti_db
      valori = db.exec_query(genera_query)
      if valori.empty?
         popup("Non è stato trovato nessun dato", "", 64)
         exit
      end
      assegna_valori_mercato(valori)
      compila_prezzi(valori)
   end

   def connetti_db
      (Db.new).connect
   end

   def conneti_excel
      WIN32OLE::connect('Excel.Application')
   end

   def conneti_workbook
      excel.Workbooks("AnalisiPrezzi.xls")
   end

   def assegna_variabile(variabile)
      tmp = excel.Run("GetElement", variabile)
      if tmp != ""
         if variabile == "zone"
            return tmp.split(",")
         elsif variabile == "start_date" || variabile == "end_date"
            return "#{tmp[-4..-1]}-#{tmp[-7..-6]}-#{tmp[0..1]}"
         else
            return tmp
         end
      end
      return nil
   end

   def hash_mercati=(m) 
      @mercati = Hash.new
      m.each do |m|
         tmp = assegna_variabile(m)
         if tmp != nil
            @mercati[tmp] = nil 
         end
      end
   end

   def assegna_valori_mercato(valori)
      if mercati.size == 2
         m1,m2 =  valori.partition { |v| v[2] ==  mercati.keys[0]}
         mercati[mercati.keys[0]],mercati[mercati.keys[1]]= m1,m2
         mercati["#{mercati.keys[0]}-#{mercati.keys[1]}"] = spread_mercati(m1,m2)
      else
         mercati[mercati.keys[0]] = valori
      end
   end

   def spread_mercati(m1,m2)
      l =  (m1.length)-1
      arr = []
      0.upto(l) { |i|
         m = m1[i][4..-1]
         # n = m2.select { |x|  x[0] == m1[i][0] && x[1] == m1[i][1]}
         n = m2.select { |x| x[1] == m1[i][1]}
         arr[i] = [m1[i][0], m1[i][1],"#{mercati.keys[0]}-#{mercati.keys[1]}", m1[i][3]]

         if n.empty?
            arr[i] << Array.new(24, "")
            arr[i].flatten!
            popup("Per il giorno #{arr[i][1]} non è statto trovato nessun dato per il mercato #{mercati.keys[1]}", "", 64)
         else
            arr[i] << [m,n[0][4..-1]].transpose.map { |x|
               if x[0].nil? || x[1].nil? 
                  ""
               else
                  x.reduce :-
               end

            }
            arr[i].flatten!
         end
      }
      return arr
   end

   def assegna_variabile_giorno
      day = []
      #{"CheckLU" => nil, "CheckMA" => nil, "CheckME" => nil, "CheckGI" => nil, "CheckVE" => nil, "CheckSA" => nil, "CheckDO" => nil}.inject({}) { |h, (k, v)| h[k] = excel.Run("GetElement", "MGP", k); h }
      ["CheckDO", "CheckLU", "CheckMA", "CheckME", "CheckGI", "CheckVE", "CheckSA"].each_with_index do |value,index|
         if excel.Run("GetElement", value) == "Vero"
            day <<  get_giorno(index)
         end
      end
      if day.empty?
         return nil
      end
      return day
   end

   def compila_prezzi(valori)
      excel.ScreenUpdating = false
      excel.Calculation = -4135
      inizializza_file

      @mercati.each do |k,v|
         worksheet = crea_foglio(k)
         worksheet.Select

         rng = worksheet.Range('B15').Resize(v.size, v.first.size)
         rng.Value = v

         applica_formato(worksheet)
         if @mercati.size == 1
            s = worksheet.Shapes("M1")
            s.Visible = true
            s.TextFrame.Characters.Text = k
         else
            @mercati.keys.each_with_index do |key, index|
               if index == 0
                  s = worksheet.Shapes("M1")
               elsif index == 1
                  s = worksheet.Shapes("M2")
               else
                  s = worksheet.Shapes("M1-M2")
               end
               s.Visible = true
               s.TextFrame.Characters.Text = key
               s.Name = key
            end
            excel.Run('CambiaColoreTab', k)
         end
      end
      @mercati.keys.each_with_index do |key, index|
         if index != 0
            @workbook.Worksheets(key).visible = false
         end

      end

      excel.DisplayAlerts = false
      @workbook.Worksheets("Analisi_Prezzi").delete
      excel.ScreenUpdating = true
      excel.Calculation = -4105

   end

   def inizializza_file
      begin 
         @workbook.Worksheets("Analisi_Prezzi")
      rescue
         excel.DisplayAlerts = false
         worksheet = @workbook.Worksheets("Template")
         worksheet.Copy({'before'=>worksheet})
         worksheet = @workbook.Worksheets("Template (2)")
         worksheet.Name = "Analisi_Prezzi"
         worksheet.visible =true
         @workbook.Worksheets.each { |sheet|
            if sheet.name != "Analisi_Prezzi" && sheet.name != "Template" && sheet.name != "Config" && sheet.name != "Template_Spread"
               sheet.delete
            end
         }

      end
   end

   def crea_foglio(name)
      if name.match("-")
         worksheet = @workbook.Worksheets("Template_Spread")
         worksheet.Copy({'before'=>worksheet})
         worksheet = @workbook.Worksheets("Template_Spread (2)")
      else
         worksheet = @workbook.Worksheets("Template")
         worksheet.Copy({'before'=>worksheet})
         worksheet = @workbook.Worksheets("Template (2)")
      end
      worksheet.Name = name
      worksheet.visible =true

      return worksheet
   end

   def applica_formato(worksheet)
      last_cell = ((worksheet.range("B14").end(-4121).address).scan(/[0-9]+$/).last).to_i # >> "$B$7"

      (15..last_cell ).each {|row|
         worksheet.Range("AD#{row}").Formula = "=SE(CONTA.NUMERI(F#{row}:AC#{row})<>0;MEDIA(F#{row}:AC#{row});\"\")"
         worksheet.Range("AE#{row}").Formula = "=SE(CONTA.NUMERI(F#{row}:M#{row};Z#{row}:AC#{row})<>0;MEDIA(F#{row}:M#{row};Z#{row}:AC#{row});\"\")"
         worksheet.Range("AF#{row}").Formula = "=SE(CONTA.NUMERI(N#{row}:Y#{row})<>0;MEDIA(N#{row}:Y#{row});\"\")"
         #worksheet.Range("AD#{row}").Formula = "=MEDIA(F#{row}:AC#{row})"
         #worksheet.Range("AE#{row}").Formula = "=MEDIA(F#{row}:M#{row};Z#{row}:AC#{row})"
         #worksheet.Range("AF#{row}").Formula = "=MEDIA(N#{row}:Y#{row})"
         if row.even? 
            worksheet.Range("B#{row}:AF#{row}").Interior.Color = 4210752.0
         else
            worksheet.Range("B#{row}:AF#{row}").Interior.Color = 2500134.0
         end
      }
   end

   def get_giorno(day)
      case day
      when 0 then "Domenica"
      when 1 then "Lunedì"
      when 2 then "Martedì"
      when 3 then "Mercelodì"
      when 4 then "Giovedì"
      when 5 then "Venerdì"
      when 6 then "Sabato"
      end

   end

end

excel = Excel.new
excel.avvio

