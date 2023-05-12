#
# Cookbook Name:: fb_syslog
# Recipe:: packages
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
return if node.macos?

package 'rsyslog' do
  # TODO(T152951763): Pin rsyslog to 8.2102.0.105.el9 in Antlir builds
  # See D45729033 for the Antlir counterpart
  if node.centos9? && node.antlir_build?
    version '8.2102.0-105.el9'
    action :install
  else
    action :upgrade
  end
end

# TODO(davide125): Document this
if node.systemd?
  fb_systemd_override 'override' do
    only_if { node['fb_syslog']['_enable_syslog_socket_override'] }
    unit_name 'rsyslog.service'
    content({
              'Unit' => { 'Requires' => 'syslog.socket' },
              'Install' => { 'Alias' => 'syslog.service' },
            })
  end
end

include_recipe 'fb_syslog::enable'
