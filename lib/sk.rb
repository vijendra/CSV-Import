require 'sk_api_schema'
require 'sk_sdk/base'
require 'sk_sdk/oauth'
# Tiny helper class for talking to SalesKing
# - Setup local Sk:: classes for remote objects. client, address,..
# - construct writable fields
class Sk
  # setup oAuth app info, local classes
  @@conf = YAML.load_file(Rails.root.join('config', 'salesking_app.yml'))
  #raise 'config/salesking_app.yml missing' if !@@conf || @@conf.empty?
  APP = SK::SDK::Oauth.new(@@conf[Rails.env])
  %w{Client Address}.each do |model|
    eval "class #{model} < SK::SDK::Base;end"
  end
  
  # init SalesKing classes and set connection oAuth token
  def self.init(site, token)
    SK::SDK::Base.set_connection( {:site => site, :token => token} )
  end

  # Construct fields for importing clients. Hides unnecessary fields and adds
  # address fields for one address
  #
  # == Returns
  #<Array>:: [ { 'field_name'=>{properties} }, ]
  def self.client_fields
    # skip fields that dont make sence
    exclude_cli = ['lock_version', 'team_id', 'addresses']
    exclude_adr = ['order', 'lat', 'long', '_destroy']
    client_schema = SK::Api::Schema.read('client', '1.0')
    adr_schema = SK::Api::Schema.read('address', '1.0')
    props = []
    client_schema['properties'].each do |name, prop|
      props << { name => prop } unless prop['readonly'] || exclude_cli.include?(name)
    end
    # only one address for now inline
    adr_schema['properties'].each do |name, prop|
      props << { "address.#{name}" => prop } unless prop['readonly'] || exclude_adr.include?(name)
    end
    props.sort_by{ |p| p.keys.first  }
  end

  # read json-schema
  def self.read_schema(kind)
    SK::Api::Schema.read(kind, '1.0')
  end
end
