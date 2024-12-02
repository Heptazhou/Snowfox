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

cd(PKG) do
	for f in readdir()
		f |> contains(r"\.xpt_artifacts\b"i) && (rm(f); continue)
		g = replace(f, r"\.en-US\b"i => "")
		g = replace(g, r"\.installer\.exe\b"i => ".exe")
		g = replace(g, r"^snowfox-\K(\d+\.)"i => s"v\1")
		g ≠ f && mv(f, g, force = true)
	end
end

