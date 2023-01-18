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

include("const.jl")

function pause(Msg = missing; up::Int = 0, down::Int = 0)
	isinteractive() && return
	print('\n'^up)
	pause(stdin, stdout, Msg)
	print('\n'^down)
end
function pause(In::IO, Out::IO, Msg = missing)
	print(Out, Msg isa String ? Msg : "Press any key to continue . . . ")
	ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid}, Int32), In.handle, 1)
	read(In, Char)
	ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid}, Int32), In.handle, 0)
	println(Out)
end

for i in strip_list
	i in strip_list_ubo && @warn i
end
@info "Done."

isempty(ARGS) || exit()
pause(up = 1)

