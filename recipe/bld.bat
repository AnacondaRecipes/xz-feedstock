setlocal

:: Create and enter the build directory
md build && cd build

:: Common CMake arguments
set CMAKE_COMMON_ARGS=-GNinja ^
                      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
                      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=FALSE ^
                      -DCMAKE_BUILD_TYPE=Release

:: Build shared library
cmake %CMAKE_COMMON_ARGS% -DBUILD_SHARED_LIBS=ON ..
if errorlevel 1 exit /b 1

ninja && ninja install
if errorlevel 1 exit /b 1

:: Clean build directory for static library build
rm -rf ./*

:: Build static library
cmake %CMAKE_COMMON_ARGS% -DBUILD_SHARED_LIBS=OFF ..
if errorlevel 1 exit /b 1

ninja
if errorlevel 1 exit /b 1

:: Copy static library to the correct location
cp lzma.lib "%LIBRARY_LIB%/lzma_static.lib"
if errorlevel 1 exit /b 1

endlocal