async(page)=>{
 await page.setViewportSize({width:1440,height:1000});
 await page.getByRole('textbox',{name:'请输入用户名'}).fill('admin');
 await page.getByRole('textbox',{name:'请输入密码'}).fill('__ADMIN_PASSWORD__');
 await page.getByRole('button',{name:'登 录'}).click();
 await page.waitForURL('**/admin/dashboard');
 const settings=await page.evaluate(async()=>{
  const r=await fetch('/api/admin/settings',{headers:{Authorization:'Bearer '+localStorage.getItem('token')}});const j=await r.json();const d=j.data||{};
  return {status:r.status,provider:d.aiTutorProvider||'',model:d.aiTutorModel||d.llmModel||'',endpoint:d.aiTutorApiEndpoint||d.llmApiEndpoint||'',enabled:d.aiTutorEnabled};
 });
 await page.goto('http://123.56.75.115/admin/knowledge',{waitUntil:'domcontentloaded'});
 return {settings,url:page.url()};
}
