# frozen_string_literal: true

module JurnalApi
  class Client
    # Defines methods related to SalesOrders
    module SalesOrders
      def sales_orders(params = {})
        response = get('sales_orders', params)
        response
      end

      def sales_order_find(id, params = {})
        id = sanitize_sales_order_id(id)
        response = get("sales_orders/#{id}", params)
        response
      end

      def sales_order_link(id)
        response = get("sales_orders/#{id}/register_tiny_url")
        response
      end

      def sales_order_create(params = {})
        response = post('sales_orders', params)
        response
      end

      def sales_order_update(id, params = {})
        response = patch("sales_orders/#{id}", params)
        response
      end

      def sales_order_convert_to_invoice(id, params = {})
        url      = "sales_orders/#{id}/convert_to_invoice"
        response = post(url, params)

        response
      end

      def sales_order_close(id)
        url      = "sales_orders/#{id}/close_order"
        response = post(url)

        response
      end

      def sales_order_receive_payments(id, params = {})
        get("sales_orders/#{id}/sales_order_payments", params)
      end

      def sales_order_templates
        get('sales_orders/templates')
      end

      def sales_order_delete(id)
        id = sanitize_sales_order_id(id)
        delete("sales_orders/#{id}")
      end

      # Sanitize the sales order ID for use in URLs, since the id can be a string that may contain special characters like slashes or spaces. This method ensures that the ID is properly URL-encoded.
      # currently only used in sales_order_find and sales_order_delete, but can be used in other methods if needed.
      def sanitize_sales_order_id(id)
        ERB::Util.url_encode(id.to_s) if id.is_a?(String) && !id.empty?
      end
    end
  end
end
