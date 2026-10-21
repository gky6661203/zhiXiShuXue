async(page)=>{
 await page.setViewportSize({width:1100,height:1050});
 const results=[];
 for(const name of ['defect-before','defect-after','architecture','wireframe','code-evidence','network-evidence']){
  await page.goto('http://127.0.0.1:5010/'+name+'.html',{waitUntil:'domcontentloaded'});
  await page.screenshot({path:'C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials/'+name+'.png',fullPage:true});
  results.push(name);
 }return results;
}
