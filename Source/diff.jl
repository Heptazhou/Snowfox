# Copyright (C) 2021-2024 Heptazhou <zhou@0h7z.com>
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

include("base_func.jl")

try
	cd(@__DIR__) do
		diff = "git diff --patch-with-stat --minimal"
		v = "v$(VER.major)"
		cd("../../Firefox")
		sh("$diff $(v)   HEAD~4 > $(v).patch")
		sh("$diff HEAD~4 HEAD~3 > font.patch")
		sh("$diff HEAD~3 HEAD~2 > crlf.patch")
		sh("$diff HEAD~1 HEAD~0 > typo.patch")
		for f ∈ readdir()
			g = "$(@__DIR__)/" * f
			endswith(f, ".patch") && @info basename(mv(f, g, force = true))
		end
	end
catch e
	@info e
end
isempty(ARGS) || exit()
pause(up = 1)

