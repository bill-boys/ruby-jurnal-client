# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JurnalApi::Client::SalesOrders do
  let(:client)          { JurnalApi::Client.new }
  let(:module_endpoint) { 'https://sandbox-api.jurnal.id/core/api/v1/sales_orders' }

  describe '#list' do
    context 'successful' do
      let(:dummy_params) { { page: 1, page_size: 10 } }
      let(:dummy_response) do
        {
          "total_data": 100,
          "data": [
            read_file_fixture('responses/sales_orders/create_success.json')['sales_order']
          ]
        }
      end

      before do
        @expected_stub = stub_request(:get, "#{module_endpoint}.json")
          .with(query: dummy_params)
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_orders(dummy_params) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end

    context 'without params' do
      let(:dummy_response) do
        {
          "total_data": 100,
          "data": []
        }
      end

      before do
        @expected_stub = stub_request(:get, "#{module_endpoint}.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_orders }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#get' do
    context 'successful' do
      let(:dummy_response) { read_file_fixture('responses/sales_orders/create_success.json') }
      let(:sales_order_id) { dummy_response['sales_order']['id'] }
      let(:dummy_params) { { for_internal: true } }

      before do
        @expected_stub = stub_request(:get, "#{module_endpoint}/#{sales_order_id}.json")
          .with(query: dummy_params)
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_find(sales_order_id, dummy_params) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end

    context 'failed' do
      context 'with status 503' do
        let(:dummy_response) { read_file_fixture('responses/sales_orders/create_success.json') }
        let(:sales_order_id) { dummy_response['sales_order']['id'] }

        before do
          @expected_stub = stub_request(:get, "#{module_endpoint}/#{sales_order_id}.json")
            .to_return(
              status: 503,
              body: 'upstream connect error or disconnect/reset before headers. reset reason: connection termination',
            )
        end

        subject { client.sales_order_find(sales_order_id) }

        it 'should hit the expected stub' do
          expect { subject }.to raise_error JurnalApi::ServiceUnavailable

          expect(@expected_stub).to have_been_requested
        end
      end
    end
  end

  describe '#get so link' do
    context 'successful' do
      let(:dummy_response) do
        { 'url' => 'http://dummy.com/123456' }
      end
      let(:sales_order_id) { '1234' }

      before do
        @expected_stub = stub_request(:get, "#{module_endpoint}/#{sales_order_id}/register_tiny_url.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_link(sales_order_id) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#create' do
    context 'successful' do
      let(:dummy_params) do
        read_file_fixture('requests/sales_orders/create_valid.json')
      end
      let(:dummy_response) do
        read_file_fixture('responses/sales_orders/create_success.json')
      end

      before do
        @expected_stub =
          stub_request(:post, module_endpoint + '.json')
            .with(body: dummy_params.to_json)
            .to_return(status: 201, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_create(dummy_params.to_json) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#update' do
    context 'successful' do
      let(:dummy_params) do
        read_file_fixture('requests/sales_orders/create_valid.json')
      end
      let(:dummy_response) do
        read_file_fixture('responses/sales_orders/create_success.json')
      end
      let(:so_id) { 909 }

      before do
        @expected_stub =
          stub_request(:patch, "#{module_endpoint}/#{so_id}.json")
          .with(body: dummy_params.to_json)
          .to_return(status: 201, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_update(so_id, dummy_params.to_json) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#convert_to_invoice' do
    context 'successful' do
      let(:dummy_params) do
        read_file_fixture('requests/sales_orders/convert_to_invoice_valid.json')
      end
      let(:dummy_response) do
        read_file_fixture('responses/sales_orders/convert_to_invoice_success.json')
      end

      before do
        @stubbed_id   = 1108 # from Jurnal API documentation
        expected_url  = module_endpoint + '/' + @stubbed_id.to_s + '/convert_to_invoice.json'

        @expected_stub =
          stub_request(:post, expected_url)
            .with(body: dummy_params.to_json)
            .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_convert_to_invoice(@stubbed_id, dummy_params.to_json) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#sales_order_receive_payments' do
    context 'success' do
      let(:dummy_params) do
        {
          page: 1,
          page_size: 5
        }
      end

      let(:dummy_response) do
        read_file_fixture('responses/sales_orders/receive_payments_response.json')
      end

      before do
        expected_url = module_endpoint + '/1/sales_order_payments.json'

        @expected_stub =
          stub_request(:get, expected_url)
          .with(query: dummy_params)
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_receive_payments(1, dummy_params) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#sales_order_templates' do
    before do
      expected_url = module_endpoint + '/templates.json'

      @expected_stub =
        stub_request(:get, expected_url)
        .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
    end

    let(:dummy_response) do
      {
        "total_data": 2,
        "data": [
          {
            "id": "default-1",
            "name": "1",
            "image_preview": "https://jurnal-assets-production.jurnal.id/images/templete_preview/invoice_preview/invoice_preview_1.png",
            "setting_link": "/company/setting/ondemand_pdf"
          },
          {
            "id": "default-2",
            "name": "2",
            "image_preview": "https://jurnal-assets-production.jurnal.id/images/templete_preview/invoice_preview/invoice_preview_2.png"
          }
        ]
      }.to_json
    end

    subject { client.sales_order_templates }

    it 'should hit the expected stub' do
      subject

      expect(@expected_stub).to have_been_requested
    end

    it 'should return a json response' do
      expect(subject).to eq dummy_response
    end
  end

  describe '#sales_order_close' do
    context 'successful' do
      let(:so_id) { 1234 }
      let(:dummy_response) do
        {
          "status": "success",
          "message": "Sales order has been closed successfully"
        }
      end

      before do
        @expected_stub = stub_request(:post, "#{module_endpoint}/#{so_id}/close_order.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_close(so_id) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end
  end

  describe '#sales_order_delete' do
    context 'successful' do
      let(:so_id) { 1234 }
      let(:dummy_response) do
        {
          "status": "success",
          "message": "Sales order has been deleted successfully"
        }
      end

      before do
        @expected_stub = stub_request(:delete, "#{module_endpoint}/#{so_id}.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_delete(so_id) }

      it 'should hit the expected stub' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end

    context 'failed' do
      context 'when sales order not found' do
        let(:so_id) { 9999 }

        before do
          @expected_stub = stub_request(:delete, "#{module_endpoint}/#{so_id}.json")
            .to_return(status: 404, body: '{"error": "Sales order not found"}', headers: header_json)
        end

        subject { client.sales_order_delete(so_id) }

        it 'should hit the expected stub' do
          expect { subject }.to raise_error JurnalApi::NotFound

          expect(@expected_stub).to have_been_requested
        end
      end
    end
  end

  describe '#sanitize_sales_order_id' do
    context 'with string ID containing special characters' do
      it 'should URL-encode forward slashes' do
        so_id = 'SO/2024/001'
        expected = 'SO%2F2024%2F001'

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to eq expected
      end

      it 'should URL-encode spaces' do
        so_id = 'SO 2024 001'
        expected = 'SO%202024%20001'

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to eq expected
      end

      it 'should URL-encode multiple special characters' do
        so_id = 'SO/2024 & 001'
        expected = 'SO%2F2024%20%26%20001'

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to eq expected
      end

      it 'should URL-encode hash/pound symbols' do
        so_id = 'SO#2024'
        expected = 'SO%232024'

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to eq expected
      end
    end

    context 'with numeric ID' do
      it 'should convert to string and handle correctly' do
        so_id = 1234
        expected = '1234'

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to eq expected
      end
    end

    context 'with empty or nil ID' do
      it 'should return nil for empty string' do
        so_id = ''

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to be_nil
      end

      it 'should return nil for nil' do
        so_id = nil

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to be_nil
      end
    end

    context 'with ID containing no special characters' do
      it 'should return the same string' do
        so_id = 'SO2024001'
        expected = 'SO2024001'

        result = client.sanitize_sales_order_id(so_id)
        expect(result).to eq expected
      end
    end
  end

  describe '#get with special characters in ID' do
    context 'when sales order ID contains forward slashes' do
      let(:so_id) { 'SO/2024/001' }
      let(:encoded_id) { 'SO%2F2024%2F001' }
      let(:dummy_response) { read_file_fixture('responses/sales_orders/create_success.json') }
      let(:dummy_params) { { for_internal: true } }

      before do
        @expected_stub = stub_request(:get, "#{module_endpoint}/#{encoded_id}.json")
          .with(query: dummy_params)
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_find(so_id, dummy_params) }

      it 'should properly URL-encode the ID' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end

    context 'when sales order ID contains spaces' do
      let(:so_id) { 'SO 2024 001' }
      let(:encoded_id) { 'SO%202024%20001' }
      let(:dummy_response) { read_file_fixture('responses/sales_orders/create_success.json') }

      before do
        @expected_stub = stub_request(:get, "#{module_endpoint}/#{encoded_id}.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_find(so_id) }

      it 'should properly URL-encode spaces in the ID' do
        subject

        expect(@expected_stub).to have_been_requested
      end
    end
  end

  describe '#delete with special characters in ID' do
    context 'when sales order ID contains forward slashes' do
      let(:so_id) { 'SO/2024/001' }
      let(:encoded_id) { 'SO%2F2024%2F001' }
      let(:dummy_response) do
        {
          "status": "success",
          "message": "Sales order has been deleted successfully"
        }
      end

      before do
        @expected_stub = stub_request(:delete, "#{module_endpoint}/#{encoded_id}.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_delete(so_id) }

      it 'should properly URL-encode the ID' do
        subject

        expect(@expected_stub).to have_been_requested
      end

      it 'should return a json response' do
        expect(subject).to eq dummy_response
      end
    end

    context 'when sales order ID contains spaces and special characters' do
      let(:so_id) { 'SO 2024/001' }
      let(:encoded_id) { 'SO%202024%2F001' }
      let(:dummy_response) do
        {
          "status": "success",
          "message": "Sales order has been deleted successfully"
        }
      end

      before do
        @expected_stub = stub_request(:delete, "#{module_endpoint}/#{encoded_id}.json")
          .to_return(status: 200, body: dummy_response.to_json, headers: header_json)
      end

      subject { client.sales_order_delete(so_id) }

      it 'should properly URL-encode special characters and spaces' do
        subject

        expect(@expected_stub).to have_been_requested
      end
    end
  end
end
