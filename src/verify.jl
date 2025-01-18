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

if abspath(PROGRAM_FILE) == @__FILE__
	for x ∈ strip_list_msc
		x ∈ strip_list_ubo && @warn x
		x ∈ strip_list_xpt && @warn x
	end
	@info "Done."
end

