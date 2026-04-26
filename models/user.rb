require_relative 'base_model'

class User < BaseModel

  # Beskrivning: Hämtar alla användare som finns i databasen
  # Argument: Inga
  # Return: Array med hashar där varje hash representerar en användare
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.all()
    sql_users = 'SELECT * FROM users'
    users = db.execute(sql_users)
    return users
  end

  # Beskrivning: Lägger till en ny användare i databasens users-tabell
  # Argument 1: String som användarnamn
  # Argument 2: String som det hashade lösenordet
  # Argument 3: String som beskrivning av användaren
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.create(username, password, description)
    sql_users = 'INSERT INTO users (username, password, description) VALUES(?,?,?)'
    db.execute(sql_users, [username, password, description])
  end

  # Beskrivning: Hämtar en specifik användare baserat på dess ID
  # Argument 1: Integer som representerar användarens ID
  # Return: En hash med användarens data, eller nil om den inte finns
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find(id)
    sql_users = 'SELECT * FROM users WHERE id =?'
    user = db.execute(sql_users, id).first
    return user
  end

  # Beskrivning: Hämtar en användare baserat på ett specifikt användarnamn
  # Argument 1: String som representerar användarnamnet
  # Return: En hash med användarens data
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find_by_username(username)
    sql_users = 'SELECT * FROM users WHERE username =?'
    user = db.execute(sql_users, username).first
    return user
  end

  # Beskrivning: Uppdaterar användarnamn och beskrivning för en befintlig användare
  # Argument 1: Integer som är ID på användaren som ska uppdateras
  # Argument 2: String med det nya användarnamnet
  # Argument 3: String med den nya beskrivningen
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.update(id, username, description)
    sql_users = 'UPDATE users SET username =?, description=? WHERE id =?'
    db.execute(sql_users, [username, description, id])
  end

  # Beskrivning: Uppdaterar användarnamn, beskrivning och lösenord för en användare
  # Argument 1: Integer som är ID på användaren som ska uppdateras
  # Argument 2: String med det nya användarnamnet
  # Argument 3: String med den nya beskrivningen
  # Argument 4: String med det nya hashade lösenordet
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.updatepassword(id, username, description, password)
    sql_users = 'UPDATE users SET username =?, description=?, password=? WHERE id =?'
    db.execute(sql_users, [username, description, password, id])
  end

  # Beskrivning: Raderar en användare och alla tillhörande klädesplagg
  # Argument 1: Integer som representerar användarens ID
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.destroy(id)
    sql_users = 'DELETE FROM users WHERE id =?'
    db.execute(sql_users, id)
    
    sql_clothes = 'SELECT id FROM clothes WHERE user_id =?'
    clothes = db.execute(sql_clothes, id)
    clothes.each do |cloth|
      Clothing.destroy(cloth['id'])
    end
  end

end