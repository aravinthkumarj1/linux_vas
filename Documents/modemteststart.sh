#!/bin/sh

echo 9 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio9/direction
echo 1 > /sys/class/gpio/gpio9/value

echo -e "Ready for test.\n"
