async(page)=>{
 await page.setViewportSize({width:1440,height:1000});
 await page.getByRole('textbox',{name:'请输入用户名'}).fill('teacher');
 await page.getByRole('textbox',{name:'请输入密码'}).fill('__TEACHER_PASSWORD__');
 await page.getByRole('button',{name:'登 录'}).click();
 await page.waitForURL('**/teacher/dashboard');
 const data=await page.evaluate(async()=>{
  const headers={Authorization:'Bearer '+localStorage.getItem('token')};
  const get=async(p)=>(await (await fetch('/api/teacher'+p,{headers})).json()).data;
  const classes=await get('/classes'),questions=await get('/questions');
  return {classes,questions:questions.filter(q=>q.reviewStatus==='approved').slice(0,8)};
 });
 await page.goto('http://123.56.75.115/teacher/analytics/class',{waitUntil:'domcontentloaded'});
 await page.getByRole('heading',{name:'班级学情分析'}).waitFor();
 await page.locator('canvas').first().waitFor();
 await page.screenshot({path:'C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/online-teacher-class.png',timeout:15000});
 return {data,body:(await page.locator('main').innerText()).slice(0,1000)};
}
