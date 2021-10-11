module Configdata
  def self.getData
    @@config_data
  end

  def self.setData
    File.open('public/worldline_transaction_config.json', 'r') do |f|
      @@config_data = JSON.parse(f.read)
      if (@@config_data['merchantCode'] || @@config_data['SALT'] || @@config_data ['currency']) == ''
        @@config_data = 403
      end
    end
  rescue StandardError
    @@config_data = 403
  end
end
