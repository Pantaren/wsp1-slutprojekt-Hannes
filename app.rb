require 'debug'
require "awesome_print"
require 'sinatra'
require 'securerandom'
require 'bcrypt'
require_relative 'models/base_model'
require_relative 'models/clothing'
require_relative 'models/category'
require_relative 'models/user'

class App < Sinatra::Base

    setup_development_features(self)

    # Funktion för att prata med databasen
    # Exempel på användning: db.execute('SELECT * FROM fruits')
    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end

    before do
      if session[:user_id]
        @current_user = User.find(session[:user_id])
        ap @current_user
      end
    end

    get '/' do
      redirect('/clothes')
    end

    get '/clothes' do
      @clothes = Clothing.all
      erb(:"clothes/index")
    end

    get '/clothes/new' do
      @category = Category.all
      erb(:"clothes/new")
    end

    post '/clothes' do
      if session[:user_id]
        title = params["title"]
        description = params["description"]
        image = params["image"]
        user_id = session[:user_id]

        new_id = Clothing.create(title, description, image, user_id) 

        if params["category_ids"]
          params["category_ids"].each do |cat_id|
          Clothing.create_relation(new_id, cat_id)
        end
        redirect('/clothes')
      else
        redirect('/login')
      end
      end
    end

    get '/clothes/:id' do | id |
      @clothes = Clothing.find(id)
      erb(:"clothes/show")
    end

    get '/clothes/:id/edit' do | id |
      @clothes = Clothing.find(id)
      @category = Category.all
      @relation = Category.find_category_ids(id)
      p @relation
      p "----------------------------------------------------------------------"
      erb(:"clothes/edit")
    end

    post "/clothes/:id/update" do | id |
      title = params["title"]
      description = params["description"]
      image = params["image"]

      Clothing.update(id, title, image, description)
      redirect('/')
    end

    post '/clothes/:id/delete' do |id|
      clothing = Clothing.find(id)
  
      if @current_user && @current_user['id'] == clothing['user_id']
        Clothing.destroy(id)
        redirect('/')
      else
        redirect('/acces_denied') # 
      end
    end

    get '/categories' do
      @categories = Category.all
      erb(:"categories/index")
    end

    get '/categories/new' do
      if @current_user && @current_user['id'] == 1
        erb(:"categories/new")
      else
        redirect('/acces_denied')
      end
    end

    post '/categories' do
      if @current_user && @current_user['id'] == 1
        name = params["name"]
        Category.create(name)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    get '/categories/:id' do |id|
      @cat_piece = Category.find_items(id)
      erb(:"categories/show")
    end

    get '/categories/:id/edit' do | id |
      if @current_user && @current_user['id'] == 1
        @cat_edit = Category.find(id)
        erb(:"categories/edit")
      else
        redirect('/acces_denied')
      end
    end

    post "/categories/:id/update" do | id |
      name = params["name"]
      if @current_user && @current_user['id'] == 1
        Category.update(id, name)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    post '/categories/:id/delete' do | id |
      if @current_user && @current_user['id'] == 1
        Category.destroy(id)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    get '/users' do
      @users = User.all
      erb(:"users/index")
    end

    get '/users/new' do
      erb(:"users/new")
    end

    post '/users' do
      username = params["username"]
      description = params["description"]
      plain_password = params["password"]
      hashed_password = BCrypt::Password.create(plain_password)

      User.create(username, hashed_password, description)
      redirect '/login'
    end

    get '/users/:id/edit' do |id|
      @user = User.find(id)
      erb(:"users/edit")
    end

    post '/users/:id/update' do |id|
      username = params["username"]
      description = params["description"]
      request_plain_password = params["password"]

      user = User.find(id)
      db_password_hashed = user["password"].to_s
      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)

      if bcrypt_db_password == request_plain_password
        if params["password_new"] && !params["password_new"].empty?
          plain_password = params["password_new"]
          hashed_password = BCrypt::Password.create(plain_password)
          User.updatepassword(id, username, description, hashed_password)
        else
          User.update(id, username, description)
        end
      end
      redirect("/users/#{id}")
    end

    get '/users/:id' do |id|
      @user = User.find(id)
      @user_clothes = Clothing.find_by_user(id)
      erb(:"users/show")
    end

    post '/users/:id/delete' do |id|
      User.destroy(id)
      redirect('/')
    end

    get '/admin' do
      if session[:user_id]
        erb(:"admin/index")
      else
        ap "/admin : Access denied."
        status 401
        redirect '/acces_denied'
      end
    end

    get '/acces_denied' do
      erb(:"users/acces_denied")
    end

    get '/login' do
      erb(:"users/login")
    end

    post '/login' do
      request_username = params[:username]
      request_plain_password = params[:password]

      user = User.find_by_username(request_username)

      unless user
        ap "/login : Invalid username."
        status 401
        redirect '/acces_denied'
      end

      db_id = user["id"].to_i
      db_password_hashed = user["password"].to_s

      # Create a BCrypt object from the hashed password from db
      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
      # Check if the plain password matches the hashed password from db
      if bcrypt_db_password == request_plain_password
        session[:user_id] = db_id
        redirect '/clothes'
      else
        ap "/login : Invalid password."
        status 401
        redirect '/acces_denied'
      end
    end

    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/'
    end

end
