# encoding: utf-8
require 'jslibfigure'


module DancesHelper
  # input: an array of possibly non-html-safe strings
  # output: a string representation of the array with brackets and
  #         quotes and properly html-safe internal strings.
  def a_to_safe_str(a)
    s = '['.html_safe
    first_time = true
    a.each do |e|
      s << ','.html_safe unless first_time
      s << '"'.html_safe
      s << e
      s << '"'.html_safe
      first_time = false;
    end
    s << ']'.html_safe
    s
  end

  def admin_moderation_display(user)
    email = mail_to(user.email, nil, target: '_blank',
                    onClick: "javascript:window.open('mailto:#{user.email}', 'mail');event.preventDefault()")
    s = ''.html_safe            # html_safe seed
    # onclick behavior is a workaround to open in a new window in
    # firefox, which has a longstanding bug ignoring target
    case user.moderation
    when 'collaborative'
      s + "Collaborative - moderators may edit or unpublish the dance, emailing " + email + " the original text"
    when 'owner'
      s + "Owner - email " + email + ", then if they don't repsond within 2 weeks unpublish the dance"
    when 'hermit'
      "Hermit - unpublish the dance, don't contact them"
    when 'unknown'
      s + "Unknown - " + email + " has not specified their modification preference"
    else
      raise "unexpected user moderation #{user.moderation.inspect}"
    end
  end

  def dance_publish_string(publish_enum)
    case publish_enum.to_s
    when 'off'
      'private'
    when 'link'
      'shared to sketchbook'
    when 'all'
      'shared'
    else
      raise 'fell through enum case'
    end
  end

  def dance_publish_word(publish_enum)
    case publish_enum.to_s
    when 'off'
      'private'
    when 'link'
      'sketchbook'
    when 'all'
      'shared'
    else
      raise 'fell through enum case'
    end
  end
end
