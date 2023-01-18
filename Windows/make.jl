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

const CLN = "https://gitlab.com/librewolf-community/browser/windows.git"
const REL = "https://github.com/Heptazhou/Snowfox/releases/download"
const VER = v"109.0-2"

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
			@run [GIT, "clone", "--depth=1", CLN, SRC]
			@run [JLC..., "move.jl", SRC, "1"]
			#
			cd(SRC * "linux/")
			v1, v2, v3 = v_read(VER)
			open("version", "w") do io
				println(io, v1)
			end
			open("source_release", "w") do io
				println(io, v2)
			end
			open("release", "w") do io
				println(io, v3)
			end
			something(tryparse(Bool, get(ENV, "JULIA_SYS_ISDOCKER", "0")), false) || return
			curl("-LO", "$REL/v$VER/snowfox-v$v1-$v2.source.tar.zst.sha256")
			curl("-LO", "$REL/v$VER/snowfox-v$v1-$v2.source.tar.zst")
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

