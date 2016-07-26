require_relative 'questiondatabase.rb'


class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.all
    questions = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    questions.map {|question| Question.new(question)}
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
      SQL
      return nil unless question.length > 0
      Question.new(question.first)
  end
  # include DBMethods

end
