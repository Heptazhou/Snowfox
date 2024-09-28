# Copyright (C) 2021-2024 Heptazhou <zhou@0h7z.com>
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

const fs = [
	"../Snowfox/src/base_func.jl"
	"../Snowfox/src/const.jl"
	#
]

try
	basename(@__DIR__) ≠ "src" || error("Not allowed.")
	@isdefined(pause) || include(fs[1])
	cd(@__DIR__) do
		for f in fs
			cp(f, f |> basename, force = true)
		end
	end
catch e
	@info e
end
isempty(ARGS) || exit()
pause(up = 1)

