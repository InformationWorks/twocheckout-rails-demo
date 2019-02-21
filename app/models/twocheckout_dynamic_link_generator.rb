class TwocheckoutDynamicLinkGenerator

  attr_accessor :name, :merchant, :dynamic, :currency, :return_url, :return_type, :tpl, :prod, :tangible, :price, :type, :qty, :signature, :test

  def initialize(name:, merchant:, dynamic:, currency:, return_url:, return_type:, tpl:, prod:, tangible:, price:, type:, qty:, test:)
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
      "signature"
    ].each do |field_name|
      field_value = self.send("#{field_name}")
      link += "#{field_name.gsub('_','-')}=#{field_value}&"
    end

    link = link.chomp("&")

    return link
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

end