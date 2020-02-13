Function Get-Xml {

    param()
    
    $PatchSearchXml = $PathReport + '\*.xml'
    $PageReport = Get-Item -Path $PatchSearchXml
    if($PageReport){
    $PageReport.Name | ForEach-Object {
        $PatchArchivo = $PathReport +'\'+ $PSItem
        $Archivo = Get-Content -Path $PatchArchivo -Raw -Encoding Default
        $Archivo = $Archivo.Replace("name", "patchn")
        $Archivo = $Archivo.Replace("description", "name")
        $Archivo | Out-File $PatchArchivo -Encoding utf8    
    }
    }
}