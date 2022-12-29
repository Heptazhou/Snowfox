# Copyright (C) 2022-2023 Heptazhou <zhou@0h7z.com>
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
# julia = "≥ 1.6"

include("base_func.jl")
include("const.jl")

const SUBMODULES = something(tryparse.(Bool, [ARGS; "0"])...)

const DIR = !isdir(SRC) ? "$(@__DIR__)/" : "$(@__DIR__)/$SRC"

try
	cd((DIR) * "linux/") do
		dir = something(filter!(x -> isdir(x) && startswith(x, "snowfox"), readdir())...)
		dir *= "/browser/branding/aurora"
		rm("$DIR" * "linux/assets/librewolf.ico", force = true)
		cp("$dir/firefox.ico", "assets/firefox.ico", force = true, follow_symlinks = true)
		cp("$dir/wizWatermark.bmp", "assets/banner.bmp", force = true, follow_symlinks = true)
		@info replace(pwd(), "\\" => "/")
	end
catch
	cd(mktempdir()) do
		@info replace(pwd(), "\\" => "/")
		dir = "browser/branding/aurora"
		url = "https://hg.mozilla.org/mozilla-central/archive/tip.zip/$dir/"
		curl("-LO", "-J", url)
		zip = something(filter!(x -> isfile(x) && startswith(x, "mozilla-central"), readdir())...)
		zip7("x", zip), rm(zip)
		dir = splitext(zip)[1] * "/$dir"
		rm("$DIR" * "linux/assets/librewolf.ico", force = true)
		cp("$dir/firefox.ico", DIR * "linux/assets/firefox.ico", force = true, follow_symlinks = true)
		cp("$dir/wizWatermark.bmp", DIR * "linux/assets/banner.bmp", force = true, follow_symlinks = true)
	end
end

filter!(!=("/"), ARGS)
if isempty(ARGS)
	(dir, arg) = @__DIR__, pwd()
	(move)(startswith(arg, dir) ? arg : dir)
else
	(dir, arg) = @__DIR__, abspath.(ARGS[1])
	isdir(arg) || throw(SystemError(arg, 2))
	(move)(startswith(arg, dir) ? arg : dir)
end

