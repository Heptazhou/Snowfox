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

const CFG = "https://codeberg.org/librewolf/settings.git"
const CLN = "https://gitlab.com/librewolf-community/browser/source.git"

function build()
	@info "Building . . ."
	cd((@__DIR__)) do
		cd(SRC)
		mf = s"Makefile"
		pf = s"https://archive.mozilla.org/pub/firefox"
		sf = s"source/firefox-$(version).source.tar.xz"
		v1, v2, v3 = VER |> v_read
		v1 = replace(v1, r"\.0$" => "") # Firefox version
		if VER |> string |> contains(r"\+b\d+")
			@warn "The build target is beta version." VER
			write(mf, replace(mf |> readstr,
				"$pf/releases/\$(version)/$sf",
				"$pf/releases/$v1" * "b$v3/$sf", "p"))
		end
		if VER |> string |> contains(r"\+rc\d")
			@warn "The build target is a RC version." VER
			write(mf, replace(mf |> readstr,
				"$pf/releases/\$(version)/$sf",
				"$pf/candidates/$v1-candidates/build$v3/$sf", "p"))
		end
		if VER |> string |> contains(r"\d+\.0")
			local v0 = ("\$(version)")
			write(mf, replace(mf |> readstr,
				"$v0/source/" => "$v1/source/",
				"firefox-$v0" => "firefox-$v1"))
		end
		Sys.iswindows() && (@warn "Not allowed."; return)
		f = ["../", ""] .* "firefox-$v1.source.tar.xz"
		f .|> isfile == [1, 0] && cp(f...)
		f[1] = "../$PKG" * "firefox-$v1.source.tar.xz"
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
		@exec [GIT, "clone", "--depth=1", CLN, SRC, "-b", "126.0.1-1"]
		@exec [GIT, "clone", "--depth=1", CFG, SRC * "submodules/" * "settings"]
		@exec [JLC..., "move.jl", SRC, "1"]
		@exec [JLC..., "remote.jl"]
		cd(SRC)
		v1, v2, v3 = VER |> v_read
		open("version", "r") do io
			v0 = readline(io) |> VersionNumber |> string
			v0 ≡ v1 ? @info(v1) : @warn("Version not matched.", v0, v1)
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

