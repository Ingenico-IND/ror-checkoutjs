Rails.application.routes.draw do
  # set the index page / root url
  root 'payment#home', as: :ingenico_home

  post 'payment/online-transaction-handler' => 'payment#online_transaction_handler'

  post 'response/response-handler' => 'response#response_handler'

  get 'payment/admin' => 'payment#admin_handler', :as => :admin_home
  post 'payment/admin' => 'payment#admin_handler'

  get 'payment/offline-verification' => 'payment#offline_verification_handler'
  post 'payment/offline-verification' => 'payment#offline_verification_handler'

  get 'payment/refund' => 'payment#refund_handler'
  post 'payment/refund' => 'payment#refund_handler'

  get 'payment/reconcile' => 'payment#reconciliation_handler'
  post 'payment/reconcile' => 'payment#reconciliation_handler'

  get 'payment/s2s' => 'payment#s2s_handler'

  get 'emandate-si/mandate-verification' => 'emandate_si#mandate_verification_handler'
  post 'emandate-si/mandate-verification' => 'emandate_si#mandate_verification_handler'

  get 'emandate-si/transaction-scheduling' => 'emandate_si#transaction_scheduling_handler'
  post 'emandate-si/transaction-scheduling' => 'emandate_si#transaction_scheduling_handler'

  get 'emandate-si/transaction-verification' => 'emandate_si#transaction_verification_handler'
  post 'emandate-si/transaction-verification' => 'emandate_si#transaction_verification_handler'

  get 'emandate-si/mandate-deactivation' => 'emandate_si#mandate_deactivation_handler'
  post 'emandate-si/mandate-deactivation' => 'emandate_si#mandate_deactivation_handler'

  get 'emandate-si/stop-payment' => 'emandate_si#stop_payment_handler'
  post 'emandate-si/stop-payment' => 'emandate_si#stop_payment_handler'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
