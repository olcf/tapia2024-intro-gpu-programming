#!/bin/bash

module load craype-accel-amd-gfx90a
module load rocm

echo "Currently loaded modules:"
echo "-------------------------"
module -t list
