REM 이 파일을 실행하기 전에 make_archived_source.bat 를 실행하여 
REM dist 디렉토리에 WPXML2TTXML.rb 파일이 생성된 상태에서 진행하시기 바랍니다.

@echo off
cd dist
del WPXML2TTXML.exe
rubyscript2exe WPXML2TTXML.rb WPXML2TTXML.exe