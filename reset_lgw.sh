#!/bin/sh

# This script is intended to be used on SX1301/8 CoreCell platform, it performs
# the following actions:
#       - export/unpexort GPIO120 and GPIO129 used to reset the SX1301/8 chip and to enable the LDOs
#
# Usage examples:
#       ./reset_lgw.sh stop
#       ./reset_lgw.sh start

# GPIO mapping has to be adapted with HW
#

SX1301_RESET_PIN=120     # SX1301 reset
SX1301_POWER_EN_PIN=129  # SX1301 power enable

WAIT_GPIO() {
    sleep 0.1
}

init() {
    # setup GPIOs
    echo "$SX1301_RESET_PIN" > /sys/class/gpio/export; WAIT_GPIO
    echo "$SX1301_POWER_EN_PIN" > /sys/class/gpio/export; WAIT_GPIO

    # set GPIOs as output
    echo "out" > /sys/class/gpio/gpio$SX1301_RESET_PIN/direction; WAIT_GPIO
    echo "out" > /sys/class/gpio/gpio$SX1301_POWER_EN_PIN/direction; WAIT_GPIO
}

reset() {
    echo "CoreCell reset through GPIO$SX1301_RESET_PIN..."
    echo "CoreCell power enable through GPIO$SX1301_POWER_EN_PIN..."

    # write output for SX1301 CoreCell power_enable and reset
    echo "0" > /sys/class/gpio/gpio$SX1301_POWER_EN_PIN/value; WAIT_GPIO
    echo "1" > /sys/class/gpio/gpio$SX1301_POWER_EN_PIN/value; WAIT_GPIO

    echo "1" > /sys/class/gpio/gpio$SX1301_RESET_PIN/value; WAIT_GPIO
    echo "0" > /sys/class/gpio/gpio$SX1301_RESET_PIN/value; WAIT_GPIO
}

term() {
    # cleanup all GPIOs
    if [ -d /sys/class/gpio/gpio$SX1301_RESET_PIN ]
    then
        echo "$SX1301_RESET_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
    if [ -d /sys/class/gpio/gpio$SX1301_POWER_EN_PIN ]
    then
        echo "$SX1301_POWER_EN_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
}

case "$1" in
    start)
    term # just in case
    init
    reset
    ;;
    stop)
    reset
    term
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
