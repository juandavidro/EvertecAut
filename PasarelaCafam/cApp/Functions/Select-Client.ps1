function Select-Client {

    <#
	.SYNOPSIS
        Presenta un Windows Forms en el que se selecciona el cliente.
    .DESCRIPTION
        Presenta un Windows Forms en el que por medio de una lista desplegable se debe seleccionar el cliente al que corresponde la ejecucion de las pruebas.
    .EXAMPLE

    .NOTES
        Author:         JRojass
        Creation Date:  03/05/2019
        Purpose/Change:
#>

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Pasarela de Pagos'
    $form.Size = New-Object System.Drawing.Size(300, 150)
    $form.StartPosition = 'CenterScreen'

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 30)
    $label.Size = New-Object System.Drawing.Size(80, 20)
    $label.Text = 'Cliente'
    $form.Controls.Add($label)

    $listBox1 = New-Object System.Windows.Forms.ComboBox
    $listBox1.DropDownWidth = 260
    $listBox1.Items.Add("Compensar")
    $listBox1.Items.Add("Cafam")
    $listBox1.Location = New-Object System.Drawing.Point(90, 30)
    $listBox1.Size = New-Object System.Drawing.Size(170, 20)
    $listBox1.TabIndex = 2

    $listBox1.EndUpdate()
    $form.Controls.Add($listBox1)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75, 80)
    $OKButton.Size = New-Object System.Drawing.Size(75, 23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(150, 80)
    $CancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $Client = $listBox1.SelectedItem
    }

    $Result = @{'Cliente' = $Client}
    return $Result
}