require_relative 'questiondatabase.rb'
require_relative 'reply'

# module DBMethods
#   def self.all(table)
#     items = QuestionsDatabase.instance.execute("SELECT * FROM #{table}")
#     items.map {|question| self.new(item)}
#   end
#
#   def self.find_by_id(id, table)
#     items = QuestionsDatabase.instance.execute(<<-SQL, @id)
#       SELECT
#         *
#       FROM
#         table
#       WHERE
#         id = ?
#       SQL
#       return nil unless items.length > 0
#       self.new(item.first)
#   end
#
# end

class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  # def self.all
  #   questions = QuestionsDatabase.instance.execute("SELECT * FROM questions")
  #   questions.map {|question| Question.new(question)}
  # end
  #
  # def self.find_by_id(id)
  #   question = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       questions
  #     WHERE
  #       id = ?
  #     SQL
  #     return nil unless question.length > 0
  #     Question.new(question.first)
  # end

  def self.find_by_author_id(author_id)
    questions  = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
       *
      FROM
        questions
      WHERE
        user_id = ?
      SQL
    return nil unless questions.length  > 0
    questions.map {|question| Question.new(question)}
  end
  # include DBMethods

  def author
    id_to_check = self.user_id
    name = QuestionsDatabase.instance.execute(<<-SQL, id_to_check)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    User.new(name.first)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def save
    @id.nil? ? self.insert : self.update
  end

  def insert
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
      SQL
  end

end
