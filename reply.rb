require_relative 'questiondatabase.rb'


class Reply
  attr_accessor :title, :body, :user_id
  attr_reader :id, :question_id, :parent_id

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.all
    replies = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
      SQL
      return nil unless reply.length > 0
      Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies  = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
       *
      FROM
        replies
      WHERE
        user_id = ?
      SQL
    return nil unless replies.length  > 0
    replies.map {|reply| Reply.new(reply)}
  end
  # include DBMethods

  def self.find_by_question_id(question_id)
    replies  = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
       *
      FROM
        replies
      WHERE
        question_id = ?
      SQL
    return nil unless replies.length  > 0
    replies.map {|reply| Reply.new(reply)}
  end

  def author
    id_to_check = self.user_id
    replies  = QuestionsDatabase.instance.execute(<<-SQL, id_to_check)
      SELECT
       *
      FROM
        users
      WHERE
        id = ?
      SQL
    return nil unless replies.length  > 0
    Reply.new(replies.first)
  end

  def question
    id_to_check = self.question_id
    replies  = QuestionsDatabase.instance.execute(<<-SQL, id_to_check)
      SELECT
       *
      FROM
        questions
      WHERE
        id = ?
      SQL
    return nil unless replies.length  > 0
    Reply.new(replies.first)
  end

  def child_replies
    id_to_check = self.id
    replies  = QuestionsDatabase.instance.execute(<<-SQL, id_to_check)
      SELECT
       *
      FROM
        replies
      WHERE
        parent_id = ?
      SQL
    return nil unless replies.length  > 0
    replies.map {|reply| Reply.new(reply)}
  end

  def save
    @id.nil? ? self.insert : self.update
  end

  def insert
    QuestionsDatabase.instance.execute(<<-SQL, @body, @parent_id, @question_id, @user_id)
      INSERT INTO
        replies (body, parent_id, question_id, user_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @body, @parent_id, @question_id, @user_id, @id)
      UPDATE
        replies
      SET
        body = ?, parent_id = ?, question_id = ?, user_id = ?
      WHERE
        id = ?
      SQL
  end

end
