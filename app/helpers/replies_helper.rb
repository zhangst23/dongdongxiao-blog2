module RepliesHelper

	def render_reply_at(reply)
		l(reply.create_at, format: :short)
	end
end
