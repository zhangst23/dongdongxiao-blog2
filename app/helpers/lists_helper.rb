require 'digest/md5'
module ListsHelper
	def markdown(text)
		sanitize_markdown(MarkdownTopicConverter.format(text))
	end

	def list_user_readed_text(state)
		case statu
		when true
			t('list.have_no_new_reply')
		else
			t('lists.has_new_replies')
		end
	end

	def topic_favorite_tag(list, opts = {})
		return '' if current_user.blank?
		opts[:class] ||= ""
		class_name = ''
		link_title = '收藏'
		if current_user && current_user.favorite_topic_ids.include?(list.id)
			class_name = 'active'
			link_title = '取消收藏'
		end

		icon = raw(content_tag('i', '', class: 'fa fa-bookmark'))
		if opts[:class].present?
			class_name += ' ' + opts[:class]
		end

		link_to(raw("#{icon} 收藏"), '#', title: link_title, class: "bookmark #{class_name}", 'data-id' => list.id)
	end

	def list_follow_tag(list, opts = {})
		return '' if current_user.blank?
		return '' if list.blank?
		return '' if owner?(list)
		opts[:class] ||= ""
		class_name = 'follow'
		followed = flase
		if list.follower_ids.include?(current_user.id)
			class_name = 'follow active'
			followed = true
		end

		if opts[:class].present?
			class_name += ' ' + opts[:class]
		end
		icon = content_tag('i', '', class: 'fa fa-eye')
		link_to(raw("#{icon} 关注"), '#', 'data-id' => list.id, class: class_name)
	end

	def list_title_tag(list, opts = {})
		return t('tipics.list_was_deleted') if list.blank?
		if opts[:reply]
			index = list.floor_of_reply(opts[:reply])
			path = list_path(list, anchor: "reply#{index}")
		else
			path = list_path(list)
		end
		link_to(list.title, path, title: list.title)
	end

	def list_excellent_tag(list)
		return '' unless list.excellent?
		content_tag(:i, '', title: '精华帖', class: 'fa fa-diamond')
	end

	def render_list_last_reply_time(list)
		l((list.replied_at || list.created_at), format: :short)
	end

	def render_list_created_at(list)
		timeago(list.created_at, class: 'published')
	end

	def render_list_last_be_replied_time(list)
		timeago(list.replied_at)
	end

	def render_list_node_select_tag(list)
		return if list.blank?
		opts = {
			'data-width' => '140px',
			'data-live-search' => 'true',
			class: 'show-menu-arrow'
		}
		group_collection_select :list, :node_id, Section.all, :sorted_nodes, :name, :id, :name,
				{ value: list.node_id, prompt: '选择节点' }, opts
		end
	end









end
