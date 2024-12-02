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

const CLN = "https://github.com/Heptazhou/Snowfox.git"
const REL = "https://github.com/Heptazhou/Snowfox/releases/download"

# https://firefox-source-docs.mozilla.org/writing-rust-code/update-policy.html#schedule
# https://releases.rs
const VRS, _ = "1.81", "win-make.dockerfile"

cd(@__DIR__) do
	if !@try parse(Bool, ENV["JULIA_SYS_ISDOCKER"]) false
		@warn "Not allowed."
		return
	end
	write("version", VER_INFO.v, "\n")
	for f ∈ [
		L10N_PKG_TAR
		TAR_PREFIX * VER_INFO.v * TAR_SUFFIX
	]' .* [".sha256", ".sha3-512", ""]
		curl("$REL/v$(VER_INFO.v)/$f")
	end
end

