# Copyright (C) 2021-2025 Heptazhou <zhou@0h7z.com>
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

cd(@__DIR__) do
	diff = "git diff --patch-with-stat --minimal"
	ver = "v$(VER.major)"
	cd("../../Firefox")
	sh("$diff $ver~0 HEAD~5 > $ver.patch")
	sh("$diff HEAD~5 HEAD~4 > font.patch")
	sh("$diff HEAD~4 HEAD~3 > crlf.patch")
	sh("$diff HEAD~1 HEAD~0 > typo.patch")
	for f ∈ readdir()
		g = stdpath(@__DIR__, f)
		endswith(f, ".patch") && @info basename(mv(f, g, force = true))
	end
end

