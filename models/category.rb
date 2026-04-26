require_relative 'base_model'

class Category < BaseModel

  # Beskrivning: Hämtar alla kategorier som finns lagrade i databasen
  # Argument: Inga
  # Return: Array med hashar där varje hash representerar en kategori
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.all()
    sql_categories = 'SELECT * FROM categories'
    categories = db.execute(sql_categories)
    return categories
  end

  # Beskrivning: Skapar en ny kategori i databasen
  # Argument 1: String som representerar namnet på kategorin
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.create(name)
    db.execute('INSERT INTO categories (name) VALUES (?)', name)
  end

  # Beskrivning: Hittar en specifik kategori baserat på dess ID
  # Argument 1: Integer som representerar kategorins ID
  # Return: En hash med kategorins data, eller nil om den inte hittas
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find(id)
    sql_categories = 'SELECT * FROM categories WHERE id =?'
    category = db.execute(sql_categories, id).first
    return category
  end

  # Beskrivning: Hämtar alla klädesplagg som är kopplade till en viss kategori via en join-tabell
  # Argument 1: Integer som representerar kategorins ID
  # Return: Array med hashar (alla clothes som har den kategorin)
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find_items(id)
    sql_categories = '
      SELECT * FROM clothes 
      INNER JOIN cat_cloth_rel
      ON clothes.id = cat_cloth_rel.cloth_id
      INNER JOIN categories
      ON cat_cloth_rel.cat_id = categories.id
      WHERE categories.id = ?
      '
    category = db.execute(sql_categories, id)
    return category
  end

  # Beskrivning: Söker efter en kategori baserat på dess namn
  # Argument 1: String som representerar namnet (t.ex. "Tröja")
  # Return: En hash med kategorins data
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find_by_title(name)
    category = db.execute('SELECT * FROM categories WHERE name LIKE ?', name).first
    return category
  end

  # Beskrivning: Hämtar alla kategori-ID:n som är kopplade till ett specifikt plagg
  # Argument 1: Integer som representerar plaggets (cloth) ID
  # Return: Array med integers (kategori-ID:n)
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.find_category_ids(id)
    db.execute('SELECT cat_id FROM cat_cloth_rel WHERE cloth_id =?', id).map { |row| row["cat_id"] }
  end

  # Beskrivning: Uppdaterar namnet på en befintlig kategori
  # Argument 1: Integer som representerar ID på kategorin som ska ändras
  # Argument 2: String med det nya namnet
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.update(id, name)
    db.execute('UPDATE categories SET name = ? WHERE id = ?', [name, id])
  end

  # Beskrivning: Tar bort en kategori från databasen helt
  # Argument 1: Integer som representerar ID på kategorin som ska raderas
  # Return: void
  # Datum: 2026-04-26
  # Namn: Hannes
  def self.destroy(id)
    db.execute('DELETE FROM categories WHERE id = ?', id)
  end

end