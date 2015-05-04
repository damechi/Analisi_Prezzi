require "erb"
require 'mandrill'

# Build template data class.
class Email
   attr_accessor :rhtml
   def initialize( data, mercato, errore )
      @data    = data 
      @mercato = mercato
      @errore  = errore
   end

   def crea_template
      # Create template.
      template = %{
                 <html>
                   <head><title>Errore flusso <%= @mercato %> per la data: <%= @data %></title></head>
                   <body>

                     <h1><%= @mercato %> per il : (<%= @data %>)</h1>
                     <p><%= @errore %></p>

                   </body>
                 </html>
               }.gsub(/^  /, '')

      @rhtml = ERB.new(template)
   end

   # Support templating of member data.
   def get_binding
      binding
   end

   def invia
      begin
         mandrill = Mandrill::API.new 'cSzHAgXw1Oiqrt_8CrFk-Q'
         message = {"html"=> @rhtml.result(self.get_binding),
            "text"=>"Report Download Flussi ",
            "subject"=>"Report Download Flussi #{@mercato}",
            "from_email"=>"miboscol@gmail.com",
            "from_name"=>"Michele",
            "to"=>
            [{"email"=>"miboscol@gmail.com"}]
         }
         result = mandrill.messages.send message

      rescue Mandrill::Error => e
         # Mandrill errors are thrown as exceptions
         puts "A mandrill error occurred: #{e.class} - #{e.message}"
         # A mandrill error occurred: Mandrill::UnknownSubaccountError - No subaccount exists with the id 'customer-123'
         raise
      end
   end

end






