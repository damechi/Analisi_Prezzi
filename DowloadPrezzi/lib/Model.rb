require "active_record"
require "active_support"

#con :dependent => :destroy è come abilitare il cascade delete, quindi se elimino un padre mi elimina ache i figli associati
class Source < ActiveRecord::Base
  has_many :borders, :dependent => :destroy
end

class Border < ActiveRecord::Base
  belongs_to :source
  has_many   :calendars, :dependent => :destroy
end

class Calendar < ActiveRecord::Base
  belongs_to :border
  has_many   :prt_prices, :dependent => :destroy
  has_many   :prt_loads, :dependent => :destroy
  has_many   :prt_temperatures, :dependent => :destroy
end

class Mgp < ActiveRecord::Base
  belongs_to :calendar
end
