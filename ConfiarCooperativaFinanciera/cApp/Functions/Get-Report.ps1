Function Get-Report {

    param()
	
	
    $ReportGenerate = $PathReportUnit + " " + $PathReport + " " + $PathReport
    invoke-expression $ReportGenerate

    $PatchSearchReport = $PathReport + '\*.html'
    $PageReport = Get-Item -Path $PatchSearchReport
    if($PageReport){
    $PageReport.Name | ForEach-Object {
        $PatchArchivo = $PathReport +'\'+ $PSItem
        $Archivo = Get-Content -Path $PatchArchivo -Raw -Encoding Default

        $Archivo = $Archivo.Replace("<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>", "<link href='../cApp/bin/styles.css' rel='stylesheet' type='text/css'>")
        $Archivo = $Archivo.Replace("<link href='https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.2/css/materialize.min.css' rel='stylesheet' type='text/css'>", "<link href='https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.2/css/materialize.min.css' rel='stylesheet' type='text/css'><link href='../cApp/bin/styles.css' rel='stylesheet' type='text/css'>")
        $Archivo = $Archivo.Replace("http://reportunit.relevantcodes.com/", "https://www.evertecinc.com/")
        $Archivo = $Archivo.Replace("NUnit", $env:USERNAME)
        $Archivo = $Archivo.Replace("<span class='sidenav-filename'>Index</span>", "<span class='sidenav-filename'>Inicio</span>")
        $Archivo = $Archivo.Replace("TestRunner", "Tester")
        $Archivo = $Archivo.Replace("Executive Summary", "Resumen Ejecutivo " + "Portal Financiero Compensar")
        $Archivo = $Archivo.Replace("</span>Warning</li>", "</span>Pending</li>")
        $Archivo = $Archivo.Replace("TestRunner", "Tester")
        $Archivo = $Archivo.Replace(",", ".")
        $Archivo | Out-File $PatchArchivo -Encoding Default
    }

    $Element = Get-ChildItem -Path $PageReport | Group-Object Extension -NoElement
    if($Element.Count -gt 1 ){
        Invoke-Item $PathReport'\Index.html'
    }
    else{
        Invoke-Item $PathReport'\*.html'
    }
    Remove-Item -Path "Reportes/*.xml"
}
}