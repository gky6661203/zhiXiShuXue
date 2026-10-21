const fs=require('fs'),{performance}=require('perf_hooks');
const base='http://123.56.75.115/api';
async function req(token,method,url,body){let error;for(let i=0;i<3;i++)try{const t=performance.now();const r=await fetch(base+url,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(body?{body:JSON.stringify(body)}:{}),signal:AbortSignal.timeout(20000)});return {status:r.status,ms:+(performance.now()-t).toFixed(2),body:await r.json()};}catch(e){error=e}throw error;}
const login=async(username,password)=>{const r=await req(null,'POST','/auth/login',{username,password});if(!r.body.success)throw Error('login '+username+' status '+r.status);return r.body.data;};
(async()=>{
 const t=await login('teacher','__TEACHER_PASSWORD__');
 const a=await login('admin','__ADMIN_PASSWORD__');
 const classes=await req(t.token,'GET','/teacher/classes');
 const questions=await req(t.token,'GET','/teacher/questions');
 const settings=await req(a.token,'GET','/admin/settings');
 const cleanSettings={};const walk=(o,p='')=>{if(!o||typeof o!=='object')return;for(const [k,v] of Object.entries(o)){if(/model|provider|endpoint|version/i.test(k)&&!/(secret|key|token|password)/i.test(k)&&typeof v!=='object')cleanSettings[p+k]=v;else if(v&&typeof v==='object')walk(v,p+k+'.');}};walk(settings.body);
 const cls=classes.body.data?.[0];const approved=questions.body.data.filter(q=>q.reviewStatus==='approved'&&q.type!=='subjective'&&q.type!=='shortAnswer').slice(0,2);
 const result={date:'2026-10-19',teacherLogin:true,adminLogin:true,classes:classes.body.data,settings:cleanSettings,questionCount:questions.body.data.length,submissions:[],uploads:[]};
 fs.writeFileSync('output/materials/online-api.json',JSON.stringify(result,null,2));
 if(!cls||approved.length<2)throw Error('No class or approved questions');
 const students=[];for(let n=2;n<=6;n++)students.push(await login('student'+n,'__STUDENT_PASSWORD__'));
 const created=await req(t.token,'POST','/teacher/assignments',{title:'材料性能验证20261019',classId:cls.id,questionIds:approved.map(q=>q.id),studentIds:students.map(s=>s.user.id),levels:['strong','medium','weak']});
 result.creation={status:created.status,success:created.body.success,id:created.body.data?.id,paperId:created.body.data?.paperId};
 if(!created.body.success)throw Error('Create assignment '+JSON.stringify(created.body));
 fs.writeFileSync('output/materials/online-api.json',JSON.stringify(result,null,2));
 const answers=Object.fromEntries(approved.map(q=>[q.id,q.answer||q.answer_text||q.answerText||'A']));
 for(let i=0;i<students.length;i++){
  const r=await req(students[i].token,'POST','/student/assignments/'+created.body.data.id+'/submit',{answers,requestId:'materials-20261019-submit-'+i});
  result.submissions.push({student:'student'+(i+2),status:r.status,ms:r.ms,success:r.body.success,recordId:r.body.data?.id,message:r.body.message});
 }
 const image=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jP1kAAAAASUVORK5CYII=','base64');
 const started=performance.now();result.uploads=await Promise.all(students.map(async(s,i)=>{const data=new FormData();data.append('file',new Blob([image],{type:'image/png'}),'material-test.png');const t=performance.now();try{const r=await fetch(base+'/student/answers/upload',{method:'POST',headers:{Authorization:'Bearer '+s.token},body:data,signal:AbortSignal.timeout(20000)});const j=await r.json();return {student:'student'+(i+2),status:r.status,ms:+(performance.now()-t).toFixed(2),success:j.success,size:image.length,filePath:j.data?.filePath};}catch(e){return {success:false,error:e.message}}}));result.uploadTotalMs=+(performance.now()-started).toFixed(2);
 fs.writeFileSync('output/materials/online-api.json',JSON.stringify(result,null,2));
 const deletion=await req(t.token,'DELETE','/teacher/assignments/'+created.body.data.id);result.cleanup={assignmentStatus:deletion.status,success:deletion.body.success,uploadedTestFilesRetained:result.uploads.filter(x=>x.success).length};
 fs.writeFileSync('output/materials/online-api.json',JSON.stringify(result,null,2));
 console.log(JSON.stringify(result,null,2));
})().catch(e=>{console.error(e.message);process.exitCode=1});
