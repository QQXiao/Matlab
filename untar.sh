#!/bin/bash
DATAROOT=/seastor/helenhelen/TV_2013/raw
cd $DATAROOT
for i in *.gz
do
          tar xf $i
done
