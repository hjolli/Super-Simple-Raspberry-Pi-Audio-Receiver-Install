#!/bin/bash
SNAP="SNAP"
while [ $SNAP != "s" ] && [ $SNAP != "c" ] && [ $SNAP != "b" ];
do
    read -p "Install this as a SnapCast Server(s), Client(c), and Both (b): (s/c/b)" SNAP
done
if [ $SUDO_USER ]; then user=$SUDO_USER ; else user=`whoami`; fi
#--------------------------------------------------------------------
function tst {
    echo "===> Executing: $*"
    if ! $*; then
        echo "Exiting script due to error from: $*"
        exit 1
    fi
}
#--------------------------------------------------------------------
PWD=`pwd`
SNAP_DIR=$PWD/snapcast
tst git clone https://github.com/badaix/snapcast.git
tst cd $SNAP_DIR/externals
tst git submodule update --init --recursive
tst sudo apt-get install build-essential -y
tst sudo apt-get install libasound2-dev libvorbisidec-dev libvorbis-dev libflac-dev alsa-utils libavahi-client-dev avahi-daemon -y
tst cd $SNAP_DIR
tst make


if [ $SNAP = "s" ]
then
    tst sudo make installserver
    echo "load-module module-pipe-sink file=/tmp/snapfifo sink_name=Snapcast" | sudo tee -a /etc/pulse/system.pa
    echo "set-default-sink Snapcast" | sudo tee -a /etc/pulse/system.pa
elif [ $SNAP = "c" ]
then
    tst sudo make installclient
    echo "sudo snapclient" | sudo tee -a ~/.profile
    # Add set-default-sink-input here
elif [ $SNAP = "b" ]
then
    tst sudo make installserver
    tst sudo make installclient
    echo "load-module module-pipe-sink file=/tmp/snapfifo sink_name=Snapcast" | sudo tee -a /etc/pulse/system.pa
    echo "set-default-sink Snapcast" | sudo tee -a /etc/pulse/system.pa
    echo "sudo snapclient" | sudo tee -a ~/.profile
fi
if [ $SNAP != "n" ]
then
    sudo sed -i "s///  name = \"/path/to/pipe\"; // there is no default pipe name for the output/  name = \"/tmp/snapfifo\"; // there is no default pipe name for the output/" /etc/shairport-sync.conf
fi

echo "Snapcast Install Has Finished"




