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

const CLN = "https://gitlab.com/librewolf-community/browser/source.git"
const REL = "https://github.com/Heptazhou/Snowfox/releases/download"
const VER = v"115.0.1-1"

function build()
	@info "Building . . ."
	cd((@__DIR__)) do
		cd(SRC)
		("$VER" |> contains(r"rc\d")) && let f = "Makefile"
			@warn "The build target is a RC version." (VER)
			pf = s"https://archive.mozilla.org/pub/firefox"
			sf = s"source/firefox-$(version).source.tar.xz"
			v1, v2, v3 = VER |> v_read
			write(f, replace(f |> readstr,
				"$pf/releases/\$(version)/$sf",
				"$pf/candidates/$v1-candidates/build$v3/$sf", "p"))
		end
		Sys.iswindows() && (@warn "Not allowed."; return)
		v = v_read(VER)[begin]
		f = ["../", ""] .* "firefox-$v.source.tar.xz"
		f .|> isfile == [1, 0] && cp(f...)
		f[1] = "../$PKG" * "firefox-$v.source.tar.xz"
		f .|> isfile == [1, 0] && cp(f...)
		@exec [GMK, "all"]
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
		Sys.iswindows() && (@warn "Not allowed."; return)
		if !isdir(SRC)
			@warn SRC * ": Not a directory"
			clean()
			fetch()
			patch()
			check()
		else
			cd(SRC)
			@exec [GMK, "check"]
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
		ispath(SRC) && throw(SystemError(SRC, 17)) # EEXIST 17 File exists
		@exec [GIT, "clone", "--depth=1", ["--recurse" "--shallow" "--remote"] .* "-submodules"..., CLN, SRC]
		@exec [JLC..., "move.jl", SRC, "1"]
		@exec [JLC..., "remote.jl"]
		cd(SRC)
		v1, v2, v3 = VER |> v_read
		open("version", "r") do io
			readline(io) |> v0 -> v0 ≡ v1 ? @info(v0) : @warn("Version not matched.", v0, v1)
		end
		open("version", "w") do io
			println(io, v1)
		end
		open("release", "w") do io
			println(io, v2)
		end
	end
end

function patch()
	@info "Patching . . ."
	cd((@__DIR__)) do
		!isdir(SRC) && throw(SystemError(SRC, 20)) # ENOTDIR 20 Not a directory
		@exec [JLC..., "move.jl", SRC, "1"]
		@exec [JLC..., "update.jl", SRC, "1"]
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

