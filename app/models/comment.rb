class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true, touch: true

  validates :commentable_type, inclusion: { in: %w(Topic) }
  validates :commentable, :user, presence: true
  validates :body, presence: true

  after_destroy :delete_all_notifications

  def delete_all_notifications
  	notifications.delete_all
  end

  def page(per = Comment.default_per_page)
  	@page ||= ((commentable.comments.where("id < ?", id).count) / per + 1)
  end

  def mention_users
  	return @mention_users if defined?(@mention_users)


  	doc = Nokogiri::HTML.fragment(markdown(body))
  	usernames = doc.search('text()').map { |node|
  		unless node.ancestors('a, pre, code').any?
  			node.text.scan(/@([a-z0-9][a-z0-9-]*)/i).flatten
  		end
  	}.flatten.compact.uniq

  	@mention_users = User.where(username: usernames)
  end
end









end
