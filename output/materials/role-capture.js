async(page)=>{
 const root='C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/';
 const auth=await page.evaluate(async()=>{const r=await fetch('/api/auth/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({username:'teacher',password:'__TEACHER_PASSWORD__'})});const j=await r.json();if(!j.success)throw Error('Teacher login failed');localStorage.setItem('token',j.data.token);localStorage.setItem('user',JSON.stringify(j.data.user));return j.success;});
 await page.goto('http://123.56.75.115/teacher/analytics/class',{waitUntil:'domcontentloaded'});
 await page.getByRole('heading',{name:'班级学情分析'}).waitFor({timeout:45000});
 await page.locator('canvas').first().waitFor();
 await page.screenshot({path:root+'online-teacher-class.png',timeout:20000});
 return {auth,title:await page.title(),body:(await page.locator('main').innerText()).slice(0,1000)};
}
