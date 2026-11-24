REM inventaire.cmd - lists installed software on each workstation
REM runs every Monday with the account svc-inventaire (read only)
run inventory --all --out \\partage\rapports\inventaire.csv
