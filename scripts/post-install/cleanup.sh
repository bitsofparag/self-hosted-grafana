#!/bin/bash

echo ">>>>> Clean up apt..."
apt-get clean

rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*

echo ">>>>> Clean up python bytecode..."
find / -mount -name *.pyc -delete
find / -mount -name *__pycache__* -delete

echo ">>>>> Clean up shell history..."
history -c

sync
