# sync

ROM_MANIFEST=git://github.com/LineageOS/android.git
BRANCH=lineage-18.1
LOCAL_MANIFEST=https://github.com/cArN4gEisDeD/local_manifest
MANIFEST_BRANCH=lineage

mkdir -p /tmp/rom
cd /tmp/rom

repo init -q --no-repo-verify --depth=1 "$ROM_MANIFEST" -b "$BRANCH" -g default,-device,-mips,-darwin,-notdefault

git clone "$LOCAL_MANIFEST" --depth 1 -b "$MANIFEST_BRANCH" .repo/local_manifests

repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 30 || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Patches

cd external/selinux
curl -LO https://github.com/PixelExperience/external_selinux/commit/9d6ebe89430ffe0aeeb156f572b2a810f9dc98cc.patch
patch -p1 < *.patch
cd ../..

#cd frameworks/base
#curl -LO https://github.com/PixelExperience/frameworks_base/commit/37f5a323245b0fd6269752742a2eb7aa3cae24a7.patch
#patch -p1 < *.patch
#cd ../..

#cd frameworks/opt/net/wifi
#curl -LO https://github.com/PixelExperience/frameworks_opt_net_wifi/commit/3bd2c14fbda9c079a4dc39ff4601ba54da589609.patch
#patch -p1 < *.patch
#cd ../../../..

cd frameworks/opt/net/ims
curl -LO https://github.com/PixelExperience/frameworks_opt_net_ims/commit/661ae9749b5ea7959aa913f2264dc5e170c63a0a.patch
patch -p1 < *.patch
cd ../../../..

# build

cd /tmp/rom

. build/envsetup.sh
lunch lineage_RMX1941-userdebug

export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1

ccache -M 20G
ccache -o compression=true
ccache -z

# use first three lines one time while generating ccache and 2nd time at time of final build
#make api-stubs-docs
#make system-api-stubs-docs
#make test-api-stubs-docs
make bacon -j$(nproc --all) &
sleep 90m
kill %1 || echo "Build already failed or completed"
ccache -s

# upload

#up(){
#	curl --upload-file $1 https://transfer.sh/$(basename $1); echo
	# 14 days, 10 GB limit
#}


up(){
	time rclone copy $1 aosp:ccache/ccache-ci -P # apon is my rclone config name, 
}

up out/target/product/RMX1941/*UNOFFICIAL*.zip || echo "Only ccache generated or build failed lol"

ccache -s
