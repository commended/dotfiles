#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher"
theme='style2'

rofi \
  -show drun \
  -theme ${dir}/${theme}.rasi
