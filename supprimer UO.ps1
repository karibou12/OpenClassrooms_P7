$CSVFile = "C:\Users\Administrator\Desktop\P7_utilisateursAD.csv"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8


Foreach($Utilisateur in $CSVData){
       $utilisateurService = $Utilisateur.service
       $UtilisateurPrenom = $Utilisateur.prenom
       $UtilisateurNom = $Utilisateur.nom
       
        
        #Vérifier la présence de l'unité d'organisation dans l'AD
if (Get-ADOrganizationalUnit -filter  'name -like $utilisateurService'){
     
    (Get-ADOrganizationalUnit -filter 'name -like $utilisateurService' -SearchScope OneLevel)`
     | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru `
     | Remove-ADOrganizationalUnit -recursive -Confirm:$false
    
        
    
     Write-Warning "L'UO $utilisateurService à été supprimée de l'AD"
}



  #remove d'un dossier partages par Groupe
    if ((Test-Path -Path "E:\Partage communs\")) {
       #Remove-Item "E:\Partage communs\"
       Remove-Item "E:\Partage communs\" -Recurse -Force -Confirm:$false
       Remove-SmbShare -Name "E:\Partage communs\$utilisateurService" -Force -Confirm:$false
       #Revoke-SmbShareAccess -Name $utilisateurService -Force -Confirm:$false
    } 
    else
     {
                 "le dossier n'exist pas"
             
        }

        $dirshare = "$UtilisateurNom $UtilisateurPrenom$"
       Remove-SmbShare -Name $dirshare -Force -Confirm:$false
       #Revoke-SmbShareAccess -Name $dirshare -Force -Confirm:$false




#remove d'un dossier partages personnel
    if ((Test-Path -Path "E:\Partage personnels\")) {
       #Remove-Item "E:\Partage communs\"
       Remove-Item "E:\Partage personnels\" -Recurse -Force -Confirm:$false
       Remove-SmbShare -Name "E:\Partage personnels\$utilisateurService" -Force -Confirm:$false
       #Revoke-SmbShareAccess -Name $utilisateurService -Force -Confirm:$false
    } 
    else
     {
                 "le dossier n'exist pas"
             
        }

        $dirshare = "$UtilisateurNom $UtilisateurPrenom$"
       Remove-SmbShare -Name $dirshare -Force -Confirm:$false
       #Revoke-SmbShareAccess -Name $dirshare -Force -Confirm:$false


}
