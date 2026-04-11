require_relative 'base_model'

class Category < BaseModel

  def self.all()
    sql_categories = 'SELECT * FROM categories'
    categories = db.execute(sql_categories)
    return categories
  end

  def self.create(name)
    db.execute('INSERT INTO categories (name) VALUES (?)', name)
  end

  def self.find(id)
    sql_categories = 'SELECT * FROM categories WHERE id =?'
    category = db.execute(sql_categories, id).first
    return category
  end

  def self.find_items(id)
    sql_categories = '
      SELECT * 
      FROM clothes 
      INNER JOIN cat_cloth_rel
      ON clothes.id = cat_cloth_rel.cloth_id
      INNER JOIN categories
      ON cat_cloth_rel.cat_id = categories.id
      WHERE categories.id = ?
      '
    category = db.execute(sql_categories, id)
    return category
  end

  def self.find_by_title(name)
    category = db.execute('SELECT * FROM categories WHERE name LIKE ?', name).first
    return category
  end

  def self.update(id, name)
    sql = 'UPDATE categories SET name =? WHERE id =?'
    db.execute(sql, [name, id])
  end

  def self.destroy(id)
    db.execute('DELETE FROM cat_cloth_rel WHERE cat_id =?', id)
    db.execute('DELETE FROM categories WHERE id =?', id)
  end

end