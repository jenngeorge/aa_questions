
require_relative 'questiondatabase.rb'
require_relative 'questions.rb'
require_relative 'modelbase'

class User < ModelBase
  attr_accessor :fname, :lname
  attr_reader :id, :table

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
    super('users')

  end

  # def self.all
  #   people = QuestionsDatabase.instance.execute("SELECT * FROM users")
  #   people.map {|person| User.new(person)}
  # end

  # include DBMethods

  # def self.find_by_id(id)
  #   user = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       users
  #     WHERE
  #       id = ?
  #     SQL
  #     return nil unless user.length > 0
  #     User.new(user.first)
  # end


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

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    user_id_to_use = self.id
    karma = QuestionsDatabase.instance.execute(<<-SQL, user_id_to_use)
    SELECT
      -- COUNT(DISTINCT(question_likes.question_id))
      -- COUNT(question_likes.id IS NOT NULL)
      CAST(COUNT(question_likes.id IS NOT NULL) AS FLOAT) / COUNT(DISTINCT(question_likes.question_id))
    FROM
      users
    LEFT OUTER JOIN
      question_likes ON question_likes.user_id = users.id
      WHERE
      users.id = ?
    SQL
  end

  def save
    @id.nil? ? self.insert : self.update
  end

  def insert
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
      SQL
  end

end
