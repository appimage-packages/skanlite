export PATH=/app/usr/bin:$PATH
export LD_LIBRARY_PATH=/app/usr/lib:/app/usr/lib/x86_64-linux-gnu:/usr/lib64:/usr/lib:/app/usr/lib/Qt-5.7.0:$LD_LIBRARY_PATH
export XDG_CONFIG_DIRS=/app/etc/xdg:/etc/xdg/xdg-plasma:/etc/xdg:/usr/share/:/root/.qttest/config
export XDG_DATA_DIRS=/app/usr:/app/usr/share:/usr:/usr/share:/root/.local/share
export XDG_DATA_HOME=$XDG_DATA_HOME:/root/.qttest/share:/root/.local/share
export XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
export XDG_CACHE_HOME=/root/.qttest/cache
export CMAKE_VERSION=3.6.20160925-g02277
which cmake
cmake --version
echo $CMAKE_VERSION
