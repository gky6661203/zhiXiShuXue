$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$base='C:/Users/32328/xwechat_files/wxid_ons1d1bcv1yk22_7bc9/msg/file/2026-10'
$out='C:/Users/32328/Desktop/zhiXiShuXue/output/materials/补齐材料_整理补充版.docx'
$w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'
function Read-ZipXml($path,$entry){
 $z=[IO.Compression.ZipFile]::OpenRead($path)
 try{$r=[IO.StreamReader]::new($z.GetEntry($entry).Open()); try{[xml]$r.ReadToEnd()}finally{$r.Dispose()}}finally{$z.Dispose()}
}
$source=Read-ZipXml "$base/待补齐材料清单.docx" 'word/document.xml'
$ns=[Xml.XmlNamespaceManager]::new($source.NameTable); $ns.AddNamespace('w',$w)
$rows=@()
foreach($row in $source.SelectNodes('//w:tbl/w:tr',$ns)){
 $cells=@($row.SelectNodes('w:tc',$ns))
 if($cells.Count -ne 4){continue}
 $id=($cells[0].SelectNodes('.//w:t',$ns)|ForEach-Object{$_.InnerText}) -join ''
 if($id -in @('5','6','7','8','9','10','11','13','15')){
  $values=@(); foreach($cell in $cells){$values+= (($cell.SelectNodes('.//w:t',$ns)|ForEach-Object{$_.InnerText}) -join '')}
  $rows+= ,$values
 }
}
if($rows.Count -ne 9){throw "Expected 9 rows, got $($rows.Count)"}
Copy-Item -LiteralPath "$base/补齐材料.docx" -Destination $out -Force
(Get-Item -LiteralPath $out).IsReadOnly=$false
$doc=Read-ZipXml $out 'word/document.xml'
$dn=[Xml.XmlNamespaceManager]::new($doc.NameTable); $dn.AddNamespace('w',$w)
$body=$doc.SelectSingleNode('//w:body',$dn); $sect=$body.SelectSingleNode('w:sectPr',$dn)
foreach($tr in $body.SelectNodes('.//w:tbl/w:tr',$dn)){
 $pr=$tr.SelectSingleNode('w:trPr',$dn)
 if(-not $pr){$pr=$doc.CreateElement('w','trPr',$w); $null=$tr.PrependChild($pr)}
 if(-not $pr.SelectSingleNode('w:cantSplit',$dn)){$null=$pr.AppendChild($doc.CreateElement('w','cantSplit',$w))}
}
function Escape($s){[Security.SecurityElement]::Escape($s)}
function Para($text,$size=22,$bold=$false){
 $b=if($bold){'<w:b/>'}else{'<w:b w:val="0"/>'}
 '<w:p><w:pPr><w:spacing w:after="100" w:line="300" w:lineRule="auto"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Calibri" w:eastAsia="宋体"/>'+ $b +'<w:color w:val="000000"/><w:sz w:val="'+$size+'"/></w:rPr><w:t xml:space="preserve">'+(Escape $text)+'</w:t></w:r></w:p>'
}
$xml='<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
$xml+=Para '待补充材料清单' 32 $true
$xml+=Para '以下整理尚未标红的材料，按原清单序号列示。测试环境参数（原序号3）已在本文前部填写，不再重复；其余9项的准备要求及填报位置如下。' 22
$xml+='<w:tbl><w:tblPr><w:tblW w:w="8306" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblBorders>'
foreach($side in @('top','left','bottom','right','insideH','insideV')){$xml+='<w:'+$side+' w:val="single" w:sz="4" w:color="D9D9D9"/>'}
$xml+='</w:tblBorders><w:tblCellMar><w:top w:w="110" w:type="dxa"/><w:left w:w="100" w:type="dxa"/><w:bottom w:w="110" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>'
$widths=@(650,1550,4656,1450)
foreach($width in $widths){$xml+='<w:gridCol w:w="'+$width+'"/>'}; $xml+='</w:tblGrid>'
$all=@(,@('原序号','材料','需补充内容','填报位置'))+$rows
for($i=0;$i -lt $all.Count;$i++){
 $xml+='<w:tr><w:trPr><w:cantSplit/>'; if($i -eq 0){$xml+='<w:tblHeader/>'}; $xml+='</w:trPr>'
 for($c=0;$c -lt 4;$c++){
  $xml+='<w:tc><w:tcPr><w:tcW w:w="'+$widths[$c]+'" w:type="dxa"/><w:vAlign w:val="center"/>'
  if($i -eq 0){$xml+='<w:shd w:fill="E7E6E6"/>'}; $xml+='</w:tcPr>'
  $p=Para $all[$i][$c] 21 ($i -eq 0)
  if($c -eq 0){$p=$p.Replace('<w:pPr>','<w:pPr><w:jc w:val="center"/>')}
  $xml+=$p+'</w:tc>'
 }; $xml+='</w:tr>'
}; $xml+='</w:tbl>'
$xml+=Para '注：原序号13为可选加分项，架构图若已无可编辑源文件可跳过，现有PNG版可保留。原序号5的缺陷修复记录应与前文“缺陷数0”保持一致；如确无缺陷，可注明未发现缺陷、无修复及回归记录。' 21
$frag=$doc.CreateDocumentFragment(); $frag.InnerXml='<wrapper xmlns:w="'+$w+'">'+$xml+'</wrapper>'
foreach($child in @($frag.FirstChild.ChildNodes)){$null=$body.InsertBefore($child,$sect)}
$zip=[IO.Compression.ZipFile]::Open($out,[IO.Compression.ZipArchiveMode]::Update)
try{$zip.GetEntry('word/document.xml').Delete(); $e=$zip.CreateEntry('word/document.xml'); $writer=[IO.StreamWriter]::new($e.Open(),[Text.UTF8Encoding]::new($false)); try{$doc.Save($writer)}finally{$writer.Dispose()}}finally{$zip.Dispose()}
Write-Output $out
Write-Output ('Added original IDs: '+(($rows|ForEach-Object{$_[0]}) -join ', '))
