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

# https://devguide.python.org/versions/
# https://firefox-source-docs.mozilla.org/writing-rust-code/update-policy.html#schedule
# https://releases.rs
const VPY, _ = "3.11", "../../Firefox/mach"
const VRS, _ = "1.83", "win-make.dockerfile"

if abspath(PROGRAM_FILE) == @__FILE__
	if !@try parse(Bool, ENV["JULIA_SYS_ISDOCKER"]) false
		return @warn "Not allowed."
	end
	ver = VER_INFO.v
	url = "https://github.com/Heptazhou/Snowfox/releases"
	tag = "$url/tag/v$ver"
	@info "sourceurl = " * tag
	write("sourceurl.txt", tag, "\n")
	write("version", ver, "\n")
	for f ∈ (L10N_PKG_TAR, TAR_PREFIX * ver * TAR_SUFFIX)
		for h ∈ HASH_ALGOS
			curl("$url/download/v$ver/$f.$(h)", force = true)
		end
		try
			curl("$url/download/v$ver/$f")
			hash_chk(f)
		catch
			curl("$url/download/v$ver/$f", force = true)
			hash_chk(f)
		end
	end
	let url = "https://github.com/Heptazhou/Firefox/releases"
		curl("$url/download/$VER_MAJOR/vs.tar.zst")
	end
end

