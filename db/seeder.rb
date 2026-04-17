require 'sqlite3'
require_relative '../config'
require 'bcrypt'

class Seeder

  def self.seed!
    puts "Using db file: #{DB_PATH}"
    puts "🧹 Dropping old tables..."
    drop_tables
    puts "🧱 Creating tables..."
    create_tables
    puts "🍎 Populating tables..."
    populate_tables
    puts "✅ Done seeding the database!"
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS clothes')
    db.execute('DROP TABLE IF EXISTS categories')
    db.execute('DROP TABLE IF EXISTS cat_cloth_rel')
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
    db.execute('CREATE TABLE clothes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                image TEXT NOT NULL, 
                description TEXT)')
    
    db.execute('CREATE TABLE categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL)')

    db.execute('CREATE TABLE cat_cloth_rel (
                cloth_id INTEGER,
                cat_id INTEGER)')

    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                password TEXT NOT NULL)')
  end
    


  def self.populate_tables
    db.execute('INSERT INTO clothes (title, description, image) VALUES ("Samis vita tröja", "Vit tröja med svarta detaljer. Kan möjligen lukta lite lätt av kebab och buldak noodles", "glhf.png")')
    db.execute('INSERT INTO clothes (title, description, image) VALUES ("Banan, använd", "En lite lätt använd banan, bra skick", "glhf.png")')
    db.execute('INSERT INTO clothes (title, description, image) VALUES ("Figges Nudie jeans", "Ett par blåa Nudie jeans i nästan nyköpt skick, bara lite utvidgade kring gutten", "glhf.png")')
    db.execute('INSERT INTO clothes (title, description, image) VALUES ("Samis strumpa", "En vit strumpa, lite krispig?", "glhf.png")')
    db.execute('INSERT INTO clothes (title, description, image) VALUES ("Ahmads svarta jeans", "Om man kollar noga kan man se kvarlevorna av folkmordet den förra ägaren begått mot falaflar", "glhf.png")')

    db.execute('INSERT INTO categories (name) VALUES ("Tröja")')
    db.execute('INSERT INTO categories (name) VALUES ("Byxa")')
    db.execute('INSERT INTO categories (name) VALUES ("Hatt")')
    db.execute('INSERT INTO categories (name) VALUES ("Vit")')
    db.execute('INSERT INTO categories (name) VALUES ("Svart")')

    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (1,1)')
    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (1,4)')
    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (2,3)')
    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (3,2)')
    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (4,4)')
    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (5,2)')
    db.execute('INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES (5,5)')

    password_hashed = BCrypt::Password.create("123")
    p "Storing hashed password (#{password_hashed}) to DB. Clear text password (123) never saved."
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Hannes", password_hashed])
  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

end

Seeder.seed!