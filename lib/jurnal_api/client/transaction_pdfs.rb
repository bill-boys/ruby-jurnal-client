# frozen_string_literal: true

module JurnalApi
  class Client
    # Defines methods related to TransactionPdfs
    module TransactionPdfs
      def transaction_pdfs_send_email(params = {})
        post('transaction_pdfs/send_email', params)
      end
    end
  end
end
