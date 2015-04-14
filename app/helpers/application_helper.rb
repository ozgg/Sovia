module ApplicationHelper
  def param_from_request(parameter)
    params[parameter].to_s.encode('UTF-8', 'UTF-8', invalid: :replace, replace: '')
  end

  def user_link(user)
    if user.nil?
      t('anonymous')
    else
      link_to user.login, user_profile_path(login: user.login)
    end
  end

  def profile_avatar(user)
    if user.nil?
      image_tag 'fallback/avatar/default.png'
    elsif user.should_use_gravatar?
      image_tag user.gravatar_image(400)
    else
      image_tag user.avatar.url
    end
  end

  def entry_avatar(user)
    attributes = { width: 100, height: 100, alt: user.nil? ? I18n.t('anonymous') : user.login }
    if user.nil?
      image_tag 'fallback/avatar/entry_default.png', attributes
    elsif user.should_use_gravatar?
      image_tag user.gravatar_image(200), attributes
    else
      image_tag user.avatar.entry.url, attributes
    end
  end

  def comment_avatar(user)
    attributes = { width: 50, height: 50, alt: user.nil? ? I18n.t('anonymous') : user.login }
    if user.nil?
      image_tag 'fallback/avatar/comment_default.png', attributes
    elsif user.should_use_gravatar?
      image_tag user.gravatar_image(100), attributes
    else
      image_tag user.avatar.comment.url, attributes
    end
  end

  def link_to_dream(dream)
    link_to dream.parsed_title, entry_dream_path(dream)
  end

  def tagged_entries_path(tag)
    parameters = { tag: tag.uri_name }
    attributes = { rel: 'tag' }
    attributes[:class] = 'described' unless tag.description.blank?
    if tag.is_a? Tag::Dream
      link_to tag.name, tagged_entry_dreams_path(parameters), attributes
    else
      tag.name
    end
  end

  def comment_url(comment)
    entry = comment.commentable
    parameters = {
        id:        entry.id,
        uri_title: entry.is_a?(Post) ? nil : (entry.url_title || 'bez-nazvaniya'),
        anchor:    "comment-#{comment.id}"
    }
    if entry.is_a? Post
      post_url id: entry.id, anchor: parameters[:anchor]
    elsif entry.is_a? Entry::Dream
      verbose_entry_dreams_url parameters
    else
      "Entry #{entry.id}"
    end
  end

  def verbose_entry_path(entry)
    parameters = {
        id:        entry.id,
        uri_title: entry.is_a?(Post) ? nil : (entry.url_title || 'bez-nazvaniya')
    }
    if entry.is_a? Post
      post_path entry
    elsif entry.is_a? Entry::Dream
      verbose_entry_dreams_path(parameters)
    end
  end

  def verbose_entry_url(entry)
    parameters = {
        id:        entry.id,
        uri_title: entry.is_a?(Post) ? nil : (entry.url_title || 'bez-nazvaniya')
    }
    if entry.is_a? Post
      post_url entry
    elsif entry.is_a? Entry::Dream
      verbose_entry_dreams_url(parameters)
    end
  end

  def parse_body(body, allow_raw = false, show_names = false)
    output = ''
    body.strip.split(/(?:\r?\n)+/).each do |fragment|
      unless allow_raw
        fragment.gsub!('<', '&lt;')
        fragment.gsub!('>', '&gt;')
      end
      link_old_dreambook_symbols(fragment)
      link_dreambook_symbols(fragment)
      link_entries(fragment)
      find_links(fragment)
      find_names(fragment, show_names)
      if fragment.match(/\A<(?:p|li|h|ol|ul)/)
        output += fragment
      else
        output += "<p>#{fragment}</p>"
      end
    end

    output
  end

  def link_old_dreambook_symbols(fragment)
    pattern = /[\[<]symbol name="(?<name>[^"]+)"[^\]>]*[\]>]/
    fragment.gsub! pattern do |chunk|
      match = pattern.match chunk
      tag   = Tag::Dream.match_by_name(match[:name])
      if tag.nil?
        '<span class="not-found">' + match[:name] + '</span>'
      else
        link_to(match[:name], dreambook_word_path(letter: tag.letter, word: tag.name))
      end
    end
  end

  def link_dreambook_symbols(fragment)
    pattern = /\[\[(?<name>[^\]]+)\]\](?:\((?<text>[^)]{1,32})\))?/
    fragment.gsub! pattern do |chunk|
      match = pattern.match chunk
      tag   = Tag::Dream.match_by_name(match[:name])
      text  = match[:text] || match[:name]
      text.gsub!('<', '&lt;')
      text.gsub!('>', '&gt;')
      text.gsub!('"', '&quot;')

      if tag.nil?
        "<span class=\"not-found\" title=\"#{match[:name]}\">#{text}</span>"
      else
        link_to(text, dreambook_word_path(letter: tag.letter, word: tag.name), title: tag.name)
      end
    end
  end

  def link_entries(fragment)
    pattern = /\[(?:entry|article|dream|post)\s+(?:id=")?(?<id>[^"]{1,8})"?[^\]]*\](?:\((?<text>[^)]{1,64})\))?/
    fragment.gsub! pattern do |chunk|
      match = pattern.match chunk
      entry = Entry::find_by(id: match[:id])
      if match[:text]
        title = match[:text]
        prefix, postfix = '', ''
      else
        title = entry.nil? ? match[:id] : entry.parsed_title
        prefix, postfix = '&laquo;', '&raquo;'
      end
      if entry.nil?
        "<span class=\"not-found\" title=\"#{escape(title)}\">#{match[:id]}</span>"
      else
        prefix + link_to(title, verbose_entry_path(entry), title: entry.parsed_title) + postfix
      end
    end
  end

  def find_links(fragment)
    pattern = /(?:\[(?<href>(?:https?:\/\/|\/)[a-zA-Z0-9\.\/?=&%+\-_]+)\]\((?<text>[^\)]+)\))/
    fragment.gsub! pattern do |chunk|
      match = pattern.match chunk
      '<a href="' + match[:href] + '">' + match[:text] + '</a>'
    end
  end

  def find_names(fragment, show_names)
    pattern = /\{(?<name>[^}]{1,30})\}(?:\((?<text>[^)]{1,30})\))?/
    fragment.gsub! pattern do |chunk|
      match = pattern.match chunk
      if match[:text]
        name = match[:text]
      else
        name = ''
        match[:name].split(/[\s-]+/).each do |word|
          name += word.first
        end
      end
      if show_names
        attribute = " title=\"#{escape(match[:name])}\""
      else
        attribute = ''
      end
      "<span class=\"name\"#{attribute}>#{escape(name)}</span>"
    end
  end

  def escape(string)
    string.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
  end

  def visitor_is_administrator?
    current_user && current_user.has_role?(:administrator)
  end
end
