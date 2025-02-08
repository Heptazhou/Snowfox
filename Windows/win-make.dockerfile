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
# % docker system prune [-af]
#

FROM snowfox:win-base

RUN cd /src && \
	rustup default 1.84 && \
	ln -sf {x86-64.,}mozconfig && \
	rustup target add x86_64-pc-windows-msvc && \
	# ln -sf {x86-32.,}mozconfig && \
	# rustup target add i686-pc-windows-msvc && \
	cat mozconfig

RUN cd /src && mach configure
RUN cd /src && mach compare-locales -q browser/locales/l10n.toml /moz/l10n zh-CN | \
	rg --passthrough "missing"; (($?))

RUN cd /src && mach build
RUN cd /src && mach package-multi-locale > /dev/null

RUN cd /src && cp -pt /pkg -v obj-*/dist/snowfox-*
RUN cd /pkg && julia 7z.jl && rm 7z.jl

FROM scratch
COPY --from=0 /pkg /pkg

#
# % id=`docker create snowfox:win-make -q` && docker cp $id:pkg . -q && docker rm $id
#

