@echo on

:: Build Static library (.lib)
cmake -GNinja ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      %COMPILER% ^
      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DCMAKE_BUILD_TYPE=Release ^
      --debug-trycompile ^
      .
ninja
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1

:: Rename Static library from liblzma.lib to liblzma_static.lib
:: The next step will build the DLL, which creates an import library
:: that would share the same name.
move %LIBRARY_LIB%\liblzma.lib %LIBRARY_LIB%\liblzma_static.lib

:: Build Shared library (.dll)
cmake -GNinja ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      %COMPILER% ^
      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      --debug-trycompile ^
      .
ninja
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1

DEL src\common\inttypes.h
DEL src\common\stdint.h
goto common_exit

:vc14_build
cd Windows\vs2017
devenv /Upgrade xz_win.sln
msbuild xz_win.sln /p:Configuration="Release" /p:Platform="%ARCH%" /verbosity:normal
if errorlevel 1 exit /b 1
COPY Release\%ARCH%\liblzma_dll\liblzma.dll %LIBRARY_BIN%\
COPY Release\%ARCH%\liblzma_dll\liblzma.lib %LIBRARY_LIB%\
goto common_exit

:common_exit
cd %SRC_DIR%
MOVE src\liblzma\api\lzma %LIBRARY_INC%\
COPY src\liblzma\api\lzma.h %LIBRARY_INC%\
exit /b 0
