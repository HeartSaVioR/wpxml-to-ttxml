REM �� ������ �����ϱ� ���� make_archived_source.bat �� �����Ͽ� 
REM dist ���丮�� WPXML2TTXML.rb ������ ������ ���¿��� �����Ͻñ� �ٶ��ϴ�.

@echo off
cd dist
del WPXML2TTXML.exe
rubyscript2exe WPXML2TTXML.rb WPXML2TTXML.exe