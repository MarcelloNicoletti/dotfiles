#!/usr/bin/env bash

# Powerline font glyphs
# This file contains the actual powerline symbols
# You'll need a powerline font to see them properly
POWERLINE_ENABLE=true
export PL_RIGHT_BLACK=$'\ue0b0'
export PL_RIGHT=$'\ue0b1'
export PL_LEFT_BLACK=$'\ue0b2'
export PL_LEFT=$'\ue0b3'

if [[ $POWERLINE_ENABLE = false ]]; then
    export PL_RIGHT_BLACK=$'\u2551'
    export PL_RIGHT=$'\u2502'
    export PL_LEFT_BLACK=$'\u2551'
    export PL_LEFT=$'\u2502'
fi
