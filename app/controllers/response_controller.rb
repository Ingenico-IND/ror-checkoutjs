class ResponseController < ApplicationController
  skip_before_action :verify_authenticity_token

  def response_handler
    File.open('public/ingenico_transaction_config.json', 'r') do |f|
      @config_data = JSON.parse(f.read)
    end
    data = params['msg'].split('|')
    @online_transaction_msg = params['msg'].split('|')
    @raw_result = params
    if data[0] == '0300'
      request_data = { merchant: { identifier: @config_data['merchantCode'] },
                       transaction: { deviceIdentifier: 'S',
                                      currency: @config_data['currency'],
                                      dateTime: data[8].match(/(\d{2}-\d{2}-\d{4})/)[0],
                                      token: data[5],
                                      requestType: 'S' } }.to_json

      raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', request_data)
      @dual_verification_result = JSON.parse(raw_response.body)
    end
  rescue StandardError => e
    puts "Oops!:There Seems to be an error. #{e}!"
    render text: e.message
  end
end
