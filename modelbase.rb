require 'byebug'
require 'active_support/inflector'

class ModelBase
  attr_reader :table

  def initialize(table)
    @table = table
    # byebug
  end

  def self.table_name
    @table || self.name.underscore.pluralize
  end

  def self.find_by_id(id)
    table = self.table_name
    item = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      #{table}.*
    FROM
      #{table}
    WHERE
    id = ?
    SQL
    return nil unless item.length > 0
    self.new(item.first)
  end

  def self.all
    table = self.table_name
    items = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        #{table}.*
      FROM
        #{table}
      SQL
    return nil unless items.length > 0
    items.map{|item| self.new(item) }
  end

end
