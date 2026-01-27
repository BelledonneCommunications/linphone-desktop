#!/bin/bash

./../chromium-depot-tools/gn gen $1 --args="extra_cflags=\"-Wno-nontrivial-memcall\""
