require './app/utils/read_config_data.rb'

class EmandateSiController < ApplicationController
	def mandate_verification_handler
		if request.get?
			begin
				Configdata.setData
				@config_data = Configdata.getData
				if @config_data == 403
					render template: "ingenico/mandtory_fields_page_error.html.erb"
				end
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
		if request.post?
			begin
				File.open("public/ingenico_transaction_config.json","r") do |f|
					@config_data = JSON.parse(f.read())
				end
				mode = params['modeOfVerification']
				if mode == 'eMandate'
					@type = "002"
				else
					@type = "001"
				end
				data = {:merchant => {:identifier => @config_data['merchantCode']},
						:payment => {:instruction => {}},
						:transaction => {
							:deviceIdentifier => "S",
							:type => @type,
							:currency => @config_data['currency'],
							:identifier => params['merchantTxnId'],
							:dateTime => params['date'],
							:subType => "002",
							:requestType => "TSI"
						},
						:consumer => {:identifier => params['consumerTxnId']}
					}.to_json
				raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
				@response = JSON.parse(raw_response.body)
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
	end

	def transaction_scheduling_handler
		if request.get?
			begin
				Configdata.setData
				@config_data = Configdata.getData
				if @config_data == 403
					render template: "ingenico/mandtory_fields_page_error.html.erb"
				end
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
		if request.post?
			begin
				File.open("public/ingenico_transaction_config.json","r") do |f|
					@config_data = JSON.parse(f.read())
				end
				mode = params['modeOfTransaction']
				if mode == 'eMandate'
					@type = "002"
				else
					@type = "001"
				end
				@transaction_id = rand.to_s[2..11]
				@date = Date.parse(params['date'])
				@date = @date.strftime('%d%m%Y')
				data = {
					:merchant => {:identifier => @config_data['merchantCode']},
					:payment => {
						:instrument => {:identifier => @config_data['merchantSchemeCode']},
						:instruction => {
							:amount => params['amount'],
							:endDateTime => @date,
							:identifier => params['mandateRegId']
						}
					},
					:transaction => {
						:deviceIdentifier => "S",
						:type => @type,
						:currency => @config_data['currency'],
						:identifier => @transaction_id,
						:subType => "003",
						:requestType => "TSI"
					}
				}.to_json
				raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
				@response = JSON.parse(raw_response.body)
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
	end

	def transaction_verification_handler
		if request.get?
			begin
				Configdata.setData
				@config_data = Configdata.getData
				if @config_data == 403
					render template: "ingenico/mandtory_fields_page_error.html.erb"
				end
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
		if request.post?
			begin
				File.open("public/ingenico_transaction_config.json","r") do |f|
					@config_data = JSON.parse(f.read())
				end
				mode = params['modeOfVerification']
				if mode == 'eMandate'
					@type = "002"
				else
					@type = "001"
				end
				data = {:merchant => {:identifier => @config_data['merchantCode']},
						:payment => {:instruction => {}},
						:transaction => {
							:deviceIdentifier => "S",
							:type => @type,
							:currency => @config_data['currency'],
							:identifier => params['merchantTxnId'],
							:dateTime => params['date'],
							:subType => "004",
							:requestType => "TSI"
						}
					}.to_json
				raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
				@response = JSON.parse(raw_response.body)
				if @response['paymentMethod']['paymentTransaction']['statusMessage'] == 'I'
					@response['paymentMethod']['paymentTransaction']['statusMessage'] = 'Initiated'
				elsif @response['paymentMethod']['paymentTransaction']['statusMessage'] == 'D'
					@response['paymentMethod']['paymentTransaction']['statusMessage'] = 'Success'
				elsif @response['paymentMethod']['paymentTransaction']['statusMessage'] == 'F'
					@response['paymentMethod']['paymentTransaction']['statusMessage'] = 'Failure'
				end
					
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
	end

	def mandate_deactivation_handler
		if request.get?
			begin
				Configdata.setData
				@config_data = Configdata.getData
				if @config_data == 403
					render template: "ingenico/mandtory_fields_page_error.html.erb"
				end
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
		if request.post?
			begin
				File.open("public/ingenico_transaction_config.json","r") do |f|
					@config_data = JSON.parse(f.read())
				end
				mode = params['modeOfTransaction']
				if mode == 'eMandate'
					@type = "002"
				else
					@type = "001"
				end
				@transaction_id = rand.to_s[2..11]
				data = {
					:merchant => {
						:webhookEndpointURL => "",
						:responseType => "",
						:responseEndpointURL => "",
						:description => "",
						:identifier => @config_data['merchantCode'],
						:webhookType => ""
					},
					:cart => {
						:item => [
							{
								:description => "",
								:providerIdentifier => "",
								:surchargeOrDiscountAmount => "",
								:amount => "",
								:comAmt => "",
								:sKU => "",
								:reference => "",
								:identifier => ""
							}
						],
						:reference => "",
						:identifier => "",
						:description => "",
						:Amount => ""
					},
					:payment => {
						:method => {
							:token => "",
							:type => ""
						},
						:instrument => {
							:expiry => {
								:year => "",
								:month => "",
								:dateTime => ""
							},
							:provider => "",
							:iFSC => "",
							:holder => {
								:name => "",
								:address => {
									:country => "",
									:street => "",
									:state => "",
									:city => "",
									:zipCode => "",
									:county => ""
								}
							},
							:bIC => "",
							:type => "",
							:action => "",
							:mICR => "",
							:verificationCode => "",
							:iBAN => "",
							:processor => "",
							:issuance => {
								:year => "",
								:month => "",
								:dateTime => ""
							},
							:alias => "",
							:identifier => "",
							:token => "",
							:authentication => {
								:token => "",
								:type => "",
								:subType => ""
							},
							:subType => "",
							:issuer => "",
							:acquirer => ""
						},
						:instruction => {
							:occurrence => "",
							:amount => "",
							:frequency => "",
							:type => "",
							:description => "",
							:action => "",
							:limit => "",
							:endDateTime => "",
							:identifier => "",
							:reference => "",
							:startDateTime => "",
							:validity => ""
						}
					},
					:transaction => {
						:deviceIdentifier => "S",
						:smsSending => "",
						:amount => "",
						:forced3DSCall  => "",
						:type => @type,
						:description => "",
						:currency => @config_data['currency'],
						:isRegistration => "",
						:identifier => @transaction_id,
						:dateTime => "",
						:token => params['mandateRegId'],
						:securityToken => "",
						:subType => "005",
						:requestType => "TSI",
						:reference => "",
						:merchantInitiated => "",
						:merchantRefNo => ""
					},
					:consumer => {
						:mobileNumber => "",
						:emailID => "",
						:identifier => "",
						:accountNo => ""
					}
				}.to_json
				raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
				@response = JSON.parse(raw_response.body)
				puts "response is #{@response}"
				if @response['paymentMethod']['paymentTransaction']['statusCode'] == "" and @response['paymentMethod']['error']['desc'] == ""
					@response['paymentMethod']['paymentTransaction']['statusCode'] = "Not Found"
					@response['paymentMethod']['error']['desc'] = "Not Found"
				end

			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
	end

	def stop_payment_handler
		if request.get?
			begin
				Configdata.setData
				@config_data = Configdata.getData
				if @config_data == 403
					render template: "ingenico/mandtory_fields_page_error.html.erb"
				end
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
		if request.post?
			begin
				File.open("public/ingenico_transaction_config.json","r") do |f|
					@config_data = JSON.parse(f.read())
				end
				@transaction_id = rand.to_s[2..11]
				data = {
					:merchant => {
						:webhookEndpointURL => "",
						:responseType => "",
						:responseEndpointURL => "",
						:description => "",
						:identifier => @config_data['merchantCode'],
						:webhookType => ""
					},
					:cart => {
						:item => [
							{
								:description => "",
								:providerIdentifier => "",
								:surchargeOrDiscountAmount => "",
								:amount => "",
								:comAmt => "",
								:sKU => "",
								:reference => "",
								:identifier => ""
							}
						],
						:reference => "",
						:identifier => "",
						:description => "",
						:Amount => ""
					},
					:payment => {
						:method => {
							:token => "",
							:type => ""
						},
						:instrument => {
							:expiry => {
								:year => "",
								:month => "",
								:dateTime => ""
							},
							:provider => "",
							:iFSC => "",
							:holder => {
								:name => "",
								:address => {
									:country => "",
									:street => "",
									:state => "",
									:city => "",
									:zipCode => "",
									:county => ""
								}
							},
							:bIC => "",
							:type => "",
							:action => "",
							:mICR => "",
							:verificationCode => "",
							:iBAN => "",
							:processor => "",
							:issuance => {
								:year => "",
								:month => "",
								:dateTime => ""
							},
							:alias => "",
							:identifier => "test",
							:token => "",
							:authentication => {
								:token => "",
								:type => "",
								:subType => ""
							},
							:subType => "",
							:issuer => "",
							:acquirer => ""
						},
						:instruction => {
							:occurrence => "",
							:amount => "11",
							:frequency => "",
							:type => "",
							:description => "",
							:action => "",
							:limit => "",
							:endDateTime => "",
							:identifier => "",
							:reference => "",
							:startDateTime => "",
							:validity => ""
						}
					},
					:transaction => {
						:deviceIdentifier => "S",
						:smsSending => "",
						:amount => "",
						:forced3DSCall  => "",
						:type => "001",
						:description => "",
						:currency => params['currency'],
						:isRegistration => "",
						:identifier => @transaction_id,
						:dateTime => "",
						:token => params['txnId'],
						:securityToken => "",
						:subType => "006",
						:requestType => "TSI",
						:reference => "",
						:merchantInitiated => "",
						:merchantRefNo => ""
					},
					:consumer => {
						:mobileNumber => "",
						:emailID => "",
						:identifier => "",
						:accountNo => ""
					}
				}.to_json
				raw_response = call_api('https://www.paynimo.com/api/paynimoV2.req', data)
				@response = JSON.parse(raw_response.body)
			rescue Exception => e
				puts "Oops!:There Seems to be an error. #{e}!"
				render text: e.message
			end
		end
	end
end
