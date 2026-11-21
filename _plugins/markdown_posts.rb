# frozen_string_literal: true

require "nokogiri"
require "reverse_markdown"

# Publishes a Markdown version of every post next to its HTML page, e.g.
# /archive/2026/11/my-post/ also gets /archive/2026/11/my-post.md.
module MarkdownPosts
  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      site.posts.docs.each do |post|
        path = "#{post.url.chomp('/')}.md"
        # An .html name keeps Jekyll from converting the content again; the
        # permalink decides the published file name.
        page = Jekyll::PageWithoutAFile.new(site, site.source, File.dirname(path), "#{File.basename(path, '.md')}.html")
        page.content = markdown_for(post)
        page.data["layout"] = nil
        page.data["permalink"] = path
        page.data["sitemap"] = false
        site.pages << page
      end
    end

    private

    # Older posts mark up multi-line code with a bare <code>; give it a <pre>
    # so it becomes a fenced block instead of inline code.
    def wrap_code_blocks(html)
      fragment = Nokogiri::HTML.fragment(html)
      fragment.css("code").each do |code|
        next if code.ancestors("pre").any? || !code.text.include?("\n")

        code.replace("<pre>#{code.to_html}</pre>")
      end
      fragment.to_html
    end

    def markdown_for(post)
      body = ReverseMarkdown.convert(wrap_code_blocks(post.content), unknown_tags: :bypass, github_flavored: true).strip
      "# #{post.data['title']}\n\n#{post.date.strftime('%Y-%m-%d')}\n\n#{body}\n"
    end
  end
end
