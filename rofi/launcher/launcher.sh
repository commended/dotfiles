#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher"
theme='style'

rofi \
  -show drun \
  -theme ${dir}/${theme}.rasi
