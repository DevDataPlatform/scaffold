#!/bin/sh

VIRTUAL_ENV="/home/ddp/venv"
export VIRTUAL_ENV
PATH="$VIRTUAL_ENV/bin:$PATH"
export PATH
prefect server start &
