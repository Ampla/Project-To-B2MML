rem @echo off
set project=AmplaProject.xml

set nxslt=.\lib\nxslt\nxslt.exe

if EXIST Output goto Output_exists
mkdir Output
:Output_exists

@echo === Equipment Model ===
%nxslt% %project% Ampla_to_Equipment_B2MML.xslt -o Output\Equipment.B2MML.xml
