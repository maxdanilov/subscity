#!/bin/bash
padrino stop
padrino start -d -h 0.0.0.0 -a thin -e production
