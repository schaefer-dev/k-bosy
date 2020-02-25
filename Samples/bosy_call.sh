#!/bin/sh

#  bosy_call.sh
#  knowledge-bosy
#
#  Created by Daniel Schäfer on 25.02.20.
#  Copyright © 2020 Daniel Schäfer. All rights reserved.

cd /Users/daniel/dev/master/bosy;

echo "test"

swift run -c release BoSy --synthesize /Users/daniel/dev/master/bosy/Specs/kbosy_outputs/$1
