require 'sinatra'
require 'rack'
require 'slim'
require "sinatra/reloader"
require 'rack-flash'

class Pgas::RestApi < Sinatra::Application
  set :views, settings.root + '/../../views'
  enable :sessions
  use Rack::Flash

  configure :development do
    register Sinatra::Reloader
    also_reload 'pgas/database'
  end

  before '/databases/*' do
    redirect '/' unless session[:username]
  end

  def connection
    @connection ||= begin
                      cfg = Pgas.connection_config.merge('host'=>'localhost', 'username' => session[:username], 'password'=> session[:password])
                      ActiveRecord::Base.postgresql_connection(cfg)
                    end
  end

  get '/' do
    slim :login
  end

  post '/login' do
    cfg = Pgas.connection_config.merge('host' => 'localhost', 'username' => params[:username], 'password'=> params[:password])
    begin
    connection = ActiveRecord::Base.postgresql_connection(cfg)
    connection.execute 'select 1'
    session[:username] = params[:username]
    session[:password] = params[:password]
    redirect '/databases'
    rescue PG::Error => e
      flash[:error] = e.message
      redirect '/'
    end
  end

  get '/logout' do
    session[:username] = nil
    session[:password] = nil
    redirect '/'
  end

  get '/databases' do
    @databases = Pgas::Database.all(connection)
    slim :databases
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
    @database = Pgas::Database.new(connection,name,params[:comment])
    @database.create
    flash[:notice] = "Database #{@database.database_name} was created!"
    redirect "/databases/#{@database.database_name}"
  end

  delete %r[/databases/([^.]+).?(.*)?] do |name, format|
    @database = Pgas::Database.new(connection, name)
    @database.drop
    flash[:notice] = "Database #{@database.database_name} was droped!"
    redirect "/databases"
  end
end
