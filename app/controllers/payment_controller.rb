require './app/utils/read_config_data'

class PaymentController < ApplicationController
  skip_before_filter :verify_authenticity_token
  include Configdata

  def home
    string_to_bool = { 'true' => true, true => true, 'false' => false, false => false }
    @transaction_id = rand.to_s[2..11]
    @return_url = request.original_url + 'response/response-handler'
    Configdata.setData
    @config_data = Configdata.getData
    @startDate = Time.now.strftime('%Y-%m-%d')
    @endDate = (Date.parse(@startDate) + 30.year).strftime('%Y-%m-%d')
    @siDetailsAtMerchantEndCond = string_to_bool[@config_data['enableSI']] && string_to_bool[@config_data['siDetailsAtMerchantEnd']]
    render template: 'payment/mandtory_fields_page_error.html.erb' if @config_data == 403
  rescue StandardError => e
    puts "Oops!:There Seems to be an error. #{e}!"
    render text: e.message
  end

  # Method to return JSON dataobject,to pass in inegenico js for Online Transaction.
  def online_transaction_handler
    if request.post?
      begin
        Configdata.setData
        @config_data = Configdata.getData
        params['amount'] = '1' if @config_data['typeOfPayment'] == 'TEST'
        if (@config_data['siDetailsAtMerchantEnd'] == 'false') && (@config_data['enableSI'] == 'true')
          params['amountType'] = @config_data['amountType']
          params['frequency'] = @config_data['frequency']
          params['debitStartDate'] = Time.now.strftime('%Y-%m-%d')
          params['debitEndDate'] = (Date.parse(params['debitStartDate']) + 30.year).strftime('%Y-%m-%d')
          params['maxAmount'] = (params['amount'].to_i * 2).to_s
        end
        datastring = get_datastring(params)
        hashedata = String(OpenSSL::Digest.new('sha512', datastring))
        data = get_hash_object(hashedata, params, @config_data)
        render json: data
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end
  end

  # Method that would create a JSON file and store config values.
  def admin_handler
    if request.get?
      begin
        File.open('public/ingenico_transaction_config.json', 'r') do |f|
          @config_data = JSON.parse(f.read)
        end
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        @config_data = {}
      end
    end

    if request.post?
      begin
        tempHash = {}
        params.each do |key, value|
          tempHash.store(key, value)
        end
        File.open('public/ingenico_transaction_config.json', 'w') do |f|
          f.write(JSON.pretty_generate(tempHash))
        end
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
      redirect_to payment_admin_path, alert: 'Success: Information has been updated.'
    end
  end

  # Method that would call an API for offline verification.
  def offline_verification_handler
    if request.get?
      begin
        Configdata.setData
        @config_data = Configdata.getData
        render template: 'payment/mandtory_fields_page_error.html.erb' if @config_data == 403
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end

    if request.post?
      begin
        File.open('public/ingenico_transaction_config.json', 'r') do |f|
          @config_data = JSON.parse(f.read)
        end
        data = { merchant: { identifier: @config_data['merchantCode'] },
                 transaction: { deviceIdentifier: 'S',
                                currency: @config_data['currency'],
                                identifier: params['merchantRefNo'],
                                dateTime: params['date'],
                                requestType: 'O' } }.to_json
        raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
        @response = JSON.parse(raw_response.body)
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end
  end

  # Method that would call an API for refund.
  def refund_handler
    if request.get?
      begin
        Configdata.setData
        @config_data = Configdata.getData
        render template: 'payment/mandtory_fields_page_error.html.erb' if @config_data == 403
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end

    if request.post?
      begin
        File.open('public/ingenico_transaction_config.json', 'r') do |f|
          @config_data = JSON.parse(f.read)
        end
        data = { merchant: { identifier: @config_data['merchantCode'] },
                 cart: {},
                 transaction: { deviceIdentifier: 'S',
                                amount: params['amount'],
                                currency: @config_data['currency'],
                                token: params['token'],
                                dateTime: params['inputDate'],
                                requestType: 'R' } }.to_json
        raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
        @response = JSON.parse(raw_response.body)
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end
  end

  def reconciliation_handler
    if request.get?
      begin
        Configdata.setData
        @config_data = Configdata.getData
        render template: 'payment/mandtory_fields_page_error.html.erb' if @config_data == 403
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end

    if request.post?
      begin
        File.open('public/ingenico_transaction_config.json', 'r') do |f|
          @config_data = JSON.parse(f.read)
        end
        transaction_ids = params['merchantRefNo'].delete(' ')
        transaction_ids = transaction_ids.split(',')
        @last_response = []
        start_date = Date.parse(params['fromDate'])
        end_date = Date.parse(params['endDate'])
        transaction_ids.each do |transaction_id|
          next unless transaction_id != ''

          @count = 0
          (start_date..end_date).each do |date|
            date = date.strftime('%d-%m-%Y')
            data = { merchant: { identifier: @config_data['merchantCode'] },
                     transaction: { deviceIdentifier: 'S',
                                    currency: @config_data['currency'],
                                    identifier: transaction_id,
                                    dateTime: date,
                                    requestType: 'O' } }.to_json
            raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
            @response = JSON.parse(raw_response.body)
            unless (@response['paymentMethod']['paymentTransaction']['statusCode'] != 9999) && (@response['paymentMethod']['paymentTransaction']['errorMessage'] != 'Transactionn Not Found')
              next
            end

            @count = 1
            @last_response.push(@response)
            break
          end
          @last_response.push(@response) if @count == 0
        end
      rescue StandardError => e
        puts "Oops!:There Seems to be an error. #{e}!"
        render text: e.message
      end
    end
  end

  # Method for S2S
  def s2s_handler
    Configdata.setData
    @config_data = Configdata.getData
    if @config_data == 403
      render template: 'payment/mandtory_fields_page_error.html.erb'
    else
      data = params['msg'].split('|')
      @clnt_txn_ref = data[3]
      @pg_txn_id = data[5]

      data_string = data[0...-1].join('|') + '|' + @config_data['SALT']
      @status = data[15] == String(OpenSSL::Digest.new('sha512', data_string)) ? 1 : 0
    end
  rescue StandardError => e
    puts "Oops!:There Seems to be an error. #{e}!"
    render text: e.message
  end

  # Method that would written a piped string to the caller
  def get_datastring(data)
    data['mrctCode'] + '|' + data['txn_id'] + '|' + data['amount'] + '|' + data['accNo'] + '|' \
      + data['custID'] + '|' + data['mobNo'] + '|' + data['email'] + '|' + \
      data['debitStartDate'].split('-').reverse.join('-') + '|' + data['debitEndDate'].split('-').reverse.join('-') \
      + '|' + data['maxAmount'] + '|' + data['amountType'] + '|' + data['frequency'] + '|' + data['cardNumber'] + '|' \
      + data['expMonth'] + '|' + data['expYear'] + '|' + data['cvvCode'] + '|' + data['SALT']
  end

  # Method that would return a hash object to the caller.
  def get_hash_object(hashdata, data, config_data)
    string_to_bool = { 'true' => true, true => true, 'false' => false, false => false }
    prepared_object = { tarCall: false,
                        features: { showPGResponseMsg: true,
                                    enableMerTxnDetails: true,
                                    enableAbortResponse: false,
                                    enableSI: string_to_bool[config_data['enableSI']],
                                    siDetailsAtMerchantEnd: string_to_bool[config_data['siDetailsAtMerchantEnd']],
                                    enableNewWindowFlow: string_to_bool[config_data['enableNewWindowFlow']], # for hybrid applications please disable this by passing false
                                    enableExpressPay: string_to_bool[config_data['enableExpressPay']], # if unique customer identifier is passed then save card functionality for end  end customer
                                    enableInstrumentDeRegistration: string_to_bool[config_data['enableInstrumentDeRegistration']], # if unique customer identifier is passed then option to delete saved card by end customer
                                    hideSavedInstruments: string_to_bool[config_data['hideSavedInstruments']],
                                    separateCardMode: string_to_bool[config_data['separateCardMode']],
                                    payWithSavedInstrument: string_to_bool[config_data['saveInstrument']],
                                    hideSIDetails: string_to_bool[config_data['hideSIDetails']],
                                    hideSIConfirmation: string_to_bool[config_data['hideSIConfirmation']],
                                    expandSIDetails: string_to_bool[config_data['expandSIDetails']],
                                    enableDebitDay: string_to_bool[config_data['enableDebitDay']],
                                    showSIResponseMsg: string_to_bool[config_data['showSIResponseMsg']],
                                    showSIConfirmation: string_to_bool[config_data['showSIConfirmation']],
                                    enableTxnForNonSICards: string_to_bool[config_data['enableTxnForNonSICards']],
                                    showAllModesWithSI: string_to_bool[config_data['showAllModesWithSI']] },
                        consumerData: { deviceId: 'WEBSH2', # //possible values 'WEBSH1', 'WEBSH2' and 'WEBMD5'
                                        token: hashdata,
                                        returnUrl: data['returnUrl'],
                                        paymentMode: config_data['paymentMode'],
                                        paymentModeOrder: config_data['paymentModeOrder'].delete(' ').split(','),
                                        checkoutElement: string_to_bool[config_data['embedPaymentGatewayOnPage']] == true ? '#ingenico_embeded_popup' : '',
                                        merchantLogoUrl: config_data['logoURL'],
                                        merchantId: data['mrctCode'], # provided merchant
                                        merchantMsg: config_data['merchantMessage'],
                                        disclaimerMsg: config_data['disclaimerMessage'],
                                        currency: data['currency'],
                                        consumerId: data['custID'], # Your unique consumer identifier to register a eMandate/eNACH
                                        consumerMobileNo: data['mobNo'],
                                        consumerEmailId: data['email'],
                                        txnId: data['txn_id'], # Unique merchant transaction ID
                                        items: [{ itemId: data['scheme'],
                                                  amount: data['amount'],
                                                  comAmt: '0' }],
                                        customStyle: { PRIMARY_COLOR_CODE: config_data['primaryColor'], # merchant primary color code
                                                       SECONDARY_COLOR_CODE: config_data['secondaryColor'], # provide merchant's suitable color code
                                                       BUTTON_COLOR_CODE_1: config_data['buttonColor1'], # merchant's button background color code
                                                       BUTTON_COLOR_CODE_2: config_data['buttonColor2'] } } }

    if string_to_bool[data['siDetailsAtMerchantEndCond']]
      prepared_object[:consumerData].merge!(
        accountNo: data['accNo'],
        accountHolderName: data['accountHolderName'],
        ifscCode: data['ifscCode'],
        accountType: data['accountType'],
        debitStartDate: data['debitStartDate'].split('-').reverse.join('-'),
        debitEndDate: data['debitEndDate'].split('-').reverse.join('-'),
        maxAmount: data['maxAmount'],
        amountType: data['amountType'],
        frequency: data['frequency']
      )
    elsif string_to_bool[config_data['enableSI']] && !string_to_bool[data['siDetailsAtMerchantEndCond']]
      prepared_object[:consumerData].merge!(
        debitStartDate: data['debitStartDate'].split('-').reverse.join('-'),
        debitEndDate: data['debitEndDate'].split('-').reverse.join('-'),
        maxAmount: data['maxAmount'],
        amountType: data['amountType'],
        frequency: data['frequency']
      )
    end
    prepared_object
  end
end
