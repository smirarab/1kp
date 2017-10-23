#!/bin/bash

for x in `ls genes`
do 
cat newdata/2R/$x/$x.input.FAA newdata/NHCM/$x/$x.input.FAA >> genes/$x/$x.input.FAA
cat newdata/2R/$x/$x.input.FNA newdata/NHCM/$x/$x.input.FNA >> genes/$x/$x.input.FNA
done
