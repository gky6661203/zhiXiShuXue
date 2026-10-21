$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing
$dir='C:/Users/32328/Desktop/zhiXiShuXue/output/materials'
$pictures='C:/Users/32328/Desktop/zhiXiShuXue/output/playwright/materials'
$source='C:/Users/32328/xwechat_files/wxid_ons1d1bcv1yk22_7bc9/msg/file/2026-10/补齐材料.docx'
$out="$dir/补齐材料_内容完成版.docx"
$facts=Get-Content "$dir/facts.json" -Raw | ConvertFrom-Json
$perf=Get-Content "$dir/performance.json" -Raw | ConvertFrom-Json
$tests=Get-Content "$dir/tests-recheck.json" -Raw | ConvertFrom-Json
$w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'
function E($t){[Security.SecurityElement]::Escape([string]$t)}
function P([string]$text,[int]$size=22,[bool]$bold=$false,[bool]$keep=$false){
 $b=if($bold){1}else{0};$k=if($keep){'<w:keepNext/>'}else{''}
 '<w:p><w:pPr>'+$k+'<w:snapToGrid w:val="0"/><w:spacing w:before="0" w:after="80" w:line="280" w:lineRule="auto"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Calibri" w:eastAsia="宋体"/><w:b w:val="'+$b+'"/><w:bCs w:val="'+$b+'"/><w:color w:val="000000"/><w:sz w:val="'+$size+'"/><w:szCs w:val="'+$size+'"/></w:rPr><w:t xml:space="preserve">'+(E $text)+'</w:t></w:r></w:p>'
}
function Heading($text){$style=if($text -eq '补齐材料补充正文'){'<w:pStyle w:val="Title"/>'}else{''};(P $text 30 $true $true).Replace('<w:pPr>','<w:pPr>'+$style+'<w:pageBreakBefore/>')}
function Sub($text){P $text 24 $true $true}
function PageBreak{''}
function T($headers,$rows,$widths){
 $xml='<w:tbl><w:tblPr><w:tblW w:w="8306" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblBorders>'
 foreach($side in @('top','left','bottom','right','insideH','insideV')){$xml+='<w:'+$side+' w:val="single" w:sz="4" w:color="D9D9D9"/>'}
 $xml+='</w:tblBorders><w:tblCellMar><w:top w:w="80" w:type="dxa"/><w:left w:w="100" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>'
 foreach($width in $widths){$xml+='<w:gridCol w:w="'+$width+'"/>'};$xml+='</w:tblGrid>'
 $all=@(,$headers)+$rows
 for($i=0;$i -lt $all.Count;$i++){
  $xml+='<w:tr><w:trPr><w:cantSplit/>';if($i -eq 0){$xml+='<w:tblHeader/>'};$xml+='</w:trPr>'
  for($c=0;$c -lt $headers.Count;$c++){
   $xml+='<w:tc><w:tcPr><w:tcW w:w="'+$widths[$c]+'" w:type="dxa"/><w:vAlign w:val="center"/>'
   if($i -eq 0){$xml+='<w:shd w:fill="E7E6E6"/>'};$xml+='</w:tcPr>'+(P $all[$i][$c] 21 ($i -eq 0))+'</w:tc>'
  };$xml+='</w:tr>'
 };$xml+='</w:tbl>'+(P '' 8);$xml
}
$script:images=@()
function Pic($name,$caption,$width=5.65,$maxHeight=7.3){
 $path="$pictures/$name.png";if(-not(Test-Path -LiteralPath $path)){throw "Missing image $name"}
 $img=[Drawing.Image]::FromFile($path);$height=$width*$img.Height/$img.Width;$img.Dispose()
 if($height -gt $maxHeight){$width=$width*$maxHeight/$height;$height=$maxHeight}
 $id=100+$script:images.Count;$rel="rIdMaterial$id";$filename="material$id.png";$script:images+=@{path=$path;name=$filename;rel=$rel}
 $cx=[int64]($width*914400);$cy=[int64]($height*914400)
 '<w:p><w:pPr><w:jc w:val="center"/><w:keepNext/><w:spacing w:after="40"/></w:pPr><w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="'+$cx+'" cy="'+$cy+'"/><wp:docPr id="'+$id+'" name="'+$filename+'" descr="'+(E $caption)+'"/><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:nvPicPr><pic:cNvPr id="0" name="'+$filename+'"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="'+$rel+'"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="'+$cx+'" cy="'+$cy+'"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>'+(P $caption 19)
}
function Avg($a){[math]::Round(($a|Measure-Object -Average).Average,2)}
$x=PageBreak
$x+=Heading '补齐材料补充正文'
$x+=P '智析数学初中数学智能学情分析平台' 26 $true
$x+=P '核验日期 2026年10月19日    测试站点 http://123.56.75.115' 22
$x+=P '本部分提供测试环境复核、历史缺陷修复、浏览器兼容性、性能实测、开发阶段与日志、页面及架构图、技术栈和代码规模材料。前文的环境参数表和8条功能测试记录原样保留。'
$x+=Sub '一 测试环境参数复核'
$envRows=@(
 ,@('线上服务器','原表登记2核、4GB、5M带宽、CentOS 7.9；服务器配置尚需控制台核验。')
 ,@('数据存储','原表登记MySQL 8.0；当前工程使用SQLite。提交正式报告时须统一为实际部署版本。')
 ,@('本机设备','ASUS TUF Gaming F15 FX507ZV4；Intel Core i7-12700H 14核；约16GB内存。')
 ,@('本机系统','Windows 11家庭版中文版，系统版本10.0.26200。')
 ,@('浏览器','Chrome 156.0.8078.36；Microsoft Edge 155.0.4283.45；桌面视口1440×1000，自动化无头模式。')
 ,@('访问网络','本机经公网HTTP访问测试站点，未施加网络限速；本次未测得接入带宽，原表100M WiFi不作为实测值。')
 ,@('本地运行时',"Node.js $($facts.node)；Node内置SQLite $($facts.sqlite)；npm 11.3.0。以上为本机版本，不能代替服务器版本。")
 )
$x+=T @('项目','核验信息') $envRows @(1700,6606)
$x+=P '线上核验使用学校演示角色账号，文档及附件不包含登录密码或API密钥。性能测试使用单独命名的验证作业，未覆盖既有作业内容。' 21

$x+=PageBreak;$x+=Heading '二 历史缺陷修复记录'
$x+=P '对应报告3.2与附件02-2。以下2项来自2026年10月14日提交10d241d7前后的实际代码差异，并于2026年10月19日重新运行函数复现。前文“缺陷数0”表示当时8条功能用例未发现缺陷，与本节历史已修复缺陷分别统计。'
$x+=Sub 'D01 分数与小数等价答案误判'
$x+=P '缺陷描述：填空题标准答案为1/2，学生填写0.5时，旧版将数学等价答案判断为错误。建议等级：中，影响客观题评分准确性。'
$x+=P '复现步骤：建立填空题，type设为fill、answer设为1/2；调用旧版gradeAnswer并传入0.5；观察isCorrect为false。'
$x+=P '原因：旧版只对答案做去空格、转小写后的字符串比较，未处理分数、小数及代数式的数学等价关系。'
$x+=P '修复方式与版本：提交10d241d7改用math-equivalence模块的equivalent函数，同时匹配acceptedAnswers；当前ef5efd61工作区仍包含该修复。'
$x+=P '回归结果：同一输入在当前版本返回isCorrect=true、needsReview=false。数学等价测试同时覆盖分数、小数、百分数及代数式；无效表达式不应被判为等价。'
$x+=Sub 'D02 主观题缺少步骤复核'
$x+=P '缺陷描述：旧版按最终答案与标准答案的文本相似度判定主观题正误，即使没有提供独立步骤证据，也可能直接判为正确。建议等级：高，影响证明题及分步给分的有效性。'
$x+=P '复现步骤：题型设为subjective；标准答案与提交内容均设为“同类项系数相加，得到5x。”；旧版gradeAnswer直接返回isCorrect=true。'
$x+=P '原因：旧版采用正则匹配或0.8相似度阈值作为终判依据，没有将推理过程交由教师逐步复核。'
$x+=P '修复方式与版本：提交10d241d7将主观题设置为isCorrect=null、needsReview=true，仅提供suggestedCorrect参考。教师通过复核队列按步骤评分后，再同步学习记录。'
$x+=P '回归结果：当前版本同一输入返回needsReview=true、isCorrect=null；工作流测试验证主观题提交、教师复核、分步评分与重复复核的数据一致性。'
$x+=P '复现截图见下页；其内容为真实函数执行输出的展示页，不是历史产品界面留影。' 21

$x+=PageBreak;$x+=Heading '缺陷复现与回归截图'
$x+=Pic 'defect-before' '图1 修复前结果回放 1/2与0.5判错 主观题直接判对' 5.4 3.85
$x+=Pic 'defect-after' '图2 修复后结果回放 等价答案判对 主观题进入教师复核' 5.4 4.05

$x+=PageBreak;$x+=Heading '三 浏览器兼容性验证'
$x+=P '对应报告表5、3.3与附件02-3。测试日期2026年10月19日，Chrome与Edge使用相同学生账号、相同站点和1440×1000视口。验证范围为登录、学生首页、知识图谱、作业列表读取以及角色权限限制。'
$compat=@(
 ,@('Chrome','156.0.8078.36','学生登录成功；首页与知识图谱可显示；作业列表5次HTTP 200；访问教师接口HTTP 403。')
 ,@('Edge','155.0.4283.45','学生登录成功；首页与知识图谱可显示；作业列表5次HTTP 200；访问教师接口HTTP 403。')
 )
$x+=T @('浏览器','实际版本','验证结果') $compat @(1300,1900,5106)
$x+=P '结论：两种浏览器在本次覆盖范围内均可使用。采集期间出现页面和字体资源加载等待超时，刷新后可完成；知识图谱部分节点标签较密集。以上现象保留为展示与性能改进项，本次未开展Firefox及移动端兼容性验证。' 21
$x+=Pic 'online-chrome-student' '图3 Chrome学生首页 实际线上页面' 5.25 2.4
$x+=Pic 'online-edge-student' '图4 Edge学生首页 相同视口对比' 5.25 2.4

$x+=PageBreak;$x+=Heading '四 性能测试数据'
$x+=P '对应报告表6、3.4与附件02-4。首页采用已登录学生工作台热缓存刷新，连续采样5次。浏览器Navigation Timing记录DOMContentLoaded与load事件；页面可见时间记录至“知识方格”标题可见，不代表所有异步统计和图表均已完成。'
$mr=@();for($i=0;$i -lt 5;$i++){$c=$perf.metrics.chrome.loads[$i];$e=$perf.metrics.edge.loads[$i];$mr+= ,@(($i+1),$c.load,$c.appReady,$e.load,$e.appReady)}
$mr+= ,@('平均',(Avg $perf.metrics.chrome.loads.load),(Avg $perf.metrics.chrome.loads.appReady),(Avg $perf.metrics.edge.loads.load),(Avg $perf.metrics.edge.loads.appReady))
$x+=T @('样本','Chrome load ms','Chrome可见 ms','Edge load ms','Edge可见 ms') $mr @(700,1800,2050,1750,2006)
$x+=Sub '单份试卷交卷响应'
$x+=P '使用单独创建的“材料性能验证20261019”作业，包含2道已审核客观题。student2至student6各提交1份，共5份；同一题量、不同学生，用于避免重复交卷缓存影响。耗时从发送请求计至响应头返回，不包含教师复核或大模型处理。'
$sr=@();for($i=0;$i -lt $perf.api.submissions.Count;$i++){$r=$perf.api.submissions[$i];$sr+= ,@(($i+1),$r.student,$r.ms,$r.status, $(if($r.success){'成功'}else{'失败'}))}
$sr+= ,@('平均','5份',(Avg $perf.api.submissions.ms),'200','5/5成功')
$x+=T @('样本','账号','响应耗时 ms','HTTP','结果') $sr @(800,1600,2500,1300,2106)
$x+=Sub '并发上传验证'
$x+=P "5个学生账号同时上传PNG测试图片，每张68字节；5个请求均返回HTTP 200，全组结束耗时$($perf.api.uploadTotalMs) ms，单请求平均$(Avg $perf.api.uploads.ms) ms。此项只验证轻量并发上传连通性，不作为大文件、整卷扫描件或高并发容量结论。"
$x+=P '本次为公网单客户端、小样本测量，缓存、资源加载和网络抖动均影响结果。不能由这些数字推断峰值承载能力或学校多班级同时使用时的表现。' 21

$x+=PageBreak;$x+=Heading '性能原始结果整理与自动化回归'
$x+=Pic 'network-evidence' '图5 线上交卷与并发上传真实测量记录 可视化整理页' 5.65 6.1
$x+=P "本地当前工作区复查：$($tests.numTotalTestSuites)个测试套件、$($tests.numTotalTests)项测试，$($tests.numPassedTests)项通过、$($tests.numFailedTests)项失败。首次执行曾有1项因ECONNRESET失败，复查全部通过；不据此声称线上系统不存在缺陷。" 21
$x+=P '图5不是F12开发者工具的原生截图。交卷与上传原始数值、浏览器计时记录已随证据附件提供。原生F12截图若为申报格式硬性要求，仍需在现场浏览器另存。' 21
$x+=P '测试清理：验证作业与5份答卷已删除，生成的测试试卷清理结果见原始记录；5张微型测试图保留于上传目录。提交产生的学习统计可能仍保留，不作为真实学生学习效果佐证。' 21

$x+=PageBreak;$x+=Heading '五 开发阶段与版本归档'
$x+=P '对应附件01-3表2。仓库没有V0.1、V0.5、V0.9、V1.0发布标签，因此下表作为按现有提交整理的阶段归档建议，日期为可追溯的代码提交日期，不直接认定为正式发布日期。'
$vr=@(
 ,@('V0.1','2026-03-31','f4bf264f','初始工程版本，首次代码提交。')
 ,@('V0.5','2026-04-05','4dc1cba1','提交说明“完成初步闭环”，包含作业发布、学生提交、教师批改和结果回看。')
 ,@('V0.9','2026-04-23','8c03c196','提交说明学生端功能基本实现，增加AI小智；后续继续优化界面。')
 ,@('V1.0','2026-10-14','10d241d7','提交说明“完成更新”；本地包版本号为1.0.0，后续10月18日恢复AI功能。')
 )
$x+=T @('阶段','归档日期','提交号','阶段内容') $vr @(1000,1550,1350,4406)
$x+=Sub '当前归档版本'
$x+=P "当前工作区Git版本为$($facts.head.Substring(0,8))，最新提交日期2026年10月18日，提交说明为恢复AI。前端、后端与根package.json均声明版本1.0.0，技术版本统计取自本机实际安装依赖。"
$x+=Sub '主要交付路径'
$x+=P '学生端以在线作答、结果回看、知识图谱、薄弱补练、错题本和学习轨迹构成学习闭环。教师端完成班级与学生管理、题目审核、作业发布、步骤复核及班级和学生学情查看。管理员负责账号、知识点、题库、设置和运行记录。'
$x+=P '正式归档时应由负责人核定阶段名称与发布日期。现有Git证据能够证明代码形成顺序和提交时间，但不能代替验收签字、会议决定或发布审批记录。' 21

$x+=PageBreak;$x+=Heading '六 开发日志'
$x+=P '对应附件01-3表3。按有实际提交的自然周整理，参与人采用Git提交作者署名；完成情况仅描述提交中有证据的工作。无提交记录的周不补写工作量。'
$logs=@(
 ,@('03-30至04-05','tianya-create、苟开源','建立工程；完成初步闭环。','f4bf264f、4dc1cba1。完善班级学生导入、答题结果、教师查看和错题重做。')
 ,@('04-06至04-12','tianya-create、苟开源','补齐教师端；完善薄弱补练；修复已知问题。','cc1fa05b、be82dd91、56df048f。教师功能与补练持续完善。')
 ,@('04-13至04-19','tianya-create','继续完善相关功能并合并开发分支。','f817984b、6881efa0。具体任务以相应提交差异为准。')
 ,@('04-20至04-26','苟开源、tianya-create','学生端基本完成；加入AI；统一页面风格与登录页。','8c03c196、68a3a028、c4776373、755c4c93、794c131c。完成多轮UI调整。')
 ,@('04-27至05-03','tianya-create、苟开源','调整题库与界面；回退一次界面变更；修复问题。','62bc7e35、75fd3fe7、2fe52f40。界面变更通过回退与后续提交处理。')
 ,@('05-18至05-24','Fancl','优化界面样式。','fa3cd949。提交说明为Optimize UI styling。')
 ,@('06-08至06-14','Fancl、苟开源','调整作业UI；更改AI模型；整理依赖安装与忽略规则。','57dd0c41、193845fd、623a51ad、02598c67。恢复忽略规则并自动安装前后端依赖。')
 ,@('10-12至10-18','苟开源','前端优化；完成更新；恢复AI功能。','fda074f0、10d241d7、ef5efd61。批改与鉴权修复详见缺陷记录。')
 )
$x+=T @('2026年周区间','提交作者','工作内容','完成情况与问题处理依据') $logs @(1500,1500,2400,2906)
$x+=P '周例会的签到、会议纪要和聊天截图未随现有资料提供，本节不把Git提交替写成会议记录。需要提交周例会附件时，应补入项目组原始记录。' 21

$x+=PageBreak;$x+=Heading '七 原型补绘与开发过程截图'
$x+=P '对应报告2.5与附件01-2。下图依据当前学习工作台补绘，表达导航、任务、知识方格和复习区的布局关系；其形成日期为2026年10月19日，不作为早期历史原型证据。'
$x+=Pic 'wireframe' '图6 学生学习工作台结构补绘 可编辑源文件见附件' 5.65 6.75
$x+=P '页面布局说明：左侧为学生导航；主区顶部提示当天优先任务；中部以知识方格显示掌握状态；下部集中作业、错题和复习入口；右下角保留AI助教入口。' 21

$x+=PageBreak;$x+=Heading '线上成品与知识点管理截图'
$x+=Pic 'online-teacher-class' '图7 教师班级学情页面 2026年10月19日线上截图' 5.65 3.9
$x+=P '班级页显示平均分、学生人数、已完成作业、掌握度、成绩排名与知识点统计。截图为系统演示数据状态，不单独作为学校试点成效证明。' 21
$x+=Pic 'online-admin-knowledge' '图8 管理员知识点管理页面 实际线上界面' 5.65 3.9

$x+=PageBreak;$x+=Heading '知识图谱与前后端联调说明'
$x+=Pic 'online-chrome-knowledge' '图9 学生知识图谱 五大模块与知识点前置关系' 5.65 4.2
$x+=Sub '前后端联调结果'
$x+=P '浏览器通过HTTP调用后端REST接口并携带JWT身份凭据。线上学生资料、作业列表返回HTTP 200；学生身份访问教师班级接口返回HTTP 403。教师可登录并打开班级学情，管理员可登录并查看知识点管理。'
$x+=P '线上性能验证作业发布后，5个演示学生分别交卷成功；图片上传接口完成5个并发小图请求。请求的状态码、耗时、验证作业标识及清理结果见原始数据附件。'
$x+=P '图谱中节点颜色与测评状态对应；未测评或样本不足不直接显示为已掌握。部分节点文字在当前1440像素视口较密集，仍可继续优化标签布局。' 21

$x+=PageBreak;$x+=Heading '八 技术栈版本与开发工具'
$x+=P '对应附件01-5表1及第三部分。以下版本来自2026年10月19日本机安装包和运行环境；线上服务器运行时版本须以部署机查询为准。'
$tr=@(
 ,@('前端框架',"Vue $($facts.versions.vue)",'组件化页面与三角色前端。')
 ,@('界面组件',"Element Plus $($facts.versions.'element-plus')",'表单、表格、弹窗和交互组件。')
 ,@('构建与路由',"Vite $($facts.versions.vite)；Vue Router $($facts.versions.'vue-router')",'前端构建、路由与页面加载。')
 ,@('状态与图表',"Pinia $($facts.versions.pinia)；ECharts $($facts.versions.echarts)",'用户状态与学情可视化。')
 ,@('后端',"Node.js $($facts.node)；Express $($facts.versions.express)",'REST API与业务服务；当前工程不使用Java后端。')
 ,@('数据存储',"SQLite $($facts.sqlite)",'Node内置node:sqlite；题库与业务数据持久化。')
 ,@('身份认证',"jsonwebtoken $($facts.versions.jsonwebtoken)；bcryptjs $($facts.versions.bcryptjs)",'JWT认证、密码散列与角色权限。')
 ,@('通信与上传',"Axios $($facts.versions.axios)；ws $($facts.versions.ws)；Multer $($facts.versions.multer)",'HTTP请求、WebSocket和受控文件上传。')
 ,@('AI模型','本地启用配置deepseek／deepseek-chat；百炼备用模型变量qwen-plus。','配置支持兼容接口；不得将备用变量写成线上已启用模型。线上管理接口未返回有效模型名，仍须核对部署配置。')
 ,@('OCR接口','未取得服务商、接口地址或版本的可验证证据。','当前已核实PNG/JPEG图片上传；上传功能不能等同于OCR识别。')
 ,@('工具',"Git 2.49.0.windows.1；npm 11.3.0；Jest $($facts.versions.jest)；Playwright CLI",'版本管理、依赖安装、自动化回归与浏览器核验。IDE和Postman使用记录未核实，不补写版本。')
 )
$x+=T @('类别','名称与版本','用途与核验说明') $tr @(1300,3100,3906)

$x+=PageBreak;$x+=Heading '九 系统架构可编辑源文件'
$x+=P '对应附件01-4。已按当前工程补绘系统架构，并提供drawio可编辑文件，包含“系统架构”和“学生工作台结构补绘”两个页面。'
$x+=Pic 'architecture' '图10 智析数学系统架构图' 5.65 6.5
$x+=P '浏览器前端经REST API接入Express服务。鉴权、角色和班级隔离先于业务处理；教学分析服务负责作业、答卷、批改、复核、掌握度和推荐，SQLite保存结构化数据，上传目录保存图片。AI助教为可配置外部服务，未核实的OCR能力不列入已完成架构。' 21

$x+=PageBreak;$x+=Heading '十 代码规模与提交记录'
$x+=P '对应附件05-2。统计对象为Git已跟踪的当前源文件，排除node_modules、构建产物、图片、数据库、配置与文档；物理行数包含空行和注释，非空行数仍包含注释，不等同于有效代码行。'
$cr=@(
 ,@('前端src下vue js css', $facts.frontend.files,$facts.frontend.total,$facts.frontend.nonempty)
 ,@('后端js 不含test', $facts.backend.files,$facts.backend.total,$facts.backend.nonempty)
 ,@('测试辅助js 独立统计',$facts.tests.files,$facts.tests.total,$facts.tests.nonempty)
 )
$x+=T @('统计范围','文件数','物理行数','非空行数') $cr @(3806,1200,1700,1600)
$x+=P "Git历史共$($facts.commits)次提交，其中非合并提交$($facts.nonMergeCommits)次。首条记录日期2026年3月31日，当前最新提交日期2026年10月18日。主要作者署名包括tianya-create、苟开源、Fancl等，署名不能直接替代正式成员分工证明。"
$x+=Pic 'code-evidence' '图11 目录结构 代码统计及最近提交记录整理图' 5.65 4.8
$x+=P '证据附件提供Git简表、完整非合并提交日期摘要、统计口径和文件清单；不打包项目完整源码，不包含.env、登录凭据或API密钥。' 21

# Preserve original document and append OOXML content with image relationships.
Copy-Item -LiteralPath $source -Destination $out -Force;(Get-Item -LiteralPath $out).IsReadOnly=$false
$zip=[IO.Compression.ZipFile]::Open($out,[IO.Compression.ZipArchiveMode]::Update)
function ReadEntry($name){$r=[IO.StreamReader]::new($zip.GetEntry($name).Open());try{[xml]$r.ReadToEnd()}finally{$r.Dispose()}}
function WriteEntry($name,$xml){$old=$zip.GetEntry($name);if($old){$old.Delete()};$e=$zip.CreateEntry($name);$s=[IO.StreamWriter]::new($e.Open(),[Text.UTF8Encoding]::new($false));try{$xml.Save($s)}finally{$s.Dispose()}}
try{
 $doc=ReadEntry 'word/document.xml';$ns=[Xml.XmlNamespaceManager]::new($doc.NameTable);$ns.AddNamespace('w',$w)
 $body=$doc.SelectSingleNode('//w:body',$ns);$sect=$body.SelectSingleNode('w:sectPr',$ns)
 foreach($row in $body.SelectNodes('.//w:tbl/w:tr',$ns)){$pr=$row.SelectSingleNode('w:trPr',$ns);if(-not $pr){$pr=$doc.CreateElement('w','trPr',$w);$null=$row.PrependChild($pr)};if(-not $pr.SelectSingleNode('w:cantSplit',$ns)){$null=$pr.AppendChild($doc.CreateElement('w','cantSplit',$w))}}
 $frag=$doc.CreateDocumentFragment();$frag.InnerXml='<wrapper xmlns:w="'+$w+'" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'+$x+'</wrapper>'
 foreach($child in @($frag.FirstChild.ChildNodes)){$null=$body.InsertBefore($child,$sect)}
 WriteEntry 'word/document.xml' $doc
 $rels=ReadEntry 'word/_rels/document.xml.rels'
 foreach($item in $script:images){$rel=$rels.CreateElement('Relationship',$rels.DocumentElement.NamespaceURI);$rel.SetAttribute('Id',$item.rel);$rel.SetAttribute('Type','http://schemas.openxmlformats.org/officeDocument/2006/relationships/image');$rel.SetAttribute('Target','media/'+$item.name);$null=$rels.DocumentElement.AppendChild($rel);$entry=$zip.CreateEntry('word/media/'+$item.name);$s=$entry.Open();try{$bytes=[IO.File]::ReadAllBytes($item.path);$s.Write($bytes,0,$bytes.Length)}finally{$s.Dispose()}}
 WriteEntry 'word/_rels/document.xml.rels' $rels
 $types=ReadEntry '[Content_Types].xml';if(-not ($types.DocumentElement.ChildNodes|Where-Object{$_.Extension -eq 'png'})){$e=$types.CreateElement('Default',$types.DocumentElement.NamespaceURI);$e.SetAttribute('Extension','png');$e.SetAttribute('ContentType','image/png');$null=$types.DocumentElement.AppendChild($e)};WriteEntry '[Content_Types].xml' $types
}finally{$zip.Dispose()}
Write-Output "Created $out with $($script:images.Count) figures"



