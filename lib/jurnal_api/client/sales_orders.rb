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

      # Sanitize the sales order ID for use in URLs. This method URL-encodes IDs that may contain
      # special characters like slashes, spaces, ampersands, hashes, etc. This is critical because
      # we removed URI::DEFAULT_PARSER.escape from request.rb for GET/DELETE methods to avoid
      # double-encoding. All IDs must be pre-sanitized at the source (here) to ensure proper URL construction.
      #
      # Args:
      #   id - The sales order ID (string, integer, or nil)
      #
      # Returns:
      #   - nil for nil or empty string inputs
      #   - URL-encoded string for all other inputs (converted to string first)
      #
      # Example:
      #   sanitize_sales_order_id('SO/2024/001')  # => 'SO%2F2024%2F001'
      #   sanitize_sales_order_id(1234)           # => '1234'
      #   sanitize_sales_order_id('')             # => nil
      #   sanitize_sales_order_id(nil)            # => nil
      def sanitize_sales_order_id(id)
        return nil if id.nil? || (id.is_a?(String) && id.empty?)
        ERB::Util.url_encode(id.to_s)
      end
    end
  end
end
