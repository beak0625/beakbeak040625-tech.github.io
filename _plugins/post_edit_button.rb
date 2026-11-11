Jekyll::Hooks.register :posts, :post_render do |post|
  filename = File.basename(post.path)
  btn_html = "<div style='margin: 40px 0 20px 0; padding-top: 20px; border-top: 1px solid #eee; text-align: right;'><a href='/write/?edit=#{filename}' style='display: inline-flex; align-items: center; justify-content: center; padding: 10px 22px; background-color: #3b2818; color: #ffffff !important; border-radius: 8px; text-decoration: none !important; font-weight: bold; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.15);'>✏️ 이 게시글 수정하기</a></div>"
  post.output = post.output.sub('<div class="post-tail-wrapper', btn_html + '<div class="post-tail-wrapper')
end
