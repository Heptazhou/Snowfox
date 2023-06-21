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

const sh(c::String) = run(`sh -c $c`) # include not allowed here

const fs = filter!(isfile, filter!(endswith(".zip"), readdir()))

const as = "-m0=lzma -md3840m -mfb273 -mmt2 -ms -mx9 -stl"

isempty(ARGS) || for fn in map(f -> splitext(f)[1], fs)
	sh.(["7z x     $fn.zip snowfox"])
	sh.(["7z a $as $fn.7z  snowfox"])
	sh.(["rm   -fr $fn.zip snowfox"])
end

