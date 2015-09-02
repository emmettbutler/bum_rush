#!/bin/bash

amxmlc src/bootycall.as -o bootycall.swf -verbose-stacktraces=true -debug=true && adl bootycallmain.xml
