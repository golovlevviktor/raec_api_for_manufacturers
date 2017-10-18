
module Raec
  require 'net/http'
  require 'uri'
  require 'json'

  mattr_accessor :debug
  @@debug = false


  mattr_accessor :api_key
  @@api_key = ''

  mattr_accessor :ssl_enabled
  @@ssl_enabled = false

  mattr_accessor :request_url
  @@request_url = 'https://catalog.raec.su'

  mattr_accessor :add_product_url
  @@add_product_url = '/api/product/add/'

  mattr_accessor :product_url
  @@product_url = '/api/product/'


  mattr_accessor :type_of_request_return
  @@type_of_request_return


  # Default way to set up Raec. Run rails generate devise_install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end


  class CaseSensitiveString < String
    def downcase
      self
    end
    def capitalize
      self
    end
  end

  module Net::HTTPHeader
    def capitalize(name)
      name
    end
    private :capitalize
  end

  # =====================================================
  # Product methods


  # Делает запрос на создание нового продукта, принимает обязательные значения, необязательные указываются в виде ключ:значение в любом порядке, например:
  #
  # response = Raec.create_new_product_data(some_id, product_name, brand_name, status, ean:'4521548754211', supplierAltId:'3TS31100BA4')
  def self.create_new_product(supplierId, name, brand, status,  **params )

    data = Hash[supplierId:supplierId, name:name, brand:brand, status:status  ].merge! Hash(**params)

    body = Hash[data: data]
    request(self.add_product_url, body)
  end


  # Запрос на изменение свойства
  def self.send_property_value(raec_id, property, value)
    
    data = Hash["#{property}": value]
    body = Hash[data: data]
    request(get_product_url(raec_id), body)
  end

  # Запрос на редактирование связей между продуктами
  def self.send_relation(raec_id, child_raec_id, related_type)
    data = Hash[childProductId: child_raec_id, related_type:related_type]
    body = Hash[relate: data]

    request(get_product_url(raec_id), body)
  end

  # Запрос на редактирование произваольного ETIM св-ва
  def self.send_feature(raec_id, feature_id, value)
    body = Hash[featureId:feature_id, value:value]

    request(get_product_url(raec_id), body)
  end

  # Запрос на редактирование произваольного параметра продукта
  def self.send_attribute(raec_id, attr_name, value)
    body = Hash["#{attr_name}":value]

    request(get_product_url(raec_id), body)
  end

  # Загрузка изображения товара
  def self.send_image(raec_id, image_path, debug = self.debug)

    body = Hash["image": Faraday::UploadIO.new(image_path, 'image/jpeg')]

    # p payload[:image] = Faraday::UploadIO.new(image_path, 'image/jpeg')

    request(get_product_url(raec_id), body, true)
  end



  private

  def self.get_product_url(raec_id)
    raec_id = raec_id.to_s.strip
    product_url + raec_id
  end


  # TODO убрать !!! DEBUG = true
  # Собственно отправка запроса
  # @return [status, body]
  def self.request (path, body, multipart = false, debug = self.debug)


    p "Path: #{path}"
    p "Sended data: #{body}"

    conn = Faraday.new( :url => self.request_url,:ssl => {:verify => self.ssl_enabled}) do |faraday|
      if multipart
        faraday.request :multipart
      end
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end



    resp = conn.post do |req|
      req.url path
      req.headers[CaseSensitiveString.new('API-KEY')] = self.api_key
      if debug
        req.headers[CaseSensitiveString.new('DEBUG')] = '1'
      end
      req.body = body
    end

    p "Response: ",
    "Status: #{resp.status}",
    "Body: #{resp.body}"

    return resp.status, resp.body
  end


end
