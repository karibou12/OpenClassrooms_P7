<#

Auteur Guillaume Desessard
Date: 22-05-2022
Version: 1.0
Description: Script interactif permettant de lister les groupes auxquels appatient un utilisateur

#>


#affiche les membres du domaine pour faciliter l'utilisation du script
Get-ADUser -filter * | Select-Object SamAccountName | Out-host 

Write-Host "entrer le nom d'un utilisateur"
$selectedUser = Read-Host

Try{
#si l'utilisateur existe on écrit dans la console le(s) groupe(s) auquel(s) appartient l'utilisateur
Get-ADPrincipalGroupMembership -Identity $selectedUser
Write-Host "$selectedUser appartient au groupe(s) précédent" 

#créer un fichier avec le nom de l'utilisateur est le place sur le bureau
Get-ADPrincipalGroupMembership -Identity $selectedUser | Out-File c:\Users\Administrator.SRVADPAR01\Desktop\$selectedUser.txt
Write-Host "le fichier suivant à été généré: .\Desktop\$selectedUser.txt"
}

catch{
#si l'utilisateur n'existe pas écrit la phrase dans la console
Write-Host "$selectedUser n'appartient a aucun groupe(s)" 
Get-ADPrincipalGroupMembership -Identity $selectedUser | Out-File c:\Users\Administrator.SRVADPAR01\Desktop\$selectedUser.txt
}

