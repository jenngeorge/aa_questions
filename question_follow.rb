require_relative 'questiondatabase.rb'
require_relative 'users'
require_relative 'questions'

class QuestionFollow
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end


  def self.all
    questions = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    questions.map {|question| QuestionFollow.new(question)}
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
      SQL
      return nil unless question.length > 0
      QuestionFollow.new(question.first)
  end
  # include DBMethods

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        users ON (question_follows.user_id = users.id)
      WHERE
        question_follows.question_id = ?
      SQL
      return nil unless users.length > 0
      users.map {|user| User.new(user)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions ON (questions.user_id = question_follows.user_id)
      WHERE
        question_follows.user_id = ?
      SQL
      return nil unless questions.length > 0
      questions.map {|question| Question.new(question)}
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
       *
      FROM
        question_follows
      GROUP BY
        question_id
      ORDER BY
        COUNT(user_id)
      LIMIT ?
      SQL
      return nil unless questions.length > 0
      questions.map {|question| QuestionFollow.new(question)}
  end

end
