const fs=require('fs'),path=require('path'),cp=require('child_process'),vm=require('vm');
const root=process.cwd(),out=path.join(root,'output/materials');
const git=(...a)=>cp.execFileSync('git',a,{encoding:'utf8',maxBuffer:10e6}).trim();
const files=git('ls-files').split('\n');
const count=pred=>{const list=files.filter(f=>pred(f)&&fs.existsSync(f));let total=0,nonempty=0; for(const f of list){const lines=fs.readFileSync(f,'utf8').split(/\r?\n/);if(lines.at(-1)==='')lines.pop();total+=lines.length; nonempty+=lines.filter(x=>x.trim()).length;}return {files:list.length,total,nonempty,list};};
const logs=git('log','--no-merges','--date=short','--format=%h|%ad|%an|%s').split('\n').map(x=>{const [hash,date,author,...msg]=x.split('|');return {hash,date,author,msg:msg.join('|')};}).reverse();
const versions={};for(const [dir,names] of [['frontend',['vue','element-plus','vite','pinia','vue-router','echarts','axios']],['backend',['express','jsonwebtoken','bcryptjs','multer','ws','jest']]])for(const n of names)versions[n]=JSON.parse(fs.readFileSync(path.join(root,dir,'node_modules',n,'package.json'))).version;
const oldSource=git('show','10d241d7^:backend/services/autoGrade.js');const sandbox={module:{exports:{}}};vm.runInNewContext(oldSource,sandbox);
const current=require(path.join(root,'backend/services/autoGrade.js'));
const cases=[{id:'D01',name:'分数与小数等价答案误判',q:{type:'fill',answer:'1/2'},a:'0.5'}, {id:'D02',name:'主观题绕过步骤复核',q:{type:'subjective',answer:'同类项系数相加，得到5x。'},a:'同类项系数相加，得到5x。'}];
const defects=cases.map(c=>({...c,before:sandbox.module.exports.gradeAnswer(c.q,c.a),after:current.gradeAnswer(c.q,c.a)}));
const facts={head:git('rev-parse','HEAD'),commits:Number(git('rev-list','--count','HEAD')),nonMergeCommits:logs.length,logs,versions,node:process.version,sqlite:process.versions.sqlite,frontend:count(f=>/^frontend\/src\//.test(f)&&/\.(vue|js|css)$/.test(f)),backend:count(f=>/^backend\//.test(f)&&/\.js$/.test(f)&&!/^backend\/test\//.test(f)),tests:count(f=>/^backend\/test\//.test(f)&&/\.js$/.test(f)),defects};
fs.writeFileSync(path.join(out,'facts.json'),JSON.stringify(facts,null,2));
for(const state of ['before','after']){
 const html='<!doctype html><meta charset="utf-8"><style>body{font:22px "Microsoft YaHei";margin:48px;color:#172330}h1{font-size:30px}article{border-top:1px solid #aaa;padding:20px 0}pre{font:20px Consolas;line-height:1.45}p{line-height:1.5}</style><h1>智析数学 '+(state==='before'?'修复前':'修复后')+'批改结果回放</h1><p>代码版本：'+(state==='before'?'10d241d7 的父版本':'ef5efd61 当前工作区版本')+'　复现日期：2026年10月19日</p><p>此页展示实际函数运行输出，用于复核历史缺陷；并非旧版产品页面截图。</p>'+defects.map(d=>'<article><h2>'+d.id+' '+d.name+'</h2><p>标准答案：'+d.q.answer+'<br>学生作答：'+d.a+'</p><pre>'+JSON.stringify(d[state],null,2).replace(/</g,'&lt;')+'</pre></article>').join('');
 fs.writeFileSync(path.join(out,'defect-'+state+'.html'),html);
}
console.log(JSON.stringify({versions,node:facts.node,sqlite:facts.sqlite,commits:facts.commits,nonMergeCommits:facts.nonMergeCommits,frontend:{...facts.frontend,list:undefined},backend:{...facts.backend,list:undefined},defects},null,2));
