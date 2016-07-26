
require_relative 'questiondatabase.rb'

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.all
    people = QuestionsDatabase.instance.execute("SELECT * FROM users")
    people.map {|person| User.new(person)}
  end

  # include DBMethods

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
      SQL
      return nil unless user.length > 0
      User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    hash = Hash.new
    hash[:fname] = fname
    hash[:lname] = lname
    person = QuestionsDatabase.instance.execute(<<-SQL, hash)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = :fname AND users.lname = :lname
      SQL
      return nil unless person.length > 0
      User.new(person.first)
  end

end
