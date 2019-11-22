@ECHO OFF
SETLOCAL enableextensions
TITLE Local Build Enumeration Tool
:: This script attempt to retrieve some useful information from the system and domain
ECHO =================================================
ECHO         Local Build Enumeration Script
ECHO =================================================
ECHO.
echo Starting enumeration for:
hostname
ECHO.
MKDIR BuildInfo
ECHO [+] Created folder "BuildInfo"
CD BuildInfo
ECHO [+] Started [ %date% - %time% ]
ECHO.
ECHO Running Local Checks..
:: Local Checks
systeminfo >> SystemInfo.txt
wmic qfe list >> Windows-Patches.txt
net share >> Shares.txt
net localgroup >> Local-Groups.txt
net users >> Local-Users.txt
net accounts >> Local-PW-Policies.txt
GPResult /R >> GP-Result.txt
ECHO.
ECHO Checking for insecure services..
ECHO [!] Please save the results manually
:: Insecure services / unquoted paths
wmic service get name,displayname,pathname,startmode |findstr /i "auto" |findstr /i /v "c:\windows\\" |findstr /i /v """
ECHO.
ECHO Checking Registry Entries..
:: Registry entries with "reg"
ECHO.
ECHO Checking Installed Software..
:: Installed programs
wmic /output:"Software.txt" product get Name, Version, Vendor
ECHO.
ECHO Checking Network Settings..
:: Network Checks
ipconfig /all >> IPConfig.txt
PING www.google.com >> InternetAccess.txt
route PRINT >> Route.txt
netstat -a >> Netstat.txt
tracert google.com >> Traceroute.txt
ECHO.
ECHO Getting Domain Information..
:: Domain Checks
net accounts /domain >> Domain-PW-Policy.txt
net users /domain >> Domain-Users.txt
net groups /domain >> Domain-Groups.txt
ECHO.
ECHO [+] Finished! [ %date% - %time% ]
ECHO.
ECHO View results in: %cd%
PAUSE
