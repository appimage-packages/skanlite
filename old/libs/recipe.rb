#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Copyright (C) 2016 Scarlett Clark <sgclark@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.
require 'erb'
require 'fileutils'
require 'yaml'

class Recipe
  attr_accessor :name
  attr_accessor :arch
  attr_accessor :desktop
  attr_accessor :icon
  attr_accessor :iconpath
  attr_accessor :install_path
  attr_accessor :packages
  attr_accessor :dep_path
  attr_accessor :repo
  attr_accessor :archives
  attr_accessor :md5sum
  attr_accessor :version
  attr_accessor :app_dir
  attr_accessor :configure_options

  def initialize(args = {})
    Dir.chdir('/')
    self.name = args[:name]
    self.arch = `arch`
    self.install_path = '/app/usr'
    self.app_dir = "/#{name}.AppDir"
    Dir.mkdir("#{app_dir}")
  end

  def clean_workspace(args = {})
    return if Dir['/app/'].empty?
    FileUtils.rm_rf("/app/.", secure: true)
    return if Dir['/out/'].empty?
    FileUtils.rm_rf("/out/.", secure: true)
  end

  def install_packages(args = {})
    self.packages = args[:packages].to_s.gsub(/\,|\[|\]/, '')
    # system('sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test')
    # system('sudo apt-get update')
    # system('sudo apt-get -y install  gcc-6 g++-6')
    # system('sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6')
    system('sudo apt-get update && sudo apt-get upgrade')
    system("sudo apt-get -y install git wget #{packages}")
    system('sudo apt-get -y remove cmake')
    $?.exitstatus
  end

  def get_git_version(args = {})
    Dir.chdir("/app/src/#{name}") do
      self.version = `git describe`.chomp.gsub("release-", "").gsub(/-g.*/, "")
      p "#{version}"
    end
  end

    def gather_integration(args = {})
    self.desktop = args[:desktop]
    Dir.chdir('/app') do
      system("cp ./usr/share/applications/#{desktop}.desktop .")
      if File.readlines("/app/#{desktop}.desktop").grep(/Icon/).empty?
        system("echo 'Icon=' >> /app/#{desktop}.desktop")
      end
      system("sed -i -e 's|Exec=.*|Exec=#{name}|g' #{desktop}.desktop")
      $?.exitstatus

    end
  end

  def copy_icon(args = {})
    self.icon = args[:icon]
    self.iconpath = args[:iconpath]
    Dir.chdir('/app') do
      system("cp #{iconpath}#{icon} . ")
      system("sed -i -e 's|Icon=.*|Icon=#{icon}|g' #{desktop}.desktop")
      $?.exitstatus
    end
  end

  def run_integration()
      system('git clone "https://github.com/probonopd/AppImageKit"')
      Dir.chdir("/AppImageKit") do
        system('cp --force /in/functions/AppRun AppImageAssistant.AppDir/AppRun')
        system('./build.sh')
      end
      system('cp /AppImageKit/out/AppRun* /app/AppRun')
      system('cp /AppImageKit/out/AppImageAssistant* /app/AppImageAssistant')
      system('chmod +x AppRun' )
      Dir.chdir('/app') do
        system("/bin/bash -xe /in/functions/desktop_integration.sh  #{name}")
      end
      $?.exitstatus
  end

  def copy_dependencies(args = {})
    Dir.chdir("/app") do
      system("cp -rfv * #{app_dir}")
    end
    Dir.chdir("#{app_dir}") do
      self.dep_path = args[:dep_path]
      dep_path.each do |dep|
        system("cp --parents -rfv #{dep} .")
      end
    end
    $?.exitstatus
  end

  def copy_libs(args = {})
    Dir.chdir("#{app_dir}") do
      system("/bin/bash -xe /in/functions/copy_libs.sh")
      $?.exitstatus
    end
  end

    def move_lib(args = {})
      Dir.chdir("#{app_dir}") do
        system("/bin/bash -xe /in/functions/move_libs.sh")
        $?.exitstatus
      end
    end

  def delete_blacklisted(args = {})
    Dir.chdir("#{app_dir}") do
      system("/bin/bash -xe /in/functions/delete_blacklisted.sh")
      $?.exitstatus
    end
  end

  def generate_appimage(args = {})
    Dir.chdir("/") do
      File.write('/in/Recipe', render)
      system("/bin/bash -xe /in/Recipe")
    end
    $?.exitstatus
  end

  def render
    ERB.new(File.read('/in/libs/Recipe.erb')).result(binding)
  end
end
