require_relative 'user'


class Question < SuperClass
  attr_accessor :title, :body, :user_id

  def self.all
    super('questions', self)
  end

  def self.find_by_id(id)
    super(id, self, 'questions')
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL
    questions.map { |question_hsh| Question.find_by_id(question_hsh['id'])}

  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options ['body']
    @user_id = options['user_id']
  end

  def most_liked(n)
    Like.most_liked_questions(n)
  end

  def create
    raise "#{self} exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
    INSERT INTO
      questions (title, body, user_id)
    VALUES
      (? , ? , ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    Like.likers_for_question_id(@id)
  end

  def num_likes
    Like.num_likes_for_question_id(@id)
  end

end
