$ErrorActionPreference='Stop'
$root='C:/Users/32328/Desktop/zhiXiShuXue'
$dir="$root/output/materials"
$pack="$dir/配套证据与源文件"
$pic="$root/output/playwright/materials"
$folders=@('01-2页面与开发过程','01-3开发日志与版本','01-4架构与原型源文件','02-2缺陷修复','02-3兼容性','02-4性能实测','05-2代码规模')
foreach($f in $folders){New-Item -ItemType Directory -Force "$pack/$f" | Out-Null}
foreach($name in @('online-teacher-class','online-admin-knowledge','online-chrome-knowledge','wireframe')){Copy-Item -LiteralPath "$pic/$name.png" -Destination "$pack/01-2页面与开发过程/$name.png" -Force}
git log --no-merges --date=short --format='%h %ad %an %s' | Set-Content -LiteralPath "$pack/01-3开发日志与版本/Git提交记录.txt"
Copy-Item -LiteralPath "$dir/智析数学架构与页面结构.drawio" -Destination "$pack/01-4架构与原型源文件/智析数学架构与页面结构.drawio" -Force
Copy-Item -LiteralPath "$pic/architecture.png" -Destination "$pack/01-4架构与原型源文件/架构预览.png" -Force
Copy-Item -LiteralPath "$pic/wireframe.png" -Destination "$pack/01-4架构与原型源文件/页面结构预览.png" -Force
foreach($name in @('defect-before','defect-after')){Copy-Item -LiteralPath "$pic/$name.png" -Destination "$pack/02-2缺陷修复/$name.png" -Force}
foreach($name in @('online-chrome-student','online-edge-student','online-chrome-knowledge','online-edge-knowledge')){Copy-Item -LiteralPath "$pic/$name.png" -Destination "$pack/02-3兼容性/$name.png" -Force}
foreach($name in @('performance.json','online-api.json')){Copy-Item -LiteralPath "$dir/$name" -Destination "$pack/02-4性能实测/$name" -Force}
Copy-Item -LiteralPath "$pic/network-evidence.png" -Destination "$pack/02-4性能实测/交卷与并发上传记录.png" -Force
Copy-Item -LiteralPath "$dir/tests-recheck.json" -Destination "$pack/02-2缺陷修复/本地回归结果.json" -Force
Copy-Item -LiteralPath "$dir/facts.json" -Destination "$pack/05-2代码规模/代码统计及缺陷复现结果.json" -Force
Copy-Item -LiteralPath "$pic/code-evidence.png" -Destination "$pack/05-2代码规模/代码规模与目录及提交.png" -Force
@'
智析数学补齐材料配套证据
核验日期：2026年10月19日
线上地址：http://123.56.75.115

正文见单独提供的《补齐材料_内容完成版.docx》。此包按附件编号放置原图、实测数据与drawio源文件。
drawio文件包含系统架构与学生工作台结构补绘两页，可用diagrams.net导入编辑。
PNG中的真实线上截图与代码结果整理图已在正文中分别说明。整理图不冒充历史产品截图或浏览器F12原生截图。

技术与证据口径
1. 物理行统计包括注释和空行；非空行统计仍包括注释，排除依赖、构建产物和数据库。Git记录可核对开发过程，但不能代替周例会签到和会议纪要。
2. V0.1至V1.0为按提交整理的阶段归档建议，仓库无对应正式版本标签，正式完成日期须负责人确认。
3. 首页load事件与标题可见时间各取5次样本；可见时间不等于全部异步图表完成时间。交卷时间从发送请求到响应头返回。
4. 并发上传为5张68字节PNG的小样本测试，不代表大文件上传性能或系统最大承载量。
5. 线上测试作业、5份答卷及生成试卷均已通过接口删除。5张微型上传图仍保留；关联学习统计可能留存，不能作为真实教学成效。
6. 本机技术栈为Node.js、Express、SQLite，和原表Java/MySQL描述不一致。服务器系统、带宽及数据库运行版本须登录部署机核验。
7. 本地AI配置为deepseek-chat，百炼备用变量为qwen-plus，不能认定线上正在启用百炼模型。OCR服务商和版本尚无可核实证据。

本包不含项目完整源码、环境密钥或账号密码。
'@ | Set-Content -LiteralPath "$pack/证据说明.txt"
$zip="$dir/配套证据与架构源文件.zip"
Compress-Archive -LiteralPath $pack -DestinationPath $zip -Force
Get-Item -LiteralPath "$dir/补齐材料_内容完成版.docx",$zip | Select-Object FullName,Length
