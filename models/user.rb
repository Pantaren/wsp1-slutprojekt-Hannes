require_relative 'base_model'

class User < BaseModel

  def self.all()
    sql_users = 'SELECT * FROM users'
    users = db.execute(sql_users)
    return users
  end

  def self.create(username, password, description)
    sql_users = 'INSERT INTO users (username, password, description) VALUES(?,?,?)'
    db.execute(sql_users, [username, password, description])
  end

  def self.find(id)
    sql_users = 'SELECT * FROM users WHERE id =?'
    user = db.execute(sql_users, id).first
    return user
  end

  def self.find_by_username(username)
    sql_users = 'SELECT * FROM users WHERE username =?'
    user = db.execute(sql_users, username).first
    return user
  end

  def self.update(id, username, description)
    sql_users = 'UPDATE users SET username =?, description=? WHERE id =?'
    db.execute(sql_users, [username, description, id])
  end

  def self.updatepassword(id, username, description, password)
    sql_users = 'UPDATE users SET username =?, description=?, password=? WHERE id =?'
    db.execute(sql_users, [username, description, password, id])
  end

  def self.destroy(id)
    sql_users = 'DELETE FROM users WHERE id =?'
    db.execute(sql_users, id)
    
    sql_clothes = 'SELECT id FROM clothes WHERE user_id =?'
    clothes = db.execute(sql_clothes, id)
    clothes.each do |cloth|
      sql_cloth_rel = 'DELETE FROM cat_cloth_rel WHERE cloth_id =?'
      db.execute(sql_cloth_rel, cloth['id'])
    end

    sql_clothes = 'DELETE FROM clothes WHERE user_id =?'
    db.execute(sql_clothes, id)
  end

end