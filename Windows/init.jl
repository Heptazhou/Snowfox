# Copyright (C) 2023 Heptazhou <zhou@0h7z.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# [compat]
# julia = "≥ 1.5"

include("base_func.jl")

const ps =
	[
		"*.gradle"
		"build/build-clang/*.json"
		"build/build-clang/*.py"
		"build/clang-plugin/*.inc"
		"build/clang-plugin/*.py"
		"build/clang-plugin/*.txt"
		"build/clang-plugin/**/*.cpp"
		"build/clang-plugin/**/*.h"
		"build/clang-plugin/Makefile.in"
		"build/clang-plugin/moz.build"
		"build/moz.configure"
		"build/unix/build-*/build-*.sh"
		"build/vs/vs*.yaml"
		"config/external/zlib"
		"gfx/wr/Cargo.lock"
		"gfx/wr/ci-scripts/install-meson.sh"
		"mobile/android/**/*.gradle"
		"mobile/android/config/mozconfigs/android-arm-gradle-dependencies"
		"mobile/android/config/mozconfigs/common*"
		"mobile/android/gradle.configure"
		"modules/libmar"
		"moz.configure"
		"other-licenses/bsdiff"
		"other-licenses/nsis/Contrib/CityHash/cityhash"
		"python/mozboot/**/*android*"
		"python/mozbuild/mozpack/macpkg.py"
		"taskcluster/scripts/misc/*.patch"
		"taskcluster/scripts/misc/*.py"
		"taskcluster/scripts/misc/*.sh"
		"taskcluster/scripts/misc/android-gradle-dependencies"
		"testing/geckodriver"
		"testing/mozbase/rust"
		"testing/webdriver"
		"toolkit/crashreporter"
		"toolkit/crashreporter/google-breakpad/src/processor"
		"toolkit/mozapps/update/updater/bspatch"
		"tools/browsertime/mach_commands.py"
		"tools/browsertime/package*.json"
		"tools/crashreporter"
		"tools/update-packaging"
	]

isempty(ARGS) || cd("/src") do
	sh.(["git init"])
	sh.(["git add $p" for p in ps])
	sh.(["git commit --allow-empty-message -m ''"])
end

