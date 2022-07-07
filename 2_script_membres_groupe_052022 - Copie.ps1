<#

Auteur Guillaume Desessard
Date: 22-05-2022
Version: 1.0
Description: Script interactif permettant de lister les membres d'un groupe de sécurité sélectionné

#>


#Ajoute les composants permettant la création de forme graphique
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Création de la fenetre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Lister les membres d'un groupe"
$form.Size = New-Object System.Drawing.Size(400,400)
$form.StartPosition = 'CenterScreen'

#Création du bouton OK
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,220)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

#création du bouton cancel
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,220)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

#création d'un label de texte
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(75,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Selectionner un Groupe'
$form.Controls.Add($label)

#création d'un listbox des groupes de l'AD contenant le texte Grp
$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(75,40)
$listBox.Size = New-Object System.Drawing.Size(250,20)

$allGrp = Get-ADGroup -Filter 'name -like "Grp*"'
foreach ($grp in $allGrp){
 $listBox.Items.Add($grp.Name)

}
$listBox.Height = 150
$form.Controls.Add($listBox)


#Création d'un label avec le chemin et le nom du fichier exporté
$file = New-Object System.Windows.Forms.Label
$file.Location = New-Object System.Drawing.Point(75,250)
$file.Size = New-Object System.Drawing.Size(280,40)
$file.Text = "Emplacement du fichier: \Desktop\ "
$form.Controls.Add($file)

#variable pemettant de stocker l'état d'un click sur le button ok
$result = $form.ShowDialog()

function listeMembre{
    Get-Date 
    Get-ADGroupMember -Identity $listBox.SelectedItem
  
}



#quand on appuie sur le bouton ok, on affiche dans la console  les membres du  groupe selectionné
#la fonction listMembre est exécutée et on créé un fichier d'export
if ($result -eq [System.Windows.Forms.DialogResult]::OK)

{
    $groupSelected = $listBox.SelectedItem
    Write-Output $groupSelected | Get-ADGroupMember 
    listeMembre  | Out-File "C:\Users\Administrator.SRVADPAR01\Desktop\export Membre du $($groupSelected).txt"     
    
}

