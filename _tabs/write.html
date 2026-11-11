require 'base64'

Jekyll::Hooks.register :posts, :post_render do |post|
  filename = File.basename(post.path)
  raw_markdown = File.read(post.path, encoding: 'UTF-8')
  encoded_raw = Base64.strict_encode64(raw_markdown)

  injected_html = <<~HTML
    <div id="custom-edit-btn-box" style="margin: 40px 0 20px 0; padding-top: 20px; border-top: 1px solid #eee; text-align: right;">
      <button type="button" onclick="window.openDirectPostEditor()" style="display: inline-flex; align-items: center; justify-content: center; padding: 10px 22px; background-color: #3b2818; color: #ffffff !important; border: none; border-radius: 8px; font-weight: bold; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.15); cursor: pointer;">
        ✏️ 이 게시글 수정하기
      </button>
    </div>

    <div id="direct-editor-modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:#f3ede2; z-index:999999; overflow:hidden; font-family:sans-serif; color:#222;">
      <div style="max-width:1400px; height:94vh; margin:3vh auto; background:#fdfbf7; border:1px solid #e2d9c8; border-radius:14px; display:flex; flex-direction:column; padding:20px 24px; box-shadow:0 10px 30px rgba(0,0,0,0.18);">
        
        <div style="display:flex; justify-content:space-between; align-items:center; padding-bottom:14px; border-bottom:1px solid #e6dec8;">
          <div style="font-size:20px; font-weight:800; color:#3b2818;">✒️ 블로그 게시글 수정 (${filename})</div>
          <div style="display:flex; gap:10px;">
            <button type="button" onclick="window.setGhToken()" style="padding:8px 14px; background:#fff; border:1px solid #ccc; border-radius:8px; cursor:pointer; font-weight:600; font-size:13px;">🔑 GitHub 연동 설정</button>
            <button type="button" onclick="document.getElementById('direct-editor-modal').style.display='none'" style="padding:8px 14px; background:#fff; border:1px solid #ccc; border-radius:8px; cursor:pointer; font-weight:600; font-size:13px;">✖ 닫기 (취소)</button>
            <button type="button" id="direct-save-btn" onclick="window.saveEditedPost()" style="padding:8px 18px; background:#7c5a3f; color:#fff; border:none; border-radius:8px; cursor:pointer; font-weight:bold; font-size:14px;">☁️ 게시글 수정 등록하기</button>
          </div>
        </div>

        <div style="display:grid; grid-template-columns: 1.2fr 3fr 1.5fr; gap:12px; margin:14px 0;">
          <input id="de-category" type="text" placeholder="카테고리 (예: Paper Review)" style="padding:10px 12px; border:1px solid #d8cebe; border-radius:8px; font-size:14px; background:#fff;">
          <input id="de-title" type="text" placeholder="게시글 제목" style="padding:10px 12px; border:1px solid #d8cebe; border-radius:8px; font-size:15px; font-weight:bold; background:#fff;">
          <input id="de-tags" type="text" placeholder="태그 (쉼표로 구분)" style="padding:10px 12px; border:1px solid #d8cebe; border-radius:8px; font-size:14px; background:#fff;">
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; flex:1; min-height:0;">
          <textarea id="de-body" oninput="window.updateDirectPreview()" style="width:100%; height:100%; padding:16px; border:1px solid #d8cebe; border-radius:8px; resize:none; font-family:monospace; font-size:14px; line-height:1.7; background:#fff; color:#222; box-sizing:border-box;"></textarea>
          <div id="de-preview" class="content" style="width:100%; height:100%; padding:16px; border:1px solid #d8cebe; border-radius:8px; overflow-y:auto; background:#fff; box-sizing:border-box; text-align:left;"></div>
        </div>

      </div>
    </div>

    <script>
    (function() {
      var encoded = "#{encoded_raw}";
      var targetFile = "#{filename}";
      var origFrontMatter = "";

      function decodeRaw() {
        var bin = atob(encoded);
        var bytes = new Uint8Array(bin.length);
        for (var i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
        return new TextDecoder('utf-8').decode(bytes);
      }

      window.updateDirectPreview = function() {
        var md = document.getElementById('de-body').value;
        var html = md
          .replace(/^### (.*$)/gim, '<h3>$1</h3>')
          .replace(/^## (.*$)/gim, '<h2>$1</h2>')
          .replace(/^# (.*$)/gim, '<h1>$1</h1>')
          .replace(/\\*\\*(.*?)\\*\\*/gim, '<strong>$1</strong>')
          .replace(/\\n/gim, '<br>');
        document.getElementById('de-preview').innerHTML = html;
      };

      window.openDirectPostEditor = function() {
        var raw = decodeRaw();
        var match = raw.match(/^---\\r?\\n([\\s\\S]*?)\\r?\\n---\\r?\\n([\\s\\S]*)$/);
        var title = "", cat = "", tags = "", body = raw;

        if (match) {
          origFrontMatter = match[1];
          body = match[2].replace(/^\\r?\\n/, '');

          var tm = origFrontMatter.match(/title:\\s*["']?(.*?)["']?\\s*$/m);
          if (tm) title = tm[1];

          var cm = origFrontMatter.match(/categories:\\s*\\[?\\s*["']?([^"'\\],\\r\\n]+)["']?/m);
          if (cm) cat = cm[1].trim();

          var tgm = origFrontMatter.match(/tags:\\s*\\[(.*?)\\]/m);
          if (tgm) tags = tgm[1].replace(/["']/g, '').trim();
        }

        document.getElementById('de-title').value = title;
        document.getElementById('de-category').value = cat;
        document.getElementById('de-tags').value = tags;
        document.getElementById('de-body').value = body;
        window.updateDirectPreview();
        document.getElementById('direct-editor-modal').style.display = 'block';
      };

      window.setGhToken = function() {
        var current = localStorage.getItem('gh_pat_token') || '';
        var input = prompt('GitHub Personal Access Token (repo 권한)을 입력해주세요:', current);
        if (input !== null && input.trim() !== '') {
          localStorage.setItem('gh_pat_token', input.trim());
          alert('GitHub 토큰이 저장되었습니다.');
        }
      };

      window.saveEditedPost = async function() {
        var token = localStorage.getItem('gh_pat_token');
        for (var i = 0; i < localStorage.length; i++) {
          var k = localStorage.key(i);
          var v = localStorage.getItem(k);
          if (!token && v && (v.startsWith('ghp_') || v.startsWith('github_pat_'))) {
            token = v;
          }
        }
        if (!token) {
          token = prompt('글 수정을 위해 GitHub 토큰(ghp_... 또는 github_pat_...)을 한 번 입력해주세요:');
          if (!token) return;
          localStorage.setItem('gh_pat_token', token.trim());
        }

        var btn = document.getElementById('direct-save-btn');
        btn.innerText = '⏳ 수정 반영 중...';
        btn.disabled = true;

        try {
          var title = document.getElementById('de-title').value.trim();
          var cat = document.getElementById('de-category').value.trim();
          var tags = document.getElementById('de-tags').value.split(',').map(function(s){return s.trim();}).filter(Boolean).join(', ');
          var body = document.getElementById('de-body').value;

          var dateMatch = origFrontMatter.match(/date:\\s*(.*?)\\s*$/m);
          var dateStr = dateMatch ? dateMatch[1] : new Date().toISOString().slice(0, 19).replace('T', ' ') + ' +0900';

          var newMd = "---\\n" +
                      "title: \\"" + title.replace(/"/g, '\\\\"') + "\\"\\n" +
                      "date: " + dateStr + "\\n" +
                      "categories: [" + (cat ? "\\"" + cat + "\\"" : "") + "]\\n" +
                      "tags: [" + tags + "]\\n" +
                      "math: true\\n" +
                      "---\\n\\n" + body;

          var apiUrl = 'https://api.github.com/repos/beakbeak040625-tech/beakbeak040625-tech.github.io/contents/_posts/' + encodeURIComponent(targetFile);
          
          var getRes = await fetch(apiUrl, {
            headers: { 'Authorization': 'token ' + token }
          });
          var getJson = await getRes.json();
          var sha = getJson.sha;

          var utf8Bytes = new TextEncoder().encode(newMd);
          var binary = '';
          for (var j = 0; j < utf8Bytes.length; j++) binary += String.fromCharCode(utf8Bytes[j]);
          var b64Content = btoa(binary);

          var putRes = await fetch(apiUrl, {
            method: 'PUT',
            headers: {
              'Authorization': 'token ' + token,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              message: 'Update post: ' + targetFile,
              content: b64Content,
              sha: sha
            })
          });

          if (putRes.ok) {
            alert('수정이 완료되었습니다! 약 1분 뒤 빌드가 반영됩니다.');
            document.getElementById('direct-editor-modal').style.display = 'none';
          } else {
            var err = await putRes.json();
            alert('저장 실패: ' + (err.message || '토큰 권한을 확인해주세요.'));
          }
        } catch (e) {
          alert('오류 발생: ' + e.message);
        } finally {
          btn.innerText = '☁️ 게시글 수정 등록하기';
          btn.disabled = false;
        }
      };
    })();
    </script>
  HTML

  post.output = post.output.sub('<div class="post-tail-wrapper', injected_html + '<div class="post-tail-wrapper')
end
