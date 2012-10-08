require 'sinatra'
require 'rack'
require 'slim'
require "sinatra/reloader"
require 'rack-flash'
require 'warden'
require 'hmac/strategies/header'

class Pgas::RestApi < Sinatra::Application
  set :views, settings.root + '/../../views'
  enable :sessions
  use Rack::Flash

  use Warden::Manager do |manager|
    manager.default_strategies [:password, :hmac_header]
    manager.failure_app = Pgas::RestApi

    manager.scope_defaults(:hmac, :strategies => [:hmac_header],
                           :store => false,
                           :hmac => {
                             :secret => ->(arg) {'secret'},
                             :auth_header_parse => /(?<scheme>[-_+.\w]+) (?<auth_key>[-_+.\w]+) (?<signature>[-_+.\w]+)/,
                             :auth_header_format => '%{auth_scheme} %{auth_key} %{signature}'
                           })
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params["username"] || params["password"]
    end

    def authenticate!
      username = params['username']
      password = params['password']
      cfg = Pgas.connection_config.merge('host' => 'localhost', 'username' => username, 'password'=> password)
      begin
        connection = ActiveRecord::Base.postgresql_connection(cfg)
        connection.execute 'select 1'
        user = { username: username, password: password }
        success!(user)
      rescue PG::Error => e
        fail!(e.message)
      end
    end
  end

  configure :development do
    register Sinatra::Reloader
    also_reload 'pgas/database'
  end

  def connection
    check_authentication
    user_params = {}
    if current_user.is_a? Hash
      user_params[:username] = current_user[:username]
      user_params[:password] = current_user[:password]
    end
    @connection ||= begin
                      cfg = Pgas.connection_config.merge({'host'=>'localhost'}).merge(user_params)
                      ActiveRecord::Base.postgresql_connection(cfg)
                    end
  end

  get '/' do
    slim :login
  end

  post '/login' do
    warden_handler.authenticate!(:password)
    if warden_handler.authenticated?
      redirect "/databases"
    else
      redirect "/"
    end
  end

  get '/logout' do
    warden_handler.logout
    redirect '/'
  end

  post "/unauthenticated" do
    redirect "/"
  end

  get '/databases' do
    @databases = Pgas::Database.all(connection)

    slim :databases
  end

  get '/databases.json' do
    @databases = Pgas::Database.all(connection)
    [200, @databases.inspect]
  end

  get %r[/databases/([^.]+).?(.*)?] do |name, format|
    @database = Pgas::Database.new(connection, name)
    case format
    when 'yml'
      [200, @database.to_yaml]
    else
      slim :database
    end
  end

  post '/databases' do
    name = params[:database_name].downcase
    template = params[:template].downcase
    comment = params[:comment]
    if template.present?
      @database = Pgas::Database.new(connection,template).clone(name, comment)
    else
      @database = Pgas::Database.new(connection,name,comment)
      @database.create
    end
    flash[:notice] = "Database #{@database.database_name} was created!"
    redirect "/databases/#{@database.database_name}"
  end

  delete %r[/databases/([^.]+).?(.*)?] do |name, format|
    @database = Pgas::Database.new(connection, name)
    @database.drop
    flash[:notice] = "Database #{@database.database_name} was droped!"
    redirect "/databases"
  end

  get '/roles' do
    @roles = Pgas::Role.all(connection)
    slim :roles
  end

  get '/roles/:name' do
    @role = Pgas::Role.new(connection, params[:name])
    slim :role
  end

  def warden_handler
    env['warden']
  end

  def current_user
    warden_handler.user
  end

  def check_authentication
    if request['Accept'] == 'application/json'
      warden_handler.authenticate!(:hmac_header, scope: :hmac)
    else
      redirect '/' unless warden_handler.authenticated?
    end
  end
end
