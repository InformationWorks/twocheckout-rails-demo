require 'net/http'
require 'uri'
require 'json'

class TwocheckoutDynamicLinkGenerator

  attr_accessor :name, :merchant, :dynamic, :currency, :return_url, :return_type, :tpl, :prod, :tangible, :price, :type, :qty, :signature, :test, :order_ext_ref

  def initialize(name:, merchant:, dynamic:, currency:, return_url:, return_type:, tpl:, prod:, tangible:, price:, type:, qty:, test:, order_ext_ref:)
    @name = name
    @merchant = merchant
    @dynamic = dynamic
    @currency = currency
    @return_url = return_url
    @return_type = return_type
    @tpl = tpl
    @prod = prod
    @tangible = tangible
    @price = price
    @type = type
    @qty = qty
    @test = test
    @order_ext_ref = order_ext_ref
    @signature = generate_signature
  end

  def dynamic_buy_link
    link = "https://secure.2checkout.com/checkout/buy?"

    [
      "merchant",
      "dynamic",
      "tpl",
      "currency",
      "prod",
      "price",
      "qty",
      "return_url",
      "return_type",
      "tangible",
      "type",
      "test",
      "order_ext_ref",
      "signature"
    ].each do |field_name|
      field_value = self.send("#{field_name}")
      link += "#{field_name.gsub('_','-')}=#{field_value}&"
    end

    link = link.chomp("&")

    return link
  end

  def self.verify_response_hash(received_params:)
    response_signature = self.generate_response_signature(received_params: received_params)
    puts "response_signature: #{response_signature}"
    puts "received_params['signature']: #{received_params["signature"]}"
    return (response_signature == received_params["signature"])
  end

  def self.reverify(received_params:)

    code = "#{Rails.application.credentials.twocheckout[:merchant_code]}"
    date = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    secret_key = "#{Rails.application.credentials.twocheckout[:secret_key]}"
    hash_raw = "#{code.length}#{code}#{date.length}#{date}"
    hash = OpenSSL::HMAC.hexdigest('MD5', secret_key, hash_raw)

    auth_header = %Q{code='#{code}' date='#{date}' hash='#{hash}'}

    puts "auth_header: #{auth_header}"

    headers = {
      :content_type => 'application/json',
      :accept => 'application/json',
      "X-Avangate-Authentication" => auth_header
    }

    link = "https://api.2checkout.com/rest/5.0/orders/#{received_params["refno"]}/"

    response = HTTParty.get(link,
      headers: headers
    )

    puts "response: #{response}"

    # https://knowledgecenter.2checkout.com/Integration/03SOAP_API/001SOAP_API_5.0/07API_Responses/007Order_with_dynamic_products
    valid_responses = ["AUTHRECEIVED", "COMPLETE"]
    return (valid_responses.include?(response["Status"]))
  end

  private

  # Ordered params that are required for signature
  # currency
  # prod
  # price
  # qty
  # return-url
  # return-type
  # tangible
  # type
  def generate_signature

    raw_data_for_signature = ""

    [
      "currency",
      "order_ext_ref",
      "price",
      "prod",
      "qty",
      "return_type",
      "return_url",
      "tangible",
      "type"
    ].each do |field|
      field_value = self.send("#{field}")
      raw_data_for_signature += "#{field_value.length}#{field_value}"
    end

    return OpenSSL::HMAC.hexdigest('SHA256', "#{Rails.application.credentials.twocheckout[:buy_link_secret_word]}", raw_data_for_signature)

  end

  def self.generate_response_signature(received_params:)

    raw_data_for_signature = ""

    [
      "currency",
      "dynamic",
      "merchant",
      "order-ext-ref",
      "price",
      "prod",
      "qty",
      "refno",
      "return-type",
      "return-url",
      "tangible",
      "test",
      "total",
      "total-currency",
      "tpl",
      "type"
    ].each do |field|
      puts "field: #{field}"
      field_value = received_params[field]
      raw_data_for_signature += "#{field_value.length}#{field_value}"
    end

    puts "response raw_data_for_signature: #{raw_data_for_signature}"

    return OpenSSL::HMAC.hexdigest('SHA256', "#{Rails.application.credentials.twocheckout[:buy_link_secret_word]}", raw_data_for_signature)

  end

end