<#

Auteur Guillaume Desessard
Date: 22-05-2022
Version: 1.0
Description: Script permettant de créer des utilisateurs avec un dossier partagé à son nom, à l'aide d'un ficher CSV

#>


#variable correspondant au fichier csv ainsi que son traitement
$CSVFile = "C:\Users\Administrator.SRVADPAR01\Desktop\P7_utilisateursAD.csv"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8

#variable pour le nom de domaine
$domaine = "DC=axeplane,DC=loc"
$server = "SRVADPAR01.axeplane.loc"

#boucle sur le fichier CSV pour créer les utilisateurs

Foreach($Utilisateur in $CSVData){
    $UtilisateurPrenom = $Utilisateur.prenom
    $UtilisateurNom = $Utilisateur.nom
    $UtilisateurLogin = $Utilisateur.login
    $UtilisateurEmail = $Utilisateur.mail
    $UtilisateurMotDePasse = "goLesbleus,"
    $utilisateurFonction = $Utilisateur.fonction
    $utilisateurService = $Utilisateur.service
    $nomGroupe = "Grp_" + $utilisateurService.ToLower()
   

  try{
        #création de l'utilisateur
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

        
        #Ajoute l'utilisateur dans son groupe de service
        Add-ADGroupMember -Identity $nomGroupe -Members $UtilisateurLogin
        
        Write-Host -ForegroundColor Green "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"

    }

    catch{
        Write-Host -ForegroundColor Red $UtilisateurLogin 
        $Error[0].Exception.Message
   }


    #Creation du dossier partagé de l'utilisateur
    try{
            
        #Creation du nom du partage
        $dirshare = "$UtilisateurNom $UtilisateurPrenom"
        $shareName = "$UtilisateurLogin$"
           
        #creation du dossier        
        New-Item -Path "E:\Partage personnels\$dirshare" -ItemType Directory -ErrorAction Stop
        Write-Host -ForegroundColor Green "Création du dossier : E:\Partage personnels\$dirshare"
      
        #definition des droits d'acces        
        New-SmbShare -Name $shareName -Path "E:\Partage personnels\$dirshare" -FullAccess "Administrators"
        Add-NTFSAccess -Path "E:\Partage personnels\$dirshare" -Account "$UtilisateurLogin@axeplane.loc" -AccessRights Full
        Grant-SmbShareAccess -Name $shareName  -AccountName "$UtilisateurLogin@axeplane.loc" -AccessRight Full -Force
    }

    catch{
        $_.Exception.Message
        Write-Host ""
    }

}




#CSV
<#
    prenom;nom;service;fonction;login;mail
    Alain;Marnet;Direction;Directeur général;a.marnet;a.marnet@axeplane.loc
    Annabeth;Viale;Direction;Directrice adjointe;a.viale;a.viale@axeplane.loc
    Thierry;Faure;Direction;Secrétaire de direction;t.faure;t.faure@axeplane.loc
    Donna;Rossi;RH;Directrice des Ressources Humaines;d.rossi;d.rossi@axeplane.loc
    Elsa;Pasteur;RH;Assistante RH;e.pasteur;e.pasteur@axeplane.loc
    Juan;Alvarez;RH;Assistant RH;j.alvarez;j.alvarez@axeplane.loc
    Jack;Wilson;Finance;Responsable service Finance;j.wilson;j.wilson@axeplane.loc
    Chloé;Lemoine;Finance;Gestionnaire finances comptabilité;c.lemoine;c.lemoine@axeplane.loc
    Vick;Van Mertens;Finance;Assistante comptable;v.vanmertens;v.vanmertens@axeplane.loc
    Guy;Mirabeau;Commercial;Responsable service Commercial;g.mirabeau;g.mirabeau@axeplane.loc
    Alisha;Kumari;Commercial;Commerciale;a.kumari;a.kumari@axeplane.loc
    Josefina;Alvarez;Commercial;Commerciale;jo.alvarez;jo.alvarez@axeplane.loc
    Halan;Bakri;Commercial;Commercial;h.bakri;h.bakri@axeplane.loc
    Moussa;Dayma;Logistique;Responsable service Logistique;m.dayma;m.dayma@axeplane.loc
    Myriam;Saltiel;Logistique;Opératrice logistique;m.saltiel;m.saltiel@axeplane.loc
    Albert;De Koch;Logistique;Opérateur logistique;a.dekoch;a.dekoch@axeplane.loc
    Maddy;Zhang;Marketing;Responsable service Marketing;m.zhang;m.zhang@axeplane.loc
    Christopher;Schmidt;Marketing;Assistant marketing;c.schmidt;c.schmidt@axeplane.loc
    Sarah;Ezzat;Stagiaire;Stagiaire service marketing;s.ezzat;s.ezzat@axeplane.loc
    Anthony;Pacaut;Informatique;Responsable service Informatique;a.pacaut;a.pacaut@axeplane.loc
    Aaron;Scott;Informatique;Administrateur Systèmes et Réseaux;a.scott;a.scott@axeplane.loc
    Guillaume;Desessard;Informatique;Technicien Supérieur Systèmes et Réseaux;g.desessard;g.desessard@axeplane.loc
#>
