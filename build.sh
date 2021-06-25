# sync

ROM_MANIFEST=https://github.com/NusantaraProject-ROM/android_manifest
BRANCH=11
LOCAL_MANIFEST=https://github.com/Fraschze97/local_manifest.git
MANIFEST_BRANCH=nusantara11

mkdir -p /tmp/rom
cd /tmp/rom

repo init -q --no-repo-verify --depth=1 "$ROM_MANIFEST" -b "$BRANCH" -g default,-device,-mips,-darwin,-notdefault

git clone "$LOCAL_MANIFEST" --depth 1 -b "$MANIFEST_BRANCH" .repo/local_manifests

repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 30 || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Patches

cd frameworks/opt/net/ims
curl -LO https://github.com/PixelExperience/frameworks_opt_net_ims/commit/661ae9749b5ea7959aa913f2264dc5e170c63a0a.patch
patch -p1 < *.patch
cd ../../../..

# build
cd /tmp/rom

. build/envsetup.sh
lunch nad_RMX1941-userdebug

export SKIP_API_CHECKS=true
export SKIP_ABI_CHECKS=true
export _JAVA_OPTIONS=-Xmx16g

export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1

ccache -M 20G
ccache -o compression=true
ccache -z


# metalava
make_metalava(){
        make init
        make sepolicy
}

make_metalava

mka nad 
sleep 90m
kill %1 || echo "Build already failed or completed"
ccache -s

# upload

#up(){
#	curl --upload-file $1 https://transfer.sh/$(basename $1); echo
	# 14 days, 10 GB limit
#}


up(){
        mkdir -p ~/.config/rclone
        echo "$rclone_config" > ~/.config/rclone/rclone.conf
	time rclone copy $1 aosp:ccache/ccache-ci -P # apon is my rclone config name, 
}

up /tmp/rom/out/target/product/RMX1941/*UNOFFICIAL*.zip || echo "Only ccache generated or build failed lol"

ccache -s
