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

#
# % docker build -t snowfox:win-make -< win-make.dockerfile
# % docker images
#
# % docker container prune -f
# % docker system prune [-af]
#

FROM snowfox:win-base

ENV CARGO_BUILD_JOBS=2 \
	CARGO_INCREMENTAL=0

RUN rustup default 1.73 && \
	rustup target add x86_64-pc-windows-msvc

RUN cd /src && mach configure

RUN cd /src && mach build

RUN cd /src && mach buildsymbols

RUN cd /src && mach package-multi-locale \
	--locales `cat browser/locales/shipped-locales` > /dev/null

RUN cd /src/obj-x86_64-pc-mingw32/dist && cp -pvt /pkg \
	install/sea/* snowfox-* && rm /pkg/*.xpt_artifacts.* || true

RUN cd /pkg && jl 7z.jl / && rm 7z.jl

#
# % id=$(docker create snowfox:win-make) && docker cp $id:pkg . -q && docker rm $id && julia move.jl /
#

