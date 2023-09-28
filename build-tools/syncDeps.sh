
# Checkouts submodules to the versions that are pushed to remote.

if [ -e "build-tools/public/DepTools.sh" ]; then
    source build-tools/public/DepTools.sh
    SyncModules
else
    git submodule update --recursive --init
fi
