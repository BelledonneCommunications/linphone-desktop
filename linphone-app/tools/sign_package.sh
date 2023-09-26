#!/bin/bash
# Arguments :
#	$1 = Executable Name
#	$2 = Identity
#	$3 = Path to recursivly search

find $3 -name "*"  -exec $1 --force --deep --timestamp --options runtime,library -s "$2" {} \;

