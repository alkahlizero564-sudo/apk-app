import json,re,glob,os,sys
D=os.path.dirname(os.path.abspath(__file__))
css=open(D+'/kit.css',encoding='utf-8').read()
js=open(D+'/kit.js',encoding='utf-8').read()
def mini(s): return re.sub(r'\n\s*','\n',s).strip()
def doc(path):
    src=open(path,encoding='utf-8').read()
    m=re.match(r'<!--META (\{.*?\})-->\n',src,re.S); meta=json.loads(m.group(1)); src=src[m.end():]
    st=re.search(r'<style>(.*?)</style>',src,re.S); sc=re.search(r'<script>(.*?)</script>\s*$',src,re.S)
    body=src[st.end() if st else 0:sc.start()].strip()
    html=('<!DOCTYPE html><html lang="ar" dir="rtl" data-theme="'+meta.get('theme','light')+'"><head><meta charset="utf-8">'
      '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><title>'+meta.get('title','')+'</title>'
      '<style>'+mini(css)+'\n:root{--h:'+str(meta['h'])+'}\n'+(mini(st.group(1)) if st else '')+'</style></head><body>'+body+
      '<script>'+mini(js)+'\n'+sc.group(1).strip()+'</script></body></html>')
    return meta,html
out=[]
groups={}
for f in sorted(glob.glob(D+'/t/*.html')):
    base=os.path.basename(f)[:-5]; g,k=(base.split('.')+['0'])[:2]
    groups.setdefault(g,[]).append((int(k),f))
for g,fs in sorted(groups.items()):
    fs.sort(); metas=[];htmls=[]
    for k,f in fs:
        m,h=doc(f); metas.append(m); htmls.append(h)
        open(D+'/out/%s.%d.html'%(g,k),'w',encoding='utf-8').write(h)
    m=metas[0]
    out.append({'name':m['name'],'desc':m['desc'],'tag':m['tag'],'c':m['c'],'cat':m['cat'],'apps':len(htmls),'html':htmls,'pro':True,'ord':m.get('ord',99),'replaces':m.get('replaces','')})
out.sort(key=lambda x:x['ord'])
json.dump(out,open(D+'/out/tpls.json','w',encoding='utf-8'),ensure_ascii=False)
print(len(out),'templates',sum(len(x['html']) for x in out),'screens')
