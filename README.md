# par3D

First Commit
socat -d -d PTY,link=/tmp/ttyV0,raw,echo=0 PTY,link=/tmp/ttyV1,raw,echo=0
echo -ne '\x0A\x00\x14\x00\x1E\x00\x28\x00\x32\x00' > /tmp/ttyV0

