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

    # Beskrivning: Etablerar en anslutning till SQLite-databasen och ser till att resultat returneras som hashar
    # Argument: Inga
    # Return: Ett SQLite3::Database-objekt
    # Datum: 2026-04-26
    # Namn: Hannes
    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end
    
    helpers do
      # Beskrivning: Kontrollerar om användaren befinner sig i en "cooldown"-period efter misslyckade inloggningsförsök
      # Argument: Inga (läser från session)
      # Return: Boolean (true om cooldown är aktiv, annars false)
      # Datum: 2026-04-26
      # Namn: Hannes
      def login_cooldown_active?
        if session[:last_login_attempt]
          fail_count = session[:fail_count] || 0
          required_wait = fail_count * 5 
        
          seconds_since_last_attempt = Time.now.to_i - session[:last_login_attempt].to_i
        
          if seconds_since_last_attempt < required_wait
            return true
          end
        end
        return false
      end
    end

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end

    # Beskrivning: Ett filter som körs innan varje route för att hämta data om den inloggade användaren
    # Datum: 2026-04-26
    # Namn: Hannes
    before do
      if session[:user_id]
        @current_user = User.find(session[:user_id])
        ap @current_user
      end
    end

    # Beskrivning: Root-route som omdirigerar besökaren till klädeslistan
    # Return: Redirect till /clothes
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/' do
      redirect('/clothes')
    end

    # Beskrivning: Hämtar och visar alla klädesplagg
    # Return: HTML-vy med alla kläder
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/clothes' do
      @clothes = Clothing.all
      erb(:"clothes/index")
    end

    # Beskrivning: Visar formuläret för att skapa ett nytt klädesplagg (kräver inloggning)
    # Return: HTML-vy med formulär eller redirect till login
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/clothes/new' do
      if session[:user_id]
        @category = Category.all
        erb(:"clothes/new")
      else
        redirect('/login')
      end
    end

    # Beskrivning: Tar emot data från formuläret och sparar ett nytt klädesplagg samt dess kategorikopplingar
    # Argument: params["title"], params["description"], params["image"], params["category_ids"]
    # Return: Redirect till /clothes
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/clothes' do
      if !session[:user_id]
        redirect '/login'
        return
      end

      title = params["title"]
      description = params["description"]
      image = params["image"]

      if title.empty? || description.empty? || image.empty?
        redirect '/clothes/new' 
        return
      end

      user_id = session[:user_id]
      new_id = Clothing.create(title, description, image, user_id)

      if params["category_ids"]
        params["category_ids"].each do |cat_id|
          Clothing.create_relation(new_id, cat_id)
        end
      end

      redirect '/clothes'
    end

    # Beskrivning: Visar information om ett specifikt klädesplagg
    # Argument 1: Integer som ID för plagget
    # Return: HTML-vy för det specifika plagget
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/clothes/:id' do | id |
      @clothes = Clothing.find(id)
      erb(:"clothes/show")
    end

    # Beskrivning: Visar redigeringsformulär för ett plagg (endast för ägaren eller admin)
    # Argument 1: Integer som ID för plagget
    # Return: HTML-vy för edit eller redirect till access denied
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/clothes/:id/edit' do | id |
      if @current_user && @current_user['id'] == Clothing.find(id)['user_id'] || @current_user['id'] == 1
        @clothes = Clothing.find(id)
        @category = Category.all
        @relation = Category.find_category_ids(id)
        erb(:"clothes/edit")
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Uppdaterar informationen för ett specifikt klädesplagg
    # Argument 1: Integer som ID för plagget
    # Argument 2: params["title"], params["description"], params["image"]
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post "/clothes/:id/update" do | id |
      if !session[:user_id]
        redirect '/login'
        return
      end

      title = params["title"]
      description = params["description"]
      image = params["image"]

      if title.empty? || description.empty? || image.empty?
        redirect '/clothes/new' 
        return
      end

      if @current_user && @current_user['id'] == Clothing.find(id)['user_id'] || @current_user['id'] == 1
        Clothing.update(id, title, image, description)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Raderar ett klädesplagg från databasen
    # Argument 1: Integer som ID för plagget
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/clothes/:id/delete' do |id|
      clothing = Clothing.find(id)
  
      if @current_user && @current_user['id'] == clothing['user_id'] || @current_user['id'] == 1
        Clothing.destroy(id)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Visar en lista på alla tillgängliga kategorier
    # Return: HTML-vy med alla kategorier
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/categories' do
      @categories = Category.all
      erb(:"categories/index")
    end

    # Beskrivning: Visar formulär för att skapa en ny kategori (endast för admin)
    # Return: HTML-vy eller redirect till access denied
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/categories/new' do
      if @current_user && @current_user['id'] == 1
        erb(:"categories/new")
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Skapar en ny kategori i databasen
    # Argument: params["name"]
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/categories' do
      if !session[:user_id]
        redirect '/login'
        return
      end

      name = params["name"]

      if name.empty?
        redirect '/categories/new'
        return
      end

      if @current_user && @current_user['id'] == 1
        Category.create(name)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Visar alla klädesplagg som tillhör en specifik kategori
    # Argument 1: Integer som ID för kategorin
    # Return: HTML-vy för den valda kategorin
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/categories/:id' do |id|
      @cat_piece = Category.find_items(id)
      erb(:"categories/show")
    end

    # Beskrivning: Visar formulär för att redigera en kategori (endast för admin)
    # Argument 1: Integer som ID för kategorin
    # Return: HTML-vy för edit eller redirect
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/categories/:id/edit' do | id |
      if @current_user && @current_user['id'] == 1
        @cat_edit = Category.find(id)
        erb(:"categories/edit")
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Uppdaterar namnet på en befintlig kategori
    # Argument 1: Integer som ID för kategorin
    # Argument 2: params["name"]
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post "/categories/:id/update" do | id |
      if !session[:user_id]
        redirect '/login'
        return
      end

      name = params["name"]

      if name.empty?
        redirect "/categories/#{id}/edit"
        return
      end

      if @current_user && @current_user['id'] == 1
        Category.update(id, name)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Raderar en kategori (endast för admin)
    # Argument 1: Integer som ID för kategorin
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/categories/:id/delete' do | id |
      if @current_user && @current_user['id'] == 1
        Category.destroy(id)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Visar en lista på alla registrerade användare
    # Return: HTML-vy med alla användare
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/users' do
      @users = User.all
      erb(:"users/index")
    end

    # Beskrivning: Visar formulär för att registrera ett nytt användarkonto
    # Return: HTML-vy för registrering
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/users/new' do
      erb(:"users/new")
    end

    # Beskrivning: Skapar en ny användare med hashat lösenord
    # Argument: params["username"], params["description"], params["password"]
    # Return: Redirect till login
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/users' do
      username = params["username"]
      description = params["description"]
      plain_password = params["password"]

      if username.empty? || description.empty? || plain_password.length < 8
        redirect '/users/new'
        return
      end

      hashed_password = BCrypt::Password.create(plain_password)

      User.create(username, hashed_password, description)
      redirect '/login'
    end

    # Beskrivning: Visar formulär för att redigera en användarprofil
    # Argument 1: Integer som ID för användaren
    # Return: HTML-vy för edit eller redirect
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/users/:id/edit' do |id|
      if !session[:user_id]
        redirect '/login'
        return
      end

      if @current_user && @current_user['id'] == id.to_i || @current_user['id'] == 1
        @user = User.find(id)
        erb(:"users/edit")
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Uppdaterar en användares information och valfritt lösenord
    # Argument 1: Integer som ID för användaren
    # Argument 2: params["username"], params["description"], params["password"], params["password_new"]
    # Return: Redirect till användarens profil
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/users/:id/update' do |id|

      if !session[:user_id]
        redirect '/login'
        return
      end

      username = params["username"]
      description = params["description"]
      request_plain_password = params["password"]

      if username.empty? || description.empty? || request_plain_password.empty?
        redirect "/users/#{id}/edit"
        return
      end

      user = User.find(id)
      db_password_hashed = user["password"].to_s
      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)

      if bcrypt_db_password == request_plain_password
        if params["password_new"] && !params["password_new"].empty?

          if params["password_new"].length < 8
            redirect "/users/#{id}/edit"  
            return
          end

          plain_password = params["password_new"]
          hashed_password = BCrypt::Password.create(plain_password)
          User.updatepassword(id, username, description, hashed_password)

        else

          User.update(id, username, description)

        end
      end
      redirect("/users/#{id}")
    end

    # Beskrivning: Visar en specifik användares profil och deras uppladdade kläder
    # Argument 1: Integer som ID för användaren
    # Return: HTML-vy för den valda användaren
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/users/:id' do |id|
      @user = User.find(id)
      @user_clothes = Clothing.find_by_user(id)
      erb(:"users/show")
    end

    # Beskrivning: Tar bort en användare (endast för ägaren eller admin)
    # Argument 1: Integer som ID för användaren
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/users/:id/delete' do |id|
      if @current_user && @current_user['id'] == id.to_i || @current_user['id'] == 1
        User.destroy(id)
        redirect('/')
      else
        redirect('/acces_denied')
      end
    end

    # Beskrivning: Visar administratörspanelen (endast för admin med ID 1)
    # Return: HTML-vy för admin eller redirect
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/admin' do
      if @current_user['id'] == 1
        erb(:"admin/index")
      else
        ap "/admin : Access denied."
        status 401
        redirect '/acces_denied'
      end
    end

    # Beskrivning: Visar en sida för nekad åtkomst
    # Return: HTML-vy "acces_denied"
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/acces_denied' do
      erb(:"users/acces_denied")
    end

    # Beskrivning: Visar inloggningsformuläret
    # Return: HTML-vy för inloggning
    # Datum: 2026-04-26
    # Namn: Hannes
    get '/login' do
      erb(:"users/login")
    end

    # Beskrivning: Validerar inloggningsuppgifter, hanterar BCrypt-jämförelse och sessionshantering
    # Argument: params[:username], params[:password]
    # Return: Redirect till /clothes vid framgång eller till access denied
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/login' do

      if login_cooldown_active?
        redirect '/acces_denied'
        return 
      end

      session[:last_login_attempt] = Time.now.to_i

      request_username = params[:username]
      request_plain_password = params[:password]
      user = User.find_by_username(request_username)

      unless user
        session[:fail_count] = (session[:fail_count] || 0) + 1
        status 401
        redirect '/acces_denied'
        return
      end
    
      bcrypt_db_password = BCrypt::Password.new(user["password"].to_s)

      if bcrypt_db_password == request_plain_password
        session[:user_id] = user["id"].to_i
        session[:fail_count] = 0
        redirect '/clothes'
      else
        session[:fail_count] = (session[:fail_count] || 0) + 1
        status 401
        redirect '/acces_denied'
      end
    end

    # Beskrivning: Loggar ut användaren genom att rensa session-hash
    # Return: Redirect till startsidan
    # Datum: 2026-04-26
    # Namn: Hannes
    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/'
    end

end