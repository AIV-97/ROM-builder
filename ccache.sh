# download

df -h
free -h
nproc
cat /etc/os*
env

url=https://rapid-thunder-eae6.carn4ge.workers.dev/0:/ccache/nezuko/ccache.tar.gz

cd /tmp
time aria2c $url -x16 -s50
time tar xf ccache.tar.gz
rm -rf ccache.tar.gz

# upload

cd /tmp

com ()
{
    tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
}

time com ccache 1

mkdir -p ~/.config/rclone
echo "$rclone_config" > ~/.config/rclone/rclone.conf
time rclone copy ccache.tar.gz aosp:ccache/nezuko -P
