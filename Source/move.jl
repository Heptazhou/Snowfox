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
# julia = "≥ 1.6"

include("base_func.jl")

const SUBMODULES = something(tryparse.(Bool, [ARGS; "0"])...)

filter!(!=("/"), ARGS)
if isempty(ARGS)
	(dir, arg) = @__DIR__, pwd()
	move((startswith(arg, dir)) ? arg : dir)
else
	(dir, arg) = @__DIR__, abspath.(ARGS[1])
	isdir(arg) || throw(SystemError(arg, 2))
	move((startswith(arg, dir)) ? arg : dir)
end

