module Configdata

	def self.getData
		@@config_data 
	end

	def self.setData
		begin
			File.open("public/ingenico_transaction_config.json","r") do |f|
				@@config_data = JSON.parse(f.read())
				if (@@config_data['merchantCode'] || @@config_data['SALT'] || @@config_data ['currency'] ) == ""
					@@config_data = 403
				end	
			end
		rescue Exception => e 
			@@config_data = 403
		end 
	end
end


