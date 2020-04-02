#!/bin/bash
0="ALERTE CTA"
message=`cat alert.txt | cut -d : -f 4`
echo MESSAGE : $message