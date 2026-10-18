$ErrorActionPreference='Stop'
$dir='C:/Users/32328/Desktop/zhiXiShuXue/output/materials'
Add-Type -AssemblyName System.Drawing
$word=New-Object -ComObject Word.Application
$word.Visible=$false
try{
 $doc=$word.Documents.Open("$dir/补齐材料_整理补充版.docx",$false,$true)
 $doc.Repaginate()
 $word.ActiveWindow.View.Type=3
 $count=$doc.ComputeStatistics(2)
 Write-Output "Pages: $count"
 $doc.ExportAsFixedFormat("$dir/qa-final.pdf",17)
 for($i=1;$i -le $count;$i++){
  $page=$word.ActiveWindow.Panes.Item(1).Pages.Item($i)
  [byte[]]$bits=$page.EnhMetaFileBits
  $ms=[IO.MemoryStream]::new($bits,0,$bits.Length)
  $mf=[Drawing.Imaging.Metafile]::new($ms)
  $bmp=[Drawing.Bitmap]::new(1240,1754)
  $g=[Drawing.Graphics]::FromImage($bmp); $g.Clear([Drawing.Color]::White)
  $g.DrawImage($mf,[Drawing.Rectangle]::new(0,0,1240,1754))
  $bmp.Save("$dir/page-$i.png",[Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose(); $mf.Dispose(); $ms.Dispose()
 }
 $doc.Close(0)
}finally{$word.Quit()}
