import json,re,glob,os
D=os.path.dirname(os.path.abspath(__file__))
exec(open(D+'/build.py').read().split('out=[]')[0])  # css, js, mini, doc
parts={}
for f in sorted(glob.glob(D+'/t/*.html')):
    base=os.path.basename(f)[:-5]; g,k=(base.split('.')+['0'])[:2]
    src=open(f,encoding='utf-8').read()
    m=re.match(r'<!--META (\{.*?\})-->\n',src,re.S); meta=json.loads(m.group(1)); src=src[m.end():]
    st=re.search(r'<style>(.*?)</style>',src,re.S); sc=re.search(r'<script>(.*?)</script>\s*$',src,re.S)
    body=src[st.end() if st else 0:sc.start()].strip()
    scr={'th':meta.get('theme','light'),'h':meta['h'],'ti':meta.get('title',''),'c':mini(st.group(1)) if st else '','b':body,'j':sc.group(1).strip()}
    # verify identical to build.py output
    assert doc(f)[1]=='<!DOCTYPE html><html lang="ar" dir="rtl" data-theme="'+scr['th']+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><title>'+scr['ti']+'</title><style>'+mini(css)+'\n:root{--h:'+str(scr['h'])+'}\n'+scr['c']+'</style></head><body>'+scr['b']+'<script>'+mini(js)+'\n'+scr['j']+'</script></body></html>'
    parts.setdefault(g,{'meta':None,'s':[]})
    if int(k)==0: parts[g]['meta']=meta
    parts[g]['s'].append((int(k),scr))
L=[]
for g,v in parts.items():
    v['s'].sort(key=lambda x:x[0]); m=v['meta']
    L.append({'name':m['name'],'desc':m['desc'],'tag':m['tag'],'c':m['c'],'cat':m['cat'],'ord':m['ord'],'rep':m['replaces'],'s':[s for _,s in v['s']]})
L.sort(key=lambda x:x['ord'])
def esc(t): return t.replace('\\','\\\\').replace('`','\\`').replace('${','\\${')
blk='''/* ===== إضافة: قوالب Pro جديدة بنظام تصميم موحد (تحل محل القوالب الأساسية القديمة) ===== */
(function(){
const PK_CSS=`'''+esc(mini(css))+'''`;
const PK_JS=`'''+esc(mini(js))+'''`;
const PK_T='''+json.dumps(L,ensure_ascii=False)+''';
function pkDoc(s){return '<!DOCTYPE html><html lang="ar" dir="rtl" data-theme="'+s.th+'"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><title>'+s.ti+'</title><style>'+PK_CSS+'\\n:root{--h:'+s.h+'}\\n'+s.c+'</style></head><body>'+s.b+'<scr'+'ipt>'+PK_JS+'\\n'+s.j+'</scr'+'ipt></body></html>'}
PK_T.forEach(function(t){
  const nt={name:t.name,desc:t.desc,tag:t.tag,c:t.c,cat:t.cat,apps:t.s.length,html:t.s.map(pkDoc),pro:true};
  const i=TPL.findIndex(function(x){return x.name===t.rep||x.name===t.name});
  if(i>-1)TPL[i]=nt;else TPL.push(nt);
});
})();
'''
open(D+'/out/block.js','w',encoding='utf-8').write(blk)
print(len(L),'templates',len(blk),'bytes')
