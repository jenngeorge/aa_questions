require_relative 'questiondatabase.rb'
require_relative 'users'


class QuestionLike
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.all
    questions = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    questions.map {|question| QuestionLike.new(question)}
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
      SQL
      return nil unless question.length > 0
      QuestionLike.new(question.first)
  end
  # include DBMethods

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      JOIN
        users ON question_likes.user_id = users.id
      WHERE
        question_id = ?
      SQL
      return nil unless users.length > 0
      users.map {|user| User.new(user)}
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(user_id)
      FROM
        question_likes
      JOIN
        users ON question_likes.user_id = users.id
      WHERE
        question_id = ?
      SQL
      count[0].values.first
    end

    def self.liked_questions_for_user_id(user_id)
      questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
          *
        FROM
          question_likes
        JOIN
          questions ON question_likes.question_id = questions.id
        WHERE
          question_likes.user_id = ?
        SQL
        return nil unless questions.length > 0
        questions.map {|question| Question.new(question)}
      end
end
