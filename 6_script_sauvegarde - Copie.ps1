<#

Auteur Guillaume Desessard
Date: 22-05-2022
Version: 1.0
Description: Script permettant la sauvergarde du répertoire User du client en utilisant la command Xcopy
/e:	Copie tous les sous-répertoires, même s’ils sont vides
/i: Affiche la liste des fichiers à copier
/c: Ignore les erreurs
/z: Copie sur un réseau en mode redémarrable
/y: Supprime l’invite pour confirmer que vous souhaitez remplacer un fichier de destination existant

#>


#créer un tableau de tous les PC du domaine, enlever le serveur de la liste
[System.Collections.ArrayList]$computersList = (Get-ADComputer -Filter *).Name
$computersList.Remove('SRVADPAR01')

#créer un fichier de "log"
$sauv >> "c:\Users\Administrator.SRVADPAR01\Desktop\sauvergardes.txt"
$date = Get-Date -Format "dd/MM/yy H:mm"

#test si les Pc du domaine sont joignable et effectue la copie s'il l'est
ForEach($computer in $computersList){

    if (Test-Connection -ComputerName $computer -Count 1 -Quiet){
        xcopy \\$computer\c$\Users\* E:\Sauvergardes /E /I /C /Z /Y
        ADD-Content  -Path "c:\Users\Administrator.SRVADPAR01\Desktop\sauvergardes.txt" -Value "$date : Pc $computer sauvegardé"
    }
    else{
        ADD-Content  -Path "c:\Users\Administrator.SRVADPAR01\Desktop\sauvergardes.txt" -Value "$date : Pc $computer n'est pas connecté, sauvergarde non effectuée"
    }
}

#saut de ligne
ADD-Content  -Path "c:\Users\Administrator.SRVADPAR01\Desktop\sauvergardes.txt" -Value " "