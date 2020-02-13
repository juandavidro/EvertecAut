function Select-Test {

    <#
	.SYNOPSIS
        Presenta un Windows Forms en el que se selecciona la prueba a ejecutar.
    .DESCRIPTION
        Presenta un Windows Forms en el que por medio de un grupo de check box se debe seleccionar las transacciones a probar.
    .EXAMPLE

    .NOTES
        Author:        
        Purpose/Change: 
#>

    param()

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Confiar'
    $form.Size = New-Object System.Drawing.Size(220, 300)
    $form.StartPosition = 'CenterScreen'

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 30)
    $label.Size = New-Object System.Drawing.Size(80, 40)
    $label.Text = 'Seleccione la prueba:'
    $form.Controls.Add($label)

    $CheckBox1 = New-Object System.Windows.Forms.CheckBox
    $CheckBox1.Location = New-Object System.Drawing.Point(10, 70)
    $CheckBox1.Size = New-Object System.Drawing.Size(100, 40)

    $CheckBox2 = New-Object System.Windows.Forms.CheckBox
    $CheckBox2.Location = New-Object System.Drawing.Point(110, 70)
    $CheckBox2.Size = New-Object System.Drawing.Size(100, 40)

    $CheckBox3 = New-Object System.Windows.Forms.CheckBox
    $CheckBox3.Location = New-Object System.Drawing.Point(10, 100)
    $CheckBox3.Size = New-Object System.Drawing.Size(100, 40)

    $CheckBox4 = New-Object System.Windows.Forms.CheckBox
    $CheckBox4.Location = New-Object System.Drawing.Point(110, 100)
    $CheckBox4.Size = New-Object System.Drawing.Size(100, 40)

    $CheckBox5 = New-Object System.Windows.Forms.CheckBox
    $CheckBox5.Location = New-Object System.Drawing.Point(10, 130)
    $CheckBox5.Size = New-Object System.Drawing.Size(100, 40)

    $CheckBox6 = New-Object System.Windows.Forms.CheckBox
    $CheckBox6.Location = New-Object System.Drawing.Point(110, 130)
    $CheckBox6.Size = New-Object System.Drawing.Size(100, 40)

    $CheckBox1.Text = 'Cargue Clientes'
    $CheckBox2.Text = 'Cargue Bloqueos'
    $CheckBox3.Text = 'IVR'
    $CheckBox4.Text = 'Tarjeta con mismo BIN'
    $CheckBox5.Text = 'Pin Pad'
    $CheckBox6.Text = 'Realce'

    $form.Controls.Add($CheckBox1)
    $form.Controls.Add($CheckBox2)
    $form.Controls.Add($CheckBox3)
    $form.Controls.Add($CheckBox4)
    $form.Controls.Add($CheckBox5)
    $form.Controls.Add($CheckBox6)
    
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(25, 230)
    $OKButton.Size = New-Object System.Drawing.Size(75, 23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(100, 230)
    $CancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $form.Topmost = $true


    $result = $form.ShowDialog()
    $Items = @($null)
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        if($CheckBox1.Checked){
            $Items += @($CheckBox1.Text)
        }
        if($CheckBox2.Checked){
            $Items += @($CheckBox2.Text)
        }
        if($CheckBox3.Checked){
            $Items += @($CheckBox3.Text)
        }
        if($CheckBox4.Checked){
            $Items += @($CheckBox4.Text)
        }
        if($CheckBox5.Checked){
            $Items += @($CheckBox5.Text)
        }
        if($CheckBox6.Checked){
            $Items += @($CheckBox6.Text)
        }
    }
    return $Items
}