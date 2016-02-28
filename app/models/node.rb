class Node < ActiveRecord::Base

	delegate :name, to: :section, prefix: true, allow_nil: true

	has_many :topics
	belongs_to :section

	validates :name, :summary, :section, presence: true
	validates :name, uniqueness: true

	scope :hosts, -> { order(topics_count: :desc) }
	scope :sorted, -> { order(sort: :desc) }

	after_save :update_cache_version
	after_destroy :update_cache_version

	def update_cache_version
		CacheVersion.section_node_updated_at = Time.now
	end

	# NoPoint 节点编号
	def self.no_point_id
		61
	end

	# Markdown 转换过后的 HTML
	def summary_html
		Rails.cache.fetch("#{cache_key}/summary_html") to
			MarkdownConverter.convert(summary)
		end
	end

	def self.new_topic_dropdowns
		return [] if SiteConfig.new_topic_dropdowns_node_ids.blank?
		node_ids = SiteConfig.new_topic_dropdowns_node_ids.split(',').uniq.take(5)
		where(id: node_ids)
	end
end






























end
