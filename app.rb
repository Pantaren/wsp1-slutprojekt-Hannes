require 'debug'
require "awesome_print"

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

    # Routen /
    get '/' do
      @clothes = db.execute('SELECT * FROM clothes')
      erb(:"clothes/index")
    end

    get '/clothes/new' do
      @category = db.execute('SELECT * FROM categories')
      erb(:"clothes/new")
    end

    post '/clothes' do
      title = params["title"]
      description = params["description"]
      image = params["image"]
      db.execute('INSERT INTO clothes (title, description, image) VALUES(?,?,?)', [title, description, image])

      new_id = db.last_insert_row_id
      ap params
      if params["category_ids"]
        params["category_ids"].each do |cat_id|
          db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES(?,?)', [new_id, cat_id])
        end
      end
      redirect('/')
    end

    get '/clothes/:id' do | id |
      @article = db.execute('SELECT * FROM clothes WHERE id = ?', id).first
      erb(:"clothes/show")
    end

    get '/clothes/:id/edit' do | id |
      @piece = db.execute('SELECT * FROM clothes WHERE id = ?', id).first
      erb(:"clothes/edit")
    end

    post "/clothes/:id/update" do | id |
      title = params["title"]
      description = params["description"]
      image = params["image"]

      db.execute('UPDATE clothes SET title =?, image=?, description=? WHERE id =?', [title, image, description, id])
      redirect('/')
    end

    post '/clothes/:id/delete' do | id |
      db.execute('DELETE FROM clothes WHERE id = ?', id).first
      redirect('/')
    end

    get '/categories' do
      @categories = db.execute('SELECT * FROM categories')
      erb(:"categories/index")
    end

        get '/categories/new' do
      erb(:"categories/new")
    end

    post '/categories' do
      name = params["name"]
      db.execute('INSERT INTO categories (name) VALUES(?)', [name])
      redirect('/')
    end

    get '/categories/:id' do |id|
      @cat_piece = db.execute('
      SELECT * 
      FROM clothes 
      INNER JOIN cat_cloth_rel
      ON clothes.id = cat_cloth_rel.cloth_id
      INNER JOIN categories
      ON cat_cloth_rel.cat_id = categories.id
      WHERE categories.id = ?
      ', id)
      erb(:"categories/show")
    end

    get '/categories/:id/edit' do | id |
      @cat_edit = db.execute('SELECT * FROM categories WHERE id = ?', id).first
      erb(:"categories/edit")
    end

    post "/categories/:id/update" do | id |
      name = params["name"]

      db.execute('UPDATE categories SET name =? WHERE id =?', [name, id])
      redirect('/')
    end

    post '/categories/:id/delete' do | id |
      db.execute('DELETE FROM categories WHERE id = ?', id).first
      redirect('/')
    end


end
