require_relative 'base_model'

class Clothing < BaseModel

  def self.all()
    sql_clothes = 'SELECT * FROM clothes'
    clothes = db.execute(sql_clothes)
    return clothes
  end

  def self.create(title, description, image)
    sql_clothes = 'INSERT INTO clothes (title, description, image) VALUES(?,?,?)'
    db.execute(sql_clothes, [title, description, image])
  end

  def self.create_relation(cloth_id, cat_id)
    sql_clothes = 'INSERT INTO cat_cloth_rel (cloth_id, cat_id) VALUES(?,?)'
    db.execute(sql_clothes, [cloth_id, cat_id])
  end

  def self.find(id)
    sql_clothes = 'SELECT * FROM clothes WHERE id =?'
    category = db.execute(sql_clothes, id).first
    return category
  end

  def self.find_by_title(title)
    category = db.execute('SELECT * FROM clothes WHERE title LIKE ?', title).first
    return category
  end

  def self.update(id, title, image, description)
    sql_clothes = 'UPDATE clothes SET title =?, image=?, description=? WHERE id =?'
    db.execute(sql_clothes, [title, image, description, id])
  end

  def self.destroy(id)
    db.execute('DELETE FROM cat_cloth_rel WHERE cloth_id =?', id)
    db.execute('DELETE FROM clothes WHERE id =?', id)
  end

end