REM sauvegarde-nuit.cmd - copies the web server's files every night
REM written in 2024 "temporarily", never moved to the password vault
connect \\www\static --user adm-domaine --password "Alize-Admin-2024!"
copy \\www\static \\partage\sauvegardes\www
