# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JurnalApi::Client::GenerateShortenLink do
  let(:client) { JurnalApi::Client.new }
  let(:module_endpoint) { 'https://sandbox-api.jurnal.id/core/api/internal' }

  describe '#generate_shorten_link' do
    context 'successful' do
      let(:payment_url) { 'https://example.com/payment/12345' }
      let(:dummy_params) { { payment_url: payment_url } }
      let(:dummy_response) do
        {
          'url' => 'https://short.ly/abc123'
        }
      end

      before do
        expected_url = "#{module_endpoint}/transactions/generate_shorten_link?payment_url=#{payment_url}"
        
        @expected_stub =
          stub_request(:post, expected_url)
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.generate_shorten_link(dummy_params) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response.to_json
      end

      it 'should set api_version to api/internal' do
        subject
        expect(client.api_version).to eq('api/internal')
      end

      it 'should set format to nil' do
        expect(client).to receive(:format=).with(nil)
        subject
      end
    end
  end
end
