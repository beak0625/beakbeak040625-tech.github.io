require 'base64'

Jekyll::Hooks.register :posts, :post_render do |post|
  filename = File.basename(post.path)
  raw_markdown = File.read(post.path, encoding: 'UTF-8')
  encoded_raw = Base64.strict_encode64(raw_markdown)

  onclick_js = "var b=atob('#{encoded_raw}'),u=new Uint8Array(b.length);for(var i=0;i<b.length;i++)u[i]=b.charCodeAt(i);localStorage.setItem('chirpy_edit_raw',new TextDecoder('utf-8').decode(u));localStorage.setItem('chirpy_edit_filename','#{filename}');var link=Array.from(document.querySelectorAll('#sidebar a.nav-link')).find(function(a){return a.innerText.includes('글쓰기')||a.href.includes('write');});window.location.href=link?link.href:'/글쓰기/';return false;"

  btn_html = "<div style='margin: 40px 0 20px 0; padding-top: 20px; border-top: 1px solid #eee; text-align: right;'><a href='#' onclick=\"#{onclick_js}\" style='display: inline-flex; align-items: center; justify-content: center; padding: 10px 22px; background-color: #3b2818; color: #ffffff !important; border-radius: 8px; text-decoration: none !important; font-weight: bold; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.15); cursor: pointer;'>✏️ 이 게시글 수정하기</a></div>"

  post.output = post.output.sub('<div class="post-tail-wrapper', btn_html + '<div class="post-tail-wrapper')
end
