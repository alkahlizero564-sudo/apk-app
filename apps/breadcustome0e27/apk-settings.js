// apk-settings.js: يعدّل مشروع أندرويد بعد توليده (آمن: لا يفشل البناء أبداً)
try{
  var fs=require('fs'),path=require('path');
  var S=JSON.parse(fs.readFileSync(path.join(__dirname,'settings.json'),'utf8'));
  var A=path.join(__dirname,'android','app');
  var gr=path.join(A,'build.gradle');
  if(fs.existsSync(gr)){
    var g=fs.readFileSync(gr,'utf8');
    if(S.versionCode)g=g.replace(/versionCode[ ]+[0-9]+/,'versionCode '+S.versionCode);
    if(S.versionName)g=g.replace(/versionName[ ]+"[^"]*"/,'versionName "'+S.versionName+'"');
    fs.writeFileSync(gr,g);
  }
  var mf=path.join(A,'src','main','AndroidManifest.xml');
  if(fs.existsSync(mf)&&(S.ori==='portrait'||S.ori==='landscape')){
    var m=fs.readFileSync(mf,'utf8');
    m=m.replace(/[ ]android:screenOrientation="[^"]*"/,'');
    m=m.replace('android:name=".MainActivity"','android:name=".MainActivity" android:screenOrientation="'+S.ori+'"');
    fs.writeFileSync(mf,m);
  }
  console.log('apk-settings applied');
}catch(e){console.log('apk-settings skipped: '+e.message)}
