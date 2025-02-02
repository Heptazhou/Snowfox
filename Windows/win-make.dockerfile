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

ENV CARGO_BUILD_JOBS=1 \
	CARGO_INCREMENTAL=0

RUN cd /src && rustup default 1.83 && rustup target add x86_64-pc-windows-msvc && \
	ver=`cargo pkgid windows | grep -Po '#\K.+'` && cd $MOZBUILD_STATE_PATH && \
	curl -LR https://crates.io/api/v1/crates/windows/$ver/download -o windows.gz && \
	tar Ufx windows.gz && rm windows.gz && mv windows-{$ver,rs} && \
	tar Ufx vs.tar.zst && rm vs.tar.zst && systemd-machine-id-setup

RUN cd /src && python3.11 mach configure
RUN cd /src && python3.11 mach build

RUN cd /src && python3.11 mach package-multi-locale \
	--locales `cat browser/locales/shipped-locales` > /dev/null

RUN cd /pkg && cp -pvt . /src/obj-*/dist/{install/sea/,snowfox-}* && \
	rm *.xpt_artifacts.* || true
RUN cd /pkg && julia 7z.jl && rm 7z.jl

FROM scratch
COPY --from=0 /pkg /pkg

# % id=`docker create snowfox:win-make -q` && docker cp $id:pkg . -q && docker rm $id && julia move.jl

