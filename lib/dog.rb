class Dog

  attr_accessor :name,:breed,:id

  def initialize(id: nil, name:, breed:)
    self.id = id
    self.name = name
    self.breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL

      DB[:conn].execute(sql)
  end

  def self.new_from_db(dog_info)
    self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
  end

  def self.find_by_name(name)
    dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1",name)
    self.new_from_db(dog_info[0])
  end

  def self.find_by_id(id)
    dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",id)
    self.new(id: dog_info[0][0], name: dog_info[0][1], breed: dog_info[0][2])
  end

  def save
    if self.id != nil
      self.update
      self
    else
      DB[:conn].execute("INSERT INTO dogs(name,breed) VALUES (?,?)",self.name,self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_or_create_by(name:, breed:)
    dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name,breed)
    if dog_info.empty?
      self.create(name: name, breed: breed)
    else
      self.new(id: dog_info[0][0], name: dog_info[0][1], breed: dog_info[0][2])
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",self.name,self.breed,self.id)[0]
  end

end
