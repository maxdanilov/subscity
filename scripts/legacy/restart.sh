#!/bin/bash
MODE=${1:-production}    
if [[ $MODE =~ ^d ]]; then
   MODE="development"
else
   MODE="production"
fi

padrino stop
padrino start -d -h 0.0.0.0 -a thin -e $MODE
