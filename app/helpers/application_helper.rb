module ApplicationHelper

  MARKDOWN_OPTS = {escape_html: true, safe_links_only: true, hard_wrap: true}
  RENDER_OPTS = {autolink: true,  strikethrough: true}
  @@markdown = 
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(MARKDOWN_OPTS), RENDER_OPTS)
  @@markdown_no_links = 
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(MARKDOWN_OPTS.merge no_links: true), RENDER_OPTS)


  def self.renderMarkdown (txt)
    ("<div class='contra-markdown-block'>"+@@markdown.render(txt)+"</div>").html_safe
  end

  def self.renderMarkdownInline (txt)
    ("<span class='contra-markdown-inline'>"+@@markdown.render(txt)+"</span>").html_safe
  end

  def self.renderMarkdownInlineNoLinks (txt)
    ("<span class='contra-markdown-inline'>"+@@markdown_no_links.render(txt)+"</span>").html_safe
  end


  def guess_title_text(controller_name)
    looking_at_name = ActiveSupport::Inflector.singularize controller_name
    if looking_at_name
      looking_at = eval("@#{looking_at_name}")
      if looking_at.respond_to? :name
        "#{looking_at.name} | #{looking_at_name.capitalize} | Contra"
      elsif looking_at.respond_to? :title
        "#{looking_at.title} | #{looking_at_name.capitalize} | Contra"
      else
        nil
      end
    end ||
      "#{controller_name.capitalize} | Contra"
  end
end
