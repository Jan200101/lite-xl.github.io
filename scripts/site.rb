#!/usr/bin/env ruby
require 'redcarpet'
require 'rouge'
class RedRouge < Redcarpet::Render::HTML
   def block_code(code, language) "<pre>" + Rouge.highlight(code, language || "bash", 'html') + "</pre>" end
   def link(link, title, link_content) "<a title='#{title}' #{link =~ /^(http|\/?img)/ && target='_blank'} href='#{ARGV[0] || ""}#{link}'>#{link_content}</a>" end
 end
rc = Redcarpet::Markdown.new(RedRouge.new(with_toc_data: true), { fenced_code_blocks: true, tables: true, footnotes: true })
sitemap = File.open("sitemap.txt", "w")
Dir.glob("locales/*").map { |locale| File.write(File.basename(locale) + ".html", File.read("#{locale}/template.html").gsub("{{ pages }}", "<style type='text/css'>" + Rouge::Themes::Base16.mode(:dark).render(scope: 'pre') + "</style>" +
  Dir.glob("#{locale}/**/*.md").select { |x| File.file?(x) }.map { |x| 
    sitemap.write("https://lite-xl.com" + (x =~ /index\.md/ ? "" : "?/" + x.downcase.gsub(/^locales\//, "").gsub(/\.\w+$/, "")) + "\n")
    "<page id='page-#{x.downcase.gsub(/(^locales\/#{File.basename(locale)}\/|[^a-z0-9_\-\/\\\.]|\.\w+$)/,"").gsub(/[\s\\\/]+/, "-")}'>#{rc.render(File.read(x))}</page>" 
  }.join("\n")).gsub(/{{ baseurl }}/, ARGV[0] || "")
) }
