#!/bin/sh

args=$*
ruby -e "require './test_start_point_checker.rb'" -- ${args}