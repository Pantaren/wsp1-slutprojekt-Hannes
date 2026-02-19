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
      erb(:index)
    end

    get '/clothes/:id' do | id |
      @article = db.execute('SELECT * FROM clothes WHERE id = ?', id).first
      p @fruit
      erb(:"show")
    end

end
