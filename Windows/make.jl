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

# https://devguide.python.org/versions/
# https://firefox-source-docs.mozilla.org/writing-rust-code/update-policy.html#schedule
# https://github.com/Heptazhou/Firefox/blob/master/build/rust/windows/Cargo.toml
# https://releases.rs
const VPY, _ = "3.11", "../../Firefox/mach"
const VRS, _ = "1.84", "win-make.dockerfile"
const WRS, _ = "0.58", "win-base.dockerfile"

