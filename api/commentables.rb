delete "#{APIPREFIX}/:commentable_id/threads" do |commentable_id|
  commentable.comment_threads.destroy_all
  {}.to_json
end

get "#{APIPREFIX}/:commentable_id/threads" do |commentable_id|
  threads = Content.where(_type:"CommentThread", commentable_id: commentable_id)
  group_ids = []
  group_ids << params["group_id"].to_i if params["group_id"]
  group_ids.concat(params["group_ids"].split(",").map(&:to_i)) if params["group_ids"]
  if not group_ids.empty?
    threads = threads.any_of(
      {:group_id.in => group_ids},
      {:group_id.exists => false},
    )
  end
    handle_threads_query(threads)    
end

post "#{APIPREFIX}/:commentable_id/threads" do |commentable_id|
  thread = CommentThread.new(params.slice(*%w[title body course_id ]).merge(commentable_id: commentable_id))
  thread.anonymous = bool_anonymous || false
  thread.anonymous_to_peers = bool_anonymous_to_peers || false
  
  if params["group_id"]
    thread.group_id = params["group_id"]
  end
  
  thread.author = user
  filter_blocked_content thread
  thread.save
  if thread.errors.any?
    error 400, thread.errors.full_messages.to_json
  else
    user.subscribe(thread) if bool_auto_subscribe
    thread.to_hash.to_json
  end
end
