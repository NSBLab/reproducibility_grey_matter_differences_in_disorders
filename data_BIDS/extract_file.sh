#!/bin/env bash

filename=$1
while read SUBJECTID; do
	unzip /home/trangc/kg98/trangc/MultiSites/BD_Modulation_Ventrolateral_Prefrontal/image03/${SUBJECTID}/anat.zip
done < $filename
