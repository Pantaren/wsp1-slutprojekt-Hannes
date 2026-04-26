require_relative 'base_model'

class Clothing < BaseModel

  # Beskrivning: Hämtar alla klädesplagg som finns lagrade i databasen
  # Argument: Inga
  # Return: Array med hashar där varje hash representerar ett klädesplagg
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.all()
    sql_clothes = 'SELECT * FROM clothes'
    clothes = db.execute(sql_clothes)
    return clothes
  end

  # Beskrivning: Skapar ett nytt klädesplagg i databasen
  # Argument 1: String som är titeln på plagget
  # Argument 2: String som är beskrivningen av plagget
  # Argument 3: String som är filnamnet/URL till bilden
  # Argument 4: Integer som är ID för användaren som skapar plagget
  # Return: Integer (ID:t för det nyskapade plagget)
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.create(title, description, image, user_id)
    sql_clothes = 'INSERT INTO clothes (title, description, image, user_id) VALUES(?,?,?,?)'
    db.execute(sql_clothes, [title, description, image, user_id])

    return db.last_insert_row_id
  end

  # Beskrivning: Skapar en relation mellan ett klädesplagg och en kategori i en join-tabell
  # Argument 1: Integer som är ID för klädesplagget
  # Argument 2: Integer som är ID för kategorin
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.create_relation(cloth_id, cat_id)
    sql_clothes = 'INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES(?,?)'
    db.execute(sql_clothes, [cloth_id, cat_id])
  end

  # Beskrivning: Hittar ett specifikt klädesplagg baserat på dess ID
  # Argument 1: Integer som representerar plaggets ID
  # Return: En hash med plaggets data, eller nil om det inte hittas
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find(id)
    sql_clothes = 'SELECT * FROM clothes WHERE id =?'
    category = db.execute(sql_clothes, id).first
    return category
  end

  # Beskrivning: Söker efter ett klädesplagg baserat på dess titel
  # Argument 1: String som representerar titeln (söksträng)
  # Return: En hash med plaggets data
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find_by_title(title)
    category = db.execute('SELECT * FROM clothes WHERE title LIKE ?', title).first
    return category
  end

  # Beskrivning: Hämtar alla klädesplagg som tillhör en specifik användare
  # Argument 1: Integer som representerar användarens ID
  # Return: Array med hashar (alla plagg användaren skapat)
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find_by_user(user_id)
    sql_clothes = 'SELECT * FROM clothes WHERE user_id =?'
    clothes = db.execute(sql_clothes, user_id)
    return clothes
  end

  # Beskrivning: Uppdaterar informationen för ett befintligt klädesplagg
  # Argument 1: Integer som är ID på plagget som ska ändras
  # Argument 2: String med den nya titeln
  # Argument 3: String med den nya bilden
  # Argument 4: String med den nya beskrivningen
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.update(id, title, image, description)
    sql_clothes = 'UPDATE clothes SET title =?, image=?, description=? WHERE id =?'
    db.execute(sql_clothes, [title, image, description, id])
  end

  # Beskrivning: Tar bort ett klädesplagg och alla dess kategorikopplingar från databasen
  # Argument 1: Integer som representerar ID på plagget som ska raderas
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.destroy(id)
    sql_clothes = 'DELETE FROM clothes WHERE id =?'
    db.execute(sql_clothes, id)

    sql_relation = 'DELETE FROM cat_cloth_rel WHERE cloth_id =?'
    db.execute(sql_relation, id)
  end

end