#!/usr/bin/make -f
# -*- makefile -*-
# Sample debian/rules that uses debhelper.
# This file was originally written by Joey Hess and Craig Small.
# As a special exception, when this file is copied by dh-make into a
# dh-make output file, you may use that output file without restriction.
# This special exception was added by Craig Small in version 0.37 of dh-make.

# Uncomment this to turn on verbose mode.
export DH_VERBOSE=1
# TODO: remove the LDFLAGS override.  It's here to avoid esoteric problems
# of this sort:
#  https://code.ros.org/trac/ros/ticket/2977
#  https://code.ros.org/trac/ros/ticket/3842
export LDFLAGS=
export PKG_CONFIG_PATH=@(InstallationPrefix)/lib/pkgconfig
# Explicitly enable -DNDEBUG, see:
# 	https://github.com/ros-infrastructure/bloom/issues/327
export DEB_CXXFLAGS_MAINT_APPEND=-DNDEBUG
ifneq ($(filter nocheck,$(DEB_BUILD_OPTIONS)),)
	BUILD_TESTING_ARG=-DBUILD_TESTING=OFF
endif

# Solve shlibdeps errors in REP136 packages that use GNUInstallDirs:
export DEB_HOST_MULTIARCH := $(shell dpkg-architecture -qDEB_HOST_MULTIARCH)

DEB_HOST_GNU_TYPE ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)

@{
dh_arguments = ''
if SourceDirectory:
    dh_arguments += f" -D{SourceDirectory}"
}@
%:
	dh $@@ -v --buildsystem=cmake --builddirectory=.obj-$(DEB_HOST_GNU_TYPE)@(dh_arguments)

override_dh_auto_configure:
	# In case we're installing to a non-standard location, look for a setup.sh
	# in the install tree and source it.  It will set things like
	# CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
	if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi && \
	dh_auto_configure -- \
		-DCMAKE_INSTALL_PREFIX="@(InstallationPrefix)" \
		-DCMAKE_PREFIX_PATH="@(InstallationPrefix)" \
@[if no_tests]@
		-DBUILD_TESTING=OFF \
@[end if]@
		$(BUILD_TESTING_ARG)

override_dh_auto_build:
	# In case we're installing to a non-standard location, look for a setup.sh
	# in the install tree and source it.  It will set things like
	# CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
	if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi && \
	dh_auto_build

override_dh_auto_test:
@[if not no_tests]@
	# In case we're installing to a non-standard location, look for a setup.sh
	# in the install tree and source it.  It will set things like
	# CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
	echo -- Running tests. Even if one of them fails the build is not canceled.
	if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi && \
	dh_auto_test || true
@[end if]@

override_dh_shlibdeps:
	# In case we're installing to a non-standard location, look for a setup.sh
	# in the install tree and source it.  It will set things like
	# CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
	if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi && \
	dh_shlibdeps -l$(CURDIR)/debian/@(Package)/@(InstallationPrefix)/lib/:$(CURDIR)/debian/@(Package)/@(InstallationPrefix)/lib/${DEB_HOST_MULTIARCH} @[if ShlibsIgnoreMissingInfo]-- --ignore-missing-info@[end if]

override_dh_auto_install:
	# In case we're installing to a non-standard location, look for a setup.sh
	# in the install tree and source it.  It will set things like
	# CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
	if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi && \
	dh_auto_install
