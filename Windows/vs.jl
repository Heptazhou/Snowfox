# Copyright (C) 2023 Heptazhou <zhou@0h7z.com>
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

const py = "taskcluster/scripts/misc/get_vs.py"

const vs = "build/vs/vs2019.yaml"

isempty(ARGS) || cd("/src") do
	dd = get(ENV, "MOZBUILD_STATE_PATH", "/moz") * "/vs"
	sh("mach python --virtualenv=build $py $vs $dd")
	sh("mach clobber")
end

