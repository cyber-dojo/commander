#!/bin/sh

ruby -e "%w( test_start_point_checker.rb ).map{ |file| './'+file }.each { |file| require file }"