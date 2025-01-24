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

if abspath(PROGRAM_FILE) == @__FILE__
	cmd = "git diff --patch-with-stat --minimal"
	ver = "v$(VER.major)"
	cd("../../Firefox")
	let distance = readstr(`git rev-list --count $ver..HEAD`)
		@assert 10 < parse(Int, distance) < 100
	end
	sh("$cmd $ver~0 HEAD~5 > $ver.patch")
	sh("$cmd HEAD~5 HEAD~4 > font.patch")
	sh("$cmd HEAD~4 HEAD~3 > crlf.patch")
	sh("$cmd HEAD~1 HEAD~0 > typo.patch")
	for f ∈ readdir()
		g = stdpath(@__DIR__, f)
		endswith(f, ".patch") && @info basename(mv(f, g, force = true))
	end
end

