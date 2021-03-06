ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'rack'
require 'padrino-core'
require 'padrino-auth'

# Helper methods for testing Padrino::Access
class MiniTest::Spec
  include Rack::Test::Methods

  def mock_app(base=Padrino::Application, &block)
    @app = Sinatra.new(base, &block)
  end

  def app
    Rack::Lint.new(@app)
  end

  def status; last_response.status; end
  def body; last_response.body; end
  alias response last_response

  def set_access(*args)
    @app.set_access(*args)
  end

  def allow(subject = nil, path = '/')
    @app.fake_session[:visitor] = nil
    get "/login/#{subject.id}" if subject
    get path
    assert_equal 200, status, caller.first.to_s
  end

  def deny(subject = nil, path = '/')
    @app.fake_session[:visitor] = nil
    get "/login/#{subject.id}" if subject
    get path
    assert_equal 403, status, caller.first.to_s
  end
end

module Character
  extend self

  def authenticate(credentials)
    case
    when credentials[:email] && credentials[:password]
      target = all.find{ |resource| resource.id.to_s == credentials[:email] }
      target.name.gsub(/[^A-Z]/,'') == credentials[:password] ? target : nil
    when credentials.has_key?(:id)
      all.find{ |resource| resource.id == credentials[:id] }
    else
      false
    end
  end

  def all
    @all = [
      OpenStruct.new(:id => :bender,   :name => 'Bender Bending Rodriguez', :role => :robots  ),
      OpenStruct.new(:id => :leela,    :name => 'Turanga Leela',            :role => :mutants ),
      OpenStruct.new(:id => :fry,      :name => 'Philip J. Fry',            :role => :humans  ),
      OpenStruct.new(:id => :ami,      :name => 'Amy Wong',                 :role => :humans  ),
      OpenStruct.new(:id => :zoidberg, :name => 'Dr. John A. Zoidberg',     :role => :lobsters),
    ]
  end
end
