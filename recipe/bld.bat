if "%ARCH%" == "64" (
   set ARCH=x64
) else (
   set ARCH=Win32
)

if "%vc%" == "9" (
  set COMPILER=-DCMAKE_C_COMPILER=c99-to-c89-cmake-nmake-wrap.bat
)

COPY %LIBRARY_INC%\inttypes.h src\common\inttypes.h
COPY %LIBRARY_INC%\stdint.h src\common\stdint.h

:: set "CC=%BUILD_PREFIX%\Library\bin\c99-to-c89-cmake-nmake-wrap.bat"
::      --trace --debug-output

cmake -G "NMake Makefiles" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      %COMPILER% ^
      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE ^
      --debug-trycompile ^
      .

:: cmake --build . -- VERBOSE=1
nmake VERBOSE=1

if errorlevel 1 exit /b 1
exit /b 0

cd Windows

devenv /Upgrade xz_win.sln
msbuild xz_win.sln /p:Configuration="Release" /p:Platform="%ARCH%" /verbosity:normal
if errorlevel 1 exit 1

COPY Release\%ARCH%\liblzma_dll\liblzma.dll %LIBRARY_BIN%\
COPY Release\%ARCH%\liblzma_dll\liblzma.lib %LIBRARY_LIB%\
COPY Release\%ARCH%\liblzma\liblzma.lib %LIBRARY_LIB%\liblzma_static.lib

cd %SRC_DIR%

MOVE src\liblzma\api\lzma %LIBRARY_INC%\
COPY src\liblzma\api\lzma.h %LIBRARY_INC%\

DEL src\common\inttypes.h
DEL src\common\stdint.h
