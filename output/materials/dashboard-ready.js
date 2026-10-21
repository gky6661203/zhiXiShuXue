async(page)=>{
 const label=(await page.evaluate(()=>navigator.userAgent)).includes('Edg/')?'edge':'chrome';
 await page.evaluate(async()=>{const r=await fetch('/api/auth/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({username:'student',password:'__STUDENT_PASSWORD__'})});const j=await r.json();if(!j.success)throw Error('login');localStorage.setItem('token',j.data.token);localStorage.setItem('user',JSON.stringify(j.data.user));});
 await page.goto('http://123.56.75.115/student/dashboard',{waitUntil:'domcontentloaded'});
 await page.getByRole('button',{name:/整式，待巩固/}).first().waitFor({timeout:45000});
 await page.screenshot({path:'C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/online-'+label+'-student.png',timeout:20000});
 return {label,title:await page.title()};
}
