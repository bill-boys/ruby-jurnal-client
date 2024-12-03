# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JurnalApi::Client::TransactionPdfs do
  let(:client) { JurnalApi::Client.new }
  let(:module_endpoint) { 'https://sandbox-api.jurnal.id/core/api/v1/transaction_pdfs' }

  describe '#send_email' do
    let(:dummy_params) do
      {
        email: {
          transaction_type_id: '3',
          email_to: 'dummy@mekari.com',
          cc_to: 'gundam@maju.com',
          email_from: 'billing@mekari.com',
          message: 'message here',
          transaction_no: 'BPI/2024/11/00001',
          template_id: 'default-1'
        }
      }
    end
    let(:dummy_response) do
      {
        message: 'sent',
        sent_total: 1
      }
    end
    let(:expected_url) { "#{module_endpoint}/send_email.json" }

    before do
      @expected_stub =
        stub_request(:post, expected_url)
        .with(body: dummy_params.to_json)
        .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
    end

    subject { client.transaction_pdfs_send_email(dummy_params.to_json) }

    it 'should hit the expected stub' do
      subject

      expect(@expected_stub).to have_been_requested
    end

    it 'should return a json response' do
      expect(subject.to_json).to eq dummy_response.to_json
    end
  end
end
