=begin
  calendar.rb - Gtk::Calendar sample script.

  Copyright (c) 2002-2006 Ruby-GNOME2 Project Team
  This program is licenced under the same licence as Ruby-GNOME2.

  $Id: calendar.rb,v 1.7 2006/06/17 13:18:12 mutoh Exp $
=end

require 'gtk2'
require 'win32ole'

cal = Gtk::Calendar.new

w = Gtk::Window.new("Calendar sample")
w.set_window_position Gtk::Window::POS_CENTER
w.add(cal).show_all.signal_connect('delete_event') do
  Gtk.main_quit
end
prova = 
date = Time.new

cal.select_month(date.month, date.year)
cal.select_day(date.day)
cal.mark_day(date.day)
#cal.clear_marks
cal.display_options(Gtk::Calendar::SHOW_HEADING |
		    Gtk::Calendar::SHOW_DAY_NAMES |
		    Gtk::Calendar::SHOW_WEEK_NUMBERS)
year, month, day = cal.date
puts "this is #{month} #{day}, #{year}"



cal.signal_connect('day_selected_double_click') do
  year, month, day = cal.date

  if day < 10
     day = "0"+day.to_s
  end
  if month < 10
     month = "0"+month.to_s
  end
  

  excel = WIN32OLE::connect('Excel.Application')
  excel.Workbooks("AnalisiPrezzi.xls")
  #excel.Run("SetData", "#{day}/#{month}/#{year}")
  excel.Run("SetData", ARGV[0], "#{day}/#{month}/#{year}")
  
  
  

  Gtk.main_quit
end


Gtk.main
