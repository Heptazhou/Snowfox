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
	dir = L10N_PKG_DIR
	tar = L10N_PKG_TAR
	@time cd(SRC) do
		sh("tar Ifc \"$TAR_ZST_18\" $tar $dir")
		for h ∈ ("sha256", "sha3-512")
			sh("$(h)sum $tar | tee $tar.$(h)")
		end
	end
	for f ∈ filter!(startswith(tar), readdir(SRC))
		@info mv(SRC / f, PKG / f, force = true)
	end
end

function clean()
	@time cd(SRC) do
		for d ∈ filter!(isdir, readdir())
			contains(d, "l10n") || continue
			@info d
			rm(d, recursive = true)
		end
	end
end

function fetch()
	@time cd(SRC) do
		curl(L10N_SRC_URL, L10N_SRC_TAR)
	end
end

function patch()
	dir = SRC / L10N_PKG_DIR
	sh("julia locale.jl $dir")
end

function unpack()
	tar = L10N_SRC_TAR
	src = L10N_SRC_DIR
	@time cd(SRC) do
		dst = L10N_PKG_DIR
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

# time julia l10n.jl fetch unpack patch build clean

