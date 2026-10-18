async (page) => {
  await page.setViewportSize({width:1440,height:1000});
  const browser = await page.evaluate(() => navigator.userAgent);
  const label=browser.includes('Edg/')?'edge':'chrome';
  const root='C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/';
  if(!page.url().includes('/student/')) {
    await page.getByRole('textbox',{name:'请输入用户名'}).fill('student');
    await page.getByRole('textbox',{name:'请输入密码'}).fill('student123');
    await page.getByRole('button',{name:'登 录'}).click();
  }
  await page.waitForURL('**/student/dashboard');
  await page.waitForLoadState('networkidle');
  await page.screenshot({path:root+label+'-dashboard.png'});
  const loads=[];
  for(let i=0;i<5;i++) {
    await page.reload({waitUntil:'networkidle'});
    loads.push(await page.evaluate(()=>{
      const n=performance.getEntriesByType('navigation')[0];
      return {domContentLoaded:n.domContentLoadedEventEnd,load:n.loadEventEnd};
    }));
  }
  const submit=await page.evaluate(async()=>{
    const token=localStorage.getItem('token'); const rows=[];
    for(let i=0;i<5;i++){
      const start=performance.now();
      const r=await fetch('/api/student/assignments/qa-assignment/submit',{
        method:'POST', headers:{'Content-Type':'application/json',Authorization:'Bearer '+token},
        body:JSON.stringify({answers:{'qa-fill':'0.5','qa-proof':'同类项系数相加，得到5x。'},requestId:'materials-'+navigator.userAgent.split(' ').pop()+'-'+i})
      });
      const data=await r.json(); rows.push({ms:performance.now()-start,status:r.status,success:data.success});
    } return rows;
  });
  await page.goto('http://localhost:5003/student/knowledge');
  await page.waitForLoadState('networkidle');
  await page.screenshot({path:root+label+'-knowledge.png'});
  const graph={title:await page.title(),body:(await page.locator('body').innerText()).slice(0,600)};
  await page.goto('http://localhost:5003/login');
  await page.evaluate(()=>{localStorage.clear();document.cookie='session=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;'});
  await page.reload();
  await page.getByRole('textbox',{name:'请输入用户名'}).fill('teacher');
  await page.getByRole('textbox',{name:'请输入密码'}).fill('teacher123');
  await page.getByRole('button',{name:'登 录'}).click();
  await page.waitForURL('**/teacher/dashboard');
  await page.goto('http://localhost:5003/teacher/analytics/class');
  await page.waitForLoadState('networkidle');
  await page.screenshot({path:root+label+'-class.png'});
  return {label,browser,loads,submit,graph,teacher:{title:await page.title(),body:(await page.locator('body').innerText()).slice(0,500)}};
}

