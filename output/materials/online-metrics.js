async (page) => {
 const root='C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/';
 const ua=await page.evaluate(()=>navigator.userAgent),label=ua.includes('Edg/')?'edge':'chrome';
 await page.goto('http://123.56.75.115/student/dashboard',{waitUntil:'domcontentloaded'});
 await page.locator('main h1').waitFor();
 await page.getByRole('heading',{name:'知识方格'}).waitFor();
 const loads=[];
 for(let i=0;i<5;i++){
  await page.reload({waitUntil:'domcontentloaded'});
  await page.getByRole('heading',{name:'知识方格'}).waitFor();
  loads.push(await page.evaluate(()=>{const n=performance.getEntriesByType('navigation')[0];return {domContentLoaded:+n.domContentLoadedEventEnd.toFixed(2),appReady:+performance.now().toFixed(2),load:+n.loadEventEnd.toFixed(2)}}));
 }
 const api=await page.evaluate(async()=>{
  const headers={Authorization:'Bearer '+localStorage.getItem('token')};
  const rows=[];for(let i=0;i<5;i++){const t=performance.now();const r=await fetch('/api/student/assignments',{headers});const d=await r.json();rows.push({ms:+(performance.now()-t).toFixed(2),status:r.status,success:d.success});}
  const r=await fetch('/api/teacher/classes',{headers});return {assignments:rows,roleCheck:r.status};
 });
 await page.goto('http://123.56.75.115/student/knowledge',{waitUntil:'domcontentloaded'});
 let graphVisible=false;
 try{await page.getByRole('heading',{name:'知识图谱',exact:true}).waitFor({timeout:15000});graphVisible=true;}catch{}
 return {label,ua,date:'2026-10-19',loads,api,graphVisible,graphTitle:await page.title()};
}
