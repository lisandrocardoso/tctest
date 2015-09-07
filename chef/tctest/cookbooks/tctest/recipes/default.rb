#
# Cookbook Name:: tctest
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'apt::default'
include_recipe 'tctest::user'
include_recipe 'tctest::database'
include_recipe 'tctest::app'
