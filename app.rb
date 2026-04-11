require 'debug'
require "awesome_print"
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
      title = params["title"]
      description = params["description"]
      image = params["image"]
      Clothing.create(title, description, image)

      new_id = db.last_insert_row_id
      if params["category_ids"]
        params["category_ids"].each do |cat_id|
          Clothing.create_relation(new_id, cat_id)
        end
      end

      redirect('/clothes')
    end

    get '/clothes/:id' do | id |
      @clothes = Clothing.find(id)
      erb(:"clothes/show")
    end

    get '/clothes/:id/edit' do | id |
      @clothes = Clothing.find(id)
      erb(:"clothes/edit")
    end

    post "/clothes/:id/update" do | id |
      title = params["title"]
      description = params["description"]
      image = params["image"]

      Clothing.update(id, title, image, description)
      redirect('/')
    end

    post '/clothes/:id/delete' do | id |
      Clothing.destroy(id)
      redirect('/')
    end

    get '/categories' do
      @categories = Category.all
      erb(:"categories/index")
    end

    get '/categories/new' do
      erb(:"categories/new")
    end

    post '/categories' do
      name = params["name"]
      Category.create(name)
      redirect('/')
    end

    get '/categories/:id' do |id|
      @cat_piece = Category.find_items(id)
      erb(:"categories/show")
    end

    get '/categories/:id/edit' do | id |
      @cat_edit = Category.find(id)
      erb(:"categories/edit")
    end

    post "/categories/:id/update" do | id |
      name = params["name"]

      Category.update(id, name)
      redirect('/')
    end

    post '/categories/:id/delete' do | id |
      Category.destroy(id)
      redirect('/')
    end


end
