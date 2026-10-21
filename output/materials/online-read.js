async (page) => {
 await page.setViewportSize({width:1440,height:1000});
 const label=(await page.evaluate(()=>navigator.userAgent)).includes('Edg/')?'edge':'chrome';
 if(!page.url().includes('/student/')){
 await page.getByRole('textbox',{name:'请输入用户名'}).fill('student');
 await page.getByRole('textbox',{name:'请输入密码'}).fill('__STUDENT_PASSWORD__');
 await page.getByRole('button',{name:'登 录'}).click();
 await page.waitForURL('**/student/dashboard');
 }
 await page.waitForLoadState('domcontentloaded');
 await page.screenshot({path:'C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/online-'+label+'-student.png'});
 const results=await page.evaluate(async()=>{
  const token=localStorage.getItem('token');
  const get=async(p)=>{const r=await fetch('/api'+p,{headers:{Authorization:'Bearer '+token}});return {status:r.status,body:await r.json()}};
  return {profile:await get('/student/profile'),assignments:await get('/student/assignments'),denied:await get('/teacher/classes')};
 });
 await page.goto('http://123.56.75.115/student/knowledge');
 await page.waitForLoadState('domcontentloaded');
 await page.screenshot({path:'C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/online-'+label+'-knowledge.png'});
 return {label,...results,body:(await page.locator('body').innerText()).slice(0,600)};
}
