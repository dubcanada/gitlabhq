class PostReceive
  @queue = :post_receive

  def self.perform(reponame, oldrev, newrev, ref, author_key_id)
    project = Project.find_by_path(reponame)
    return false if project.nil?

    # Ignore push from non-gitlab users
    return false unless Key.find_by_identifier(author_key_id)

    # Create push event
    project.observe_push(oldrev, newrev, ref, author_key_id)

    # Close merged MR 
    project.update_merge_requests(oldrev, newrev, ref, author_key_id)

    # Execute web hooks
    project.execute_web_hooks(oldrev, newrev, ref, author_key_id)
  end
end
