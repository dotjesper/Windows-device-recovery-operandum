@echo off

:: ------------------------------------------------------------------------------------
::  FactoryReset_AfterImageApply.cmd
:: ------------------------------------------------------------------------------------
::  Created: 11-05-2016 10:24 GMT+1 by @dotJesper
::  Edited:  11-04-2017 15:29 GMT+1 by @dotJesper
:: ------------------------------------------------------------------------------------
::  Revision 1.0: First edition
::  Revision 1.1: Minor changes
::  Revision 1.2: Changed %LogFile% from %TargetOS%\Panther\*.log
::                to %TargetOSDrive%\Recovery\OEM\LOGS\*.log
::  Revision 1.3: File Cleanup section added
:: ------------------------------------------------------------------------------------
::  Comments: None
::
:: ------------------------------------------------------------------------------------

:: Define %ScriptFolder% (This later becomes C:\Recovery\OEM\)
   SET ScriptFolder=%~dp0

:: Define %TargetOS% as the Windows folder (This later becomes C:\Windows)
   FOR /F "tokens=1,2,3 delims= " %%A IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RecoveryEnvironment" /v TargetOS') DO SET TargetOS=%%C

:: Define %TargetOSDrive% as the Windows partition (This later becomes C:)
   FOR /F "tokens=1 delims=\" %%A IN ('ECHO %TargetOS%') DO SET TargetOSDrive=%%A

:: Set log file
   SET LogFile="%TargetOSDrive%\Recovery\OEM\LOGS\%~n0.log"
   IF EXIST "%LogFile%" (del "%LogFile%" /q /f)

   ECHO    %LogFile%
   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Date: %DATE% >> %LogFile%
   ECHO    Time: %TIME% >> %LogFile%
   ECHO    ScriptFolder: %ScriptFolder% >> %LogFile%
   ECHO    TargetOS: %TargetOS% >> %LogFile%
   ECHO    TargetOSDrive: %TargetOSDrive% >> %LogFile%
   ECHO    Script name: %~n0 >> %LogFile%
   ECHO    Param: %1 >> %LogFile%
   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Computer name: %COMPUTERNAME% >> %LogFile%
   ECHO    User name: %USERNAME% >> %LogFile%
   ECHO    User Profile: %USERPROFILE% >> %LogFile%

:: Add back Windows settings, Start Menu Layout and OOBE.xml customizations
   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Copying Unattend.xml >> %LogFile%

   IF EXIST "%ScriptFolder%Unattend.xml" (
        COPY "%ScriptFolder%Unattend.xml" "%TargetOS%\Panther\Unattend.xml" /y >> %LogFile%
    ) ELSE (
        ECHO    %ScriptFolder%Unattend.xml not found >> %LogFile%
    )

   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Copying LayoutModifications.xml >> %LogFile%

   IF EXIST "%ScriptFolder%LayoutModification.xml" (
        COPY "%ScriptFolder%LayoutModification.xml" "%TargetOSDrive%\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" /y >> %LogFile%
    ) ELSE (
        ECHO    %ScriptFolder%LayoutModification.xml not found >> %LogFile%
    )

   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Copying OOBE.xml files >> %LogFile%

   robocopy.exe "%ScriptFolder%OOBE" "%TargetOS%\System32\oobe\info\default" *.* /s /Log+:%LogFile%

   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Copying PPKG files >> %LogFile%

   robocopy.exe "%ScriptFolder%PPKG" "%TargetOS%\Provisioning\Packages" *.* /Log+:%LogFile%

   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Servicing Windows (Managing Features) >> %LogFile%

   dism.exe /Image:%TargetOSDrive% /Disable-Feature /FeatureName:SMB1Protocol /NoRestart /LogLevel:2 >> %LogFile%
   dism.exe /Image:%TargetOSDrive% /Enable-Feature /FeatureName:Microsoft-Hyper-V-All /NoRestart /LogLevel:2 >> %LogFile%

   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Cleaning up files and folders >> %LogFile%

   IF EXIST "%TargetOSDrive%\Recovery" (
        ATTRIB +S +H "%TargetOSDrive%\Recovery" >> %LogFile%
    ) ELSE (
        ECHO    %TargetOSDrive%\Recovery not found >> %LogFile%
    )

   IF EXIST "%TargetOSDrive%\Intel" (
        ATTRIB +H "%TargetOSDrive%\Intel" >> %LogFile%
    ) ELSE (
        ECHO    %S%TargetOSDrive%\Intel not found >> %LogFile%
    )

:: EOF
   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Script ended %DATE% %TIME% >> %LOGFILE%

   EXIT /B 0
