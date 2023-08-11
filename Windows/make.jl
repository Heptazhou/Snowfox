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

const CLN = "https://github.com/Heptazhou/Snowfox.git"
const REL = "https://github.com/Heptazhou/Snowfox/releases/download"
const VER = v"116.0.3-1"

# https://firefox-source-docs.mozilla.org/writing-rust-code/update-policy.html#schedule
# https://releases.rs
const VRS, _ = "1.71", "win-make.dockerfile"

try
	cd(@__DIR__)
	v1, v2, v3 = VER |> v_read
	v_rel = split("v$VER", "+")[1]
	write("version", "$v1-$v2")
	something(tryparse(Bool, get(ENV, "JULIA_SYS_ISDOCKER", "")), false) ?
	for f in "$REL/$v_rel/snowfox-v$v1-$v2.source.tar.zst" .* [".sha256", ""]
		f |> basename |> ispath || curl("-LO", f)
	end :
	@warn "Not allowed."
catch e
	@info e
end
isempty(ARGS) || exit()
pause(up = 1)

