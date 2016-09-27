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

end
