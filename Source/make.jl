# Copyright (C) 2022-2025 Heptazhou <zhou@0h7z.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

include("base_func.jl")

function build()
	dir = TAR_PREFIX * VER_INFO.v
	tar = TAR_PREFIX * VER_INFO.v * TAR_SUFFIX
	@time cd(SRC) do
		sh("tar Ifc \"$TAR_ZST_18\" $tar $dir")
		hash_gen(tar)
	end
	for f ∈ filter!(startswith(tar), readdir(SRC))
		@info mv(SRC / f, PKG / f, force = true)
	end
end

function clean()
	@time cd(SRC) do
		for d ∈ filter!(isdir, readdir())
			contains(d, "l10n") && continue
			@info d
			rm(d, recursive = true)
		end
	end
end

function fetch()
	tar = VER_INFO.moz_tar
	url = VER_INFO.moz_url
	@time cd(SRC) do
		curl(url, tar)
		let url = replace(url, "/source/$tar" => "/SHA256SUMS")
			sha = curl(url, "$tar.sha256", force = true)
			str = only(filter!(endswith("source/$tar"), readlines(sha)))
			write(sha, str[1:64], " *", tar, "\n") # 256 / log2(16)
		end
		txt = "$tar.txt"
		if isfile(txt)
			hash_chk(tar)
		else
			hash_chk(tar, "sha256")
			hash_gen(tar)
			write(txt, url, "\n")
		end
	end
	tar *= '.'
	for f ∈ filter!(startswith(tar), readdir(SRC))
		@info cp(SRC / f, PKG / f, force = true)
	end
end

function patch()
	dir = SRC / TAR_PREFIX * VER_INFO.v
	sh("julia patch.jl $dir")
end

function unpack()
	tar = VER_INFO.moz_tar
	src = VER_INFO.moz_src
	@time cd(SRC) do
		dst = TAR_PREFIX * VER_INFO.v
		isdir(dst) && return dst
		isdir(src) || sh("tar fx $tar")
		mv(src, dst, force = true)
	end
end

if abspath(PROGRAM_FILE) == @__FILE__
	mkpath(PKG)
	mkpath(SRC)
	args = Symbol.(ARGS)
	@assert all(∈([
			:build
			:clean
			:fetch
			:patch
			:unpack
		]), args)
	for f ∈ args
		@info f
		@eval $f()
	end
end

# time julia make.jl fetch unpack patch build clean

