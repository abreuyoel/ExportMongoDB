@echo off
setlocal enabledelayedexpansion

:: Nombres de las bases de datos MongoDB que deseas exportar (separados por espacios)
set "MONGODB_DATABASES=WorkflowEngine CaptureWorkflow GlobalForms PortalSecurity ServiceEngine admin local"

:: Ruta base donde se almacenarán los archivos de exportación
set "BASE_EXPORT_PATH=Z:\Backup_BD_MGPRD"

:: Obtén la fecha y hora actual en un formato compatible con archivos de lote de Windows
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DATETIME=%%I"
set "FECHA_ACTUAL=!DATETIME:~0,4!-!DATETIME:~4,2!-!DATETIME:~6,2!-!DATETIME:~8,6!"

:: Crea una carpeta con la fecha actual dentro de la ruta base
set "EXPORT_PATH=%BASE_EXPORT_PATH%\%FECHA_ACTUAL%"
mkdir "!EXPORT_PATH!"

:: Comando para exportar las bases de datos MongoDB
for %%D in (%MONGODB_DATABASES%) do (
  mongodump --db "%%D" --out "!EXPORT_PATH!"
)

:: Verifica si la exportación fue exitosa
if %errorlevel% equ 0 (
  set "ASUNTO=Éxito: Exportación de MongoDB completada"
  set "MENSAJE=La exportación de las bases de datos MongoDB se ha completado con éxito. Puedes encontrar los archivos exportados en %EXPORT_PATH%."
) else (
  set "ASUNTO=Error: Exportación de MongoDB fallida"
  set "MENSAJE=La exportación de las bases de datos MongoDB ha fallado. Por favor, revise los registros para obtener más detalles."
)

:: Envía el correo electrónico utilizando Blat
echo %MENSAJE% | blat - -subject "%ASUNTO%" -to %CORREO_DESTINO%

:: Limpia los archivos de exportación antiguos (opcional)
:: Encuentra y elimina carpetas de exportación más antiguas que X días
set "DIAS_RETENER=7"
forfiles /P "%BASE_EXPORT_PATH%" /D -%DIAS_RETENER% /C "cmd /c if @isdir==TRUE rmdir /s /q @path"

endlocal
