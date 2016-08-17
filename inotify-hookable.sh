#!/bin/bash

inotify-hookable \
    --watch-directories /home/jillian/Dropbox/projects/perl/HPC-Runner-Command/lib/  \
    --watch-directories /home/jillian/Dropbox/projects/perl/HPC-Runner-Command/t/lib/TestsFor/  \
    --watch-directories lib \
    --watch-directories t/lib/TestsFor/ \
    --on-modify-command "prove -v t/test_class_tests.t"
