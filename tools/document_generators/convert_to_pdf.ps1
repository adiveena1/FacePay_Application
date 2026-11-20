param(
    [Parameter(Mandatory=$true)]
    [string]$DocxPath,
    [Parameter(Mandatory=$true)]
    [string]$PdfPath
)

$resolvedDocx = (Resolve-Path $DocxPath).Path
$targetPdf = [System.IO.Path]::GetFullPath($PdfPath)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $doc = $word.Documents.Open($resolvedDocx)
    # 17 = wdFormatPDF
    $doc.SaveAs([ref]$targetPdf, [ref]17)
    $doc.Close([ref]$false)
    Write-Output "Successfully converted $resolvedDocx to $targetPdf"
}
catch {
    Write-Error "Error during Word conversion: $_"
    exit 1
}
finally {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
