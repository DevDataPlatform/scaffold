#!/bin/sh

TARGET_DIR=/home/ddp/DDP_Backend/

git clone https://github.com/DevDataPlatform/DDP_Backend.git $TARGET_DIR

python3 -m venv $TARGET_DIR/venv

# VIRTUAL_ENV="$TARGET_DIR/venv"
# export VIRTUAL_ENV
# PATH="$VIRTUAL_ENV/bin:$PATH"
# export PATH

$TARGET_DIR/venv/bin/pip install --upgrade pip
$TARGET_DIR/venv/bin/pip install -r $TARGET_DIR/requirements.txt

mkdir $TARGET_DIR/ddpui/logs
