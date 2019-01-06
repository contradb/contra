class LinkStripper < Redcarpet::Render::HTML
  def link(link, title, content)
    content
  end
end


module ApplicationHelper
  MARKDOWN_OPTS = {escape_html: true, safe_links_only: true, hard_wrap: true}
  RENDER_OPTS = {autolink: true,  strikethrough: true}
  @@markdown =
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(MARKDOWN_OPTS), RENDER_OPTS)
  @@markdown_html_ok =
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(MARKDOWN_OPTS.merge(escape_html: false)), RENDER_OPTS)
  @@markdown_no_links =
    Redcarpet::Markdown.new(LinkStripper.new(MARKDOWN_OPTS), RENDER_OPTS.merge(autolink: false))


  def self.renderMarkdown(txt)
    ("<div class='contra-markdown-block'>"+@@markdown.render(txt)+"</div>").html_safe
  end

  def self.renderMarkdownHtmlOk(txt)
    ("<div class='contra-markdown-block'>"+@@markdown_html_ok.render(txt)+"</div>").html_safe
  end

  def self.renderMarkdownInline(txt)
    ("<span class='contra-markdown-inline'>"+@@markdown.render(txt)+"</span>").html_safe
  end

  def self.renderMarkdownInlineNoLinks(txt)
    ("<span class='contra-markdown-inline'>"+@@markdown_no_links.render(txt)+"</span>").html_safe
  end


  def guess_title_text(controller_name)
    looking_at_name = ActiveSupport::Inflector.singularize controller_name
    if looking_at_name
      looking_at = begin
                     eval("@titlebar || @#{looking_at_name}")
                   rescue
                     return "Contra"
                   end
      if looking_at.respond_to?(:name) && looking_at.name.present?
        "#{looking_at.name} | #{looking_at_name.capitalize} | Contra"
      elsif looking_at.respond_to?(:title) && looking_at.title.present?
        "#{looking_at.title} | #{looking_at_name.capitalize} | Contra"
      elsif looking_at.is_a? String
        "#{looking_at} | #{looking_at_name.capitalize} | Contra"
      else
        "#{looking_at_name.capitalize} | Contra"
      end
    end ||
      "#{controller_name.capitalize} | Contra"
  end

  def conditional_classes(test:, thens:, elses: nil, always: nil)
    if test
      always ? "#{always} #{thens}" : thens
    elsif elses
      always ? "#{always} #{elses}" : elses
    else
      always || ''
    end
  end
end
