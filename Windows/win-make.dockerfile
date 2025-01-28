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

#
# % docker build -t snowfox:win-make -< win-make.dockerfile
# % docker images
#
# % docker container prune -f
# % docker system prune [-af]
#

FROM snowfox:win-base

ARG ARCH=x86-64

ENV CARGO_BUILD_JOBS=1 \
	MOZCONFIG=$ARCH.mozconfig

RUN rustup default 1.83 && \
	rustup target add {i686,x86_64}-pc-windows-msvc && \
	systemd-machine-id-setup

RUN cd /src && python3.11 mach configure
RUN cd /src && python3.11 mach build
RUN cd /src && python3.11 mach package-multi-locale > /dev/null

RUN cd /src/obj-*-w64-mingw32/dist/ && \
	cp -pvt /pkg install/sea/* snowfox-* && \
	rm /pkg/*.xpt_artifacts.* || true
RUN cd /pkg && julia 7z.jl && rm 7z.jl

FROM scratch
COPY --from=0 /pkg /pkg

#
# % id=`docker create snowfox:win-make -q` && docker cp $id:pkg . -q && docker rm $id && julia move.jl
#

