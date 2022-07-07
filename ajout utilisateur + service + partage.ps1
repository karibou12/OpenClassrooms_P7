$CSVFile = "C:\Users\Administrator\Desktop\P7_utilisateursAD.csv"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8
$domaine = "DC=axeplane,DC=loc"
$server = "SRVADPAR01.axeplane.loc"

Foreach($Utilisateur in $CSVData){
    $UtilisateurPrenom = $Utilisateur.prenom
    $UtilisateurNom = $Utilisateur.nom
    $UtilisateurLogin = $Utilisateur.login
    $UtilisateurEmail = $Utilisateur.mail
    $UtilisateurMotDePasse = "goLesbleus,"
    $utilisateurFonction = $Utilisateur.fonction
    $utilisateurService = $Utilisateur.service
    $nomGroupe = "Grp_" + $utilisateurService.ToLower()

    
    #Vérifier la présence de l'unité d'organisation dans l'AD
    if (Get-ADOrganizationalUnit -filter  'name -like $utilisateurService'){
         Write-Warning "L'UO $utilisateurService existe déjà dans l'AD"
    }
    else
    {
        New-ADOrganizationalUnit -Name "$utilisateurService" `
                                 -Path $domaine
        Write-Output "Création de groupe : $utilisateurService)"
    }

    
    #Vérifier la présence du group dans l'AD
    if (Get-ADGroup -filter  'name -like $nomGroupe'){
         Write-Warning "L'UO $utilisateurService existe déjà dans l'AD"
    }
    else
    {
        New-ADGroup -Name $nomGroupe `
                    -GroupCategory Security `
                    -GroupScope Global `
                    -Path "OU=$utilisateurService,$domaine" `

        Write-Output "Création de groupe : $utilisateurService)"
    }

    
    #Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {samAccountName -eq $UtilisateurLogin}){
        Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
    }
    else
    {
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                   -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                   -GivenName $UtilisateurPrenom `
                   -Surname $UtilisateurNom `
                   -SamAccountName $UtilisateurLogin `
                   -UserPrincipalName "$UtilisateurLogin@axeplane.loc" `
                   -EmailAddress $UtilisateurEmail `
                   -Title $UtilisateurFonction `
                   -Department $utilisateurService `
                   -Path "OU=$utilisateurService,$domaine" `
                   -AccountPassword(ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                   -ChangePasswordAtLogon $false `
                   -Enabled $true `
                   -server $server

           Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }


    #Ajoute l'utilisateur dans son groupe de service
    Add-ADGroupMember -Identity $nomGroupe -Members $UtilisateurLogin

    


    


    #Creation d'un dossier partages par Groupe
    if (Test-Path -Path "E:\Partage communs\$utilisateurService") {
        "le dossier exist"
    } 
    else
     {
                New-Item -Name $utilisateurService -ItemType Directory -Path "E:\Partage communs"
                                  
                  
                #Creation du partages du service
               
                New-SmbShare -Name $utilisateurService -Path "E:\Partage communs\$utilisateurService" -FullAccess ("administrator", $nomGroupe)

                #Get-SmbShareAccess -Name $nomGroupe

                Add-NTFSAccess -Path "E:\Partage communs\$utilisateurService" -Account "$nomGroupe" -AccessRights Full

                Grant-SmbShareAccess -Name $nomGroupe  -AccountName "$nomGroupe" -AccessRight Full -Force


        }
        

                #Creation du partages de l'utilisateur
                $dirshare = "$UtilisateurNom $UtilisateurPrenom$"
                
                New-Item -Path "E:\Partage personnels\$dirshare" -ItemType Directory
                
                New-SmbShare -Name $dirshare -Path "E:\Partage personnels\$dirshare" -FullAccess "Administrators"
                #Get-SmbShareAccess -Name $dirshare
                Add-NTFSAccess -Path "E:\Partage personnels\$dirshare" -Account "$UtilisateurLogin@axeplane.loc" -AccessRights Full
                Grant-SmbShareAccess -Name $dirshare  -AccountName "$UtilisateurLogin@axeplane.loc" -AccessRight Full -Force
                                              

}


    #Creation d'un dossier partages par Groupe lecture seule
            
    Add-NTFSAccess -Path "E:\Partage communs\Marketing" -Account "Grp_commercial" -AccessRights Read
    Add-NTFSAccess -Path "E:\Partage communs\Commercial" -Account "Grp_marketing" -AccessRights Read

                                              


