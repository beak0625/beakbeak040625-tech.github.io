require 'base64'

Jekyll::Hooks.register :posts, :post_render do |post|
  filename = File.basename(post.path)
  raw_markdown = File.read(post.path, encoding: 'UTF-8')
  encoded_raw = Base64.strict_encode64(raw_markdown)

  injected_html = <<~HTML
    <div id="custom-edit-btn-box" style="margin: 40px 0 20px 0; padding-top: 20px; border-top: 1px solid #eee; text-align: right;">
      <button type="button" onclick="window.openInPageEditor()" style="display: inline-flex; align-items: center; justify-content: center; padding: 10px 22px; background-color: #3b2818; color: #ffffff !important; border: none; border-radius: 8px; font-weight: bold; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.15); cursor: pointer;">
        ✏️ 이 게시글 수정하기
      </button>
    </div>
    <div id="inpage-editor-modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:#f3ede2; z-index:999999; overflow:hidden; font-family:-apple-system,BlinkMacSystemFont,'Pretendard',sans-serif; color:#222;">
      <div style="max-width:1440px; height:94vh; margin:3vh auto; background:#fdfbf7; border:1px solid #e2d9c8; border-radius:14px; display:flex; flex-direction:column; padding:20px 24px; box-shadow:0 10px 30px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; padding-bottom:14px; border-bottom:1px solid #e6dec8;">
          <div style="font-size:20px; font-weight:800; color:#3b2818;">✏️ 블로그 게시글 수정 (#{filename})</div>
          <div style="display:flex; gap:8px;">
            <button type="button" onclick="window.ipSetToken()" style="padding:8px 14px; background:#fff; color:#333; border:1px solid #d4cbb8; border-radius:8px; cursor:pointer; font-weight:600; font-size:13px;">🔑 GitHub 연동 설정</button>
            <button type="button" onclick="document.getElementById('inpage-editor-modal').style.display='none'" style="padding:8px 14px; background:#fff; color:#333; border:1px solid #d4cbb8; border-radius:8px; cursor:pointer; font-weight:600; font-size:13px;">✖ 닫기</button>
            <button type="button" id="ip-save-btn" onclick="window.ipSavePost()" style="padding:8px 18px; background:#7c5a3f; color:#fff; border:none; border-radius:8px; cursor:pointer; font-weight:bold; font-size:14px;">☁️ 게시글 수정 완료하기</button>
          </div>
        </div>
        <div style="display:grid; grid-template-columns: 1.2fr 2.8fr 1.5fr; gap:12px; margin:14px 0 10px 0;">
          <select id="ip-cat" style="padding:10px 12px; border:1px solid #d8cebe; border-radius:8px; font-size:14px; background:#fff; color:#222;">
            <option value="개발">1. 개발</option>
            <option value="CTF/Wargame">2. CTF/Wargame</option>
            <option value="Bug Bounty">3. Bug Bounty</option>
            <option value="블로그/기술문서">4. 블로그/기술문서</option>
            <option value="논문/컨퍼런스">5. 논문/컨퍼런스</option>
            <option value="공모전 및 자격증">6. 공모전 및 자격증</option>
          </select>
          <input id="ip-title" type="text" placeholder="게시글 제목" style="padding:10px 14px; border:1px solid #d8cebe; border-radius:8px; font-size:15px; font-weight:bold; background:#fff; color:#222;">
          <input id="ip-tags" type="text" placeholder="태그 (쉼표로 구분)" style="padding:10px 14px; border:1px solid #d8cebe; border-radius:8px; font-size:14px; background:#fff; color:#222;">
        </div>
        <div style="display:flex; flex-wrap:wrap; gap:6px; align-items:center; padding:8px 12px; background:#f6f1e7; border:1px solid #e2d9c8; border-radius:8px; margin-bottom:12px;">
          <select onchange="window.ipHeading(this.value); this.value='';" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; font-weight:600; color:#333;">
            <option value="">문단 제목</option>
            <option value="1">대제목 (1.5em)</option>
            <option value="2">중제목 (1.2em)</option>
            <option value="3">소제목 (###)</option>
          </select>
          <button type="button" onclick="window.ipWrap('**','**')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; cursor:pointer;"><b>B</b></button>
          <button type="button" onclick="window.ipWrap('*','*')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; cursor:pointer;"><i>I</i></button>
          <button type="button" onclick="window.ipWrap('<u>','</u>')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; cursor:pointer;"><u>U</u></button>
          <button type="button" onclick="window.ipWrap('~~','~~')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; cursor:pointer;"><s>S</s></button>
          <button type="button" onclick="window.ipWrap('<mark style=&quot;background:#fff3b0;&quot;>','</mark>')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; cursor:pointer;">🖍️ 형광펜</button>
          <button type="button" onclick="window.ipInsert('\\n\\n| 항목 | 설명 | 비고 |\\n| :--- | :--- | :--- |\\n| 내용 1 | 설명 1 | 비고 1 |\\n\\n')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; font-weight:600; cursor:pointer;">⊞ 표 삽입</button>
          <button type="button" onclick="window.ipWrap('$$','$$')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; font-weight:600; cursor:pointer;">√x 수식</button>
          <button type="button" onclick="window.ipInsert('\\n<br>\\n')" style="padding:5px 10px; background:#fff; border:1px solid #d8cebe; border-radius:6px; font-size:13px; font-weight:600; cursor:pointer;">↵ 줄바꿈(&lt;br&gt;)</button>
        </div>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; flex:1; min-height:0;">
          <textarea id="ip-body" oninput="window.ipPreview()" style="width:100%; height:100%; padding:16px; border:1px solid #d8cebe; border-radius:8px; resize:none; font-family:monospace; font-size:14px; line-height:1.75; background:#fff; color:#222; box-sizing:border-box;"></textarea>
          <div id="ip-prev" class="content" style="width:100%; height:100%; padding:16px 20px; border:1px solid #d8cebe; border-radius:8px; overflow-y:auto; background:#fff; color:#222; box-sizing:border-box; text-align:left;"></div>
        </div>
      </div>
    </div>
    <script>
    (function(){
      var b64 = "#{encoded_raw}";
      var fname = "#{filename}";
      var origDate = "";
      function getRaw(){
        var bin = atob(b64);
        var bytes = new Uint8Array(bin.length);
        for(var i=0;i<bin.length;i++) bytes[i]=bin.charCodeAt(i);
        return new TextDecoder('utf-8').decode(bytes);
      }
      function getTok(){
        var t = localStorage.getItem('gh_pat_token') || localStorage.getItem('github_token') || localStorage.getItem('token');
        if(t) return t;
        for(var i=0;i<localStorage.length;i++){
          var v = localStorage.getItem(localStorage.key(i));
          if(v && (v.startsWith('ghp_')||v.startsWith('github_pat_'))) return v;
        }
        return '';
      }
      window.ipPreview = function(){
        var md = document.getElementById('ip-body').value || '';
        var html = md.replace(/^### (.*$)/gim,'<h3>$1</h3>').replace(/^## (.*$)/gim,'<h2>$1</h2>').replace(/^# (.*$)/gim,'<h1>$1</h1>').replace(/\\*\\*(.*?)\\*\\*/gim,'<strong>$1</strong>').replace(/\\n/g,'<br>');
        var p = document.getElementById('ip-prev');
        p.innerHTML = html;
        if(window.MathJax && window.MathJax.typesetPromise) window.MathJax.typesetPromise([p]).catch(function(){});
      };
      window.ipWrap = function(pre,suf){
        var el = document.getElementById('ip-body');
        var s = el.selectionStart, e = el.selectionEnd;
        var sel = el.value.substring(s,e) || '텍스트';
        el.setRangeText(pre+sel+suf, s, e, 'end');
        el.focus(); window.ipPreview();
      };
      window.ipInsert = function(txt){
        var el = document.getElementById('ip-body');
        el.setRangeText(txt, el.selectionStart, el.selectionEnd, 'end');
        el.focus(); window.ipPreview();
      };
      window.ipHeading = function(lv){
        if(lv==='1') window.ipWrap('<span style="font-size:1.5em;">','</span>\\n<br>\\n');
        if(lv==='2') window.ipWrap('<span style="font-size:1.2em;">','</span>\\n<br>\\n');
        if(lv==='3') window.ipInsert('\\n### 제목\\n');
      };
      window.openInPageEditor = function(){
        var raw = getRaw();
        localStorage.setItem('chirpy_edit_raw', raw);
        localStorage.setItem('chirpy_edit_filename', fname);
        var m = raw.match(/^---\\r?\\n([\\s\\S]*?)\\r?\\n---\\r?\\n([\\s\\S]*)$/);
        var title='', cat='논문/컨퍼런스', tags='', body=raw;
        if(m){
          var yaml = m[1];
          body = m[2].replace(/^\\r?\\n/,'');
          var tm = yaml.match(/title:\\s*["']?(.*?)["']?\\s*$/m);
          if(tm) title = tm[1].replace(/\\\\"/g,'"');
          var dm = yaml.match(/date:\\s*(.*?)\\s*$/m);
          if(dm) origDate = dm[1].trim();
          var cm = yaml.match(/categories:\\s*\\[?\\s*["']?([^"'\\],\\r\\n]+)["']?/m);
          if(cm) cat = cm[1].trim();
          var tgm = yaml.match(/tags:\\s*\\[(.*?)\\]/m);
          if(tgm) tags = tgm[1].replace(/["']/g,'').split(',').map(function(s){return s.trim();}).filter(Boolean).join(', ');
        }
        document.getElementById('ip-title').value = title;
        var sel = document.getElementById('ip-cat');
        var found = false;
        for(var i=0;i<sel.options.length;i++){
          if(sel.options[i].value===cat || sel.options[i].text.includes(cat)){ sel.selectedIndex=i; found=true; break; }
        }
        if(!found){ var o=document.createElement('option'); o.value=cat; o.text=cat; sel.appendChild(o); sel.value=cat; }
        document.getElementById('ip-tags').value = tags;
        document.getElementById('ip-body').value = body;
        window.ipPreview();
        document.getElementById('inpage-editor-modal').style.display = 'block';
      };
      window.ipSetToken = function(){
        var cur = getTok();
        var inp = prompt('GitHub Personal Access Token (repo 권한) 입력:', cur);
        if(inp && inp.trim()) { localStorage.setItem('gh_pat_token', inp.trim()); alert('저장되었습니다.'); }
      };
      window.ipSavePost = async function(){
        var tok = getTok();
        if(!tok){
          tok = prompt('GitHub 토큰(ghp_...)을 입력해주세요:');
          if(!tok) return;
          localStorage.setItem('gh_pat_token', tok.trim());
        }
        var btn = document.getElementById('ip-save-btn');
        btn.disabled = true; btn.innerText = '⏳ 수정 반영 중...';
        try{
          var t = document.getElementById('ip-title').value.trim();
          var c = document.getElementById('ip-cat').value.trim();
          var tg = document.getElementById('ip-tags').value.split(',').map(function(s){return s.trim();}).filter(Boolean).map(function(x){return '"'+x+'"';}).join(', ');
          var bd = document.getElementById('ip-body').value;
          var dt = origDate || (new Date().toISOString().slice(0,19).replace('T',' ')+' +0900');
          var newMd = '---\\ntitle: "'+t.replace(/"/g,'\\\\"')+'"\\ndate: '+dt+'\\ncategories: ["'+c+'"]\\ntags: ['+(tg||'"'+c+'"')+']\\nmath: true\\n---\\n\\n'+bd;
          var url = 'https://api.github.com/repos/beakbeak040625-tech/beakbeak040625-tech.github.io/contents/_posts/'+encodeURIComponent(fname);
          var gRes = await fetch(url, { headers:{'Authorization':'token '+tok} });
          var gData = await gRes.json();
          var u8 = new TextEncoder().encode(newMd);
          var bin = ''; for(var i=0;i<u8.length;i++) bin += String.fromCharCode(u8[i]);
          var pRes = await fetch(url, {
            method:'PUT',
            headers:{'Authorization':'token '+tok,'Content-Type':'application/json'},
            body: JSON.stringify({ message:'Update post: '+fname, content:btoa(bin), sha:gData.sha })
          });
          if(pRes.ok){
            alert('게시글 수정이 완료되었습니다! 약 1분 뒤 빌드가 반영됩니다.');
            document.getElementById('inpage-editor-modal').style.display = 'none';
          } else {
            var err = await pRes.json();
            alert('저장 실패: '+(err.message||'토큰 권한을 확인해주세요.'));
          }
        } catch(e){ alert('오류: '+e.message); }
        finally { btn.disabled = false; btn.innerText = '☁️ 게시글 수정 완료하기'; }
      };
    })();
    </script>
  HTML

  post.output = post.output.sub('<div class="post-tail-wrapper', injected_html + '<div class="post-tail-wrapper')
end
