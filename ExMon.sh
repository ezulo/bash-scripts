#!/bin/bash
EXTERNAL_OUTPUT=HDMI2
INTERNAL_INPUT=eDP1

xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto
