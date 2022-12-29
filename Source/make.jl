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
# julia = "≥ 1.5"

include("base_func.jl")
include("const.jl")

const CLN = "https://gitlab.com/librewolf-community/browser/source.git"

function build()
	@info "Building . . ."
	cd((@__DIR__)) do
		cd(SRC)
		Sys.iswindows() && (@warn "Not allowed."; return)
		@run [GMK, "all"]
		dir = mkpath("../$PKG")
		for f in filter!(isfile, readdir())
			f |> startswith("firefox-") && cp(f, "$dir/$f", force = true)
			f |> startswith("snowfox-") && cp(f, "$dir/$f", force = true)
		end
	end
end

function check()
	@info "Checking . . ."
	cd((@__DIR__)) do
		if !isdir(SRC)
			throw(SystemError(SRC, 20)) # ENOTDIR 20 Not a directory
		else
			cd(SRC)
			@run [GMK, "check"]
		end
	end
end

function clean()
	@info "Cleaning . . ."
	cd((@__DIR__)) do
		rm(SRC, force = true, recursive = true)
	end
end

function fetch()
	@info "Fetching . . ."
	cd((@__DIR__)) do
		if ispath(SRC)
			throw(SystemError(SRC, 17)) # EEXIST 17 File exists
		else
			@run [GIT, "clone", "--depth=1", ["--recurse" "--shallow" "--remote"] .* "-submodules"..., CLN, SRC]
			@run [JLC..., "move.jl", SRC, "1"]
			@run [JLC..., "remote.jl"]
		end
	end
end

function patch()
	@info "Patching . . ."
	cd((@__DIR__)) do
		if !isdir(SRC)
			throw(SystemError(SRC, 20)) # ENOTDIR 20 Not a directory
		else
			@run [JLC..., "move.jl", SRC, "1"]
			@run [JLC..., "update.jl", SRC, "1"]
		end
	end
end

isempty(ARGS) && @info "Nothing to do."
while !isempty(ARGS)
	op = popfirst!(ARGS)
	if false
	elseif op ≡ "all"
		clean()
		fetch()
		patch()
		build()
	elseif op ≡ "build"
		build()
	elseif op ≡ "check"
		check()
	elseif op ≡ "clean"
		clean()
	elseif op ≡ "fetch"
		fetch()
	elseif op ≡ "patch"
		patch()
	else
		@warn "Invalid target: " * op
	end
end

