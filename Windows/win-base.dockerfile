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
# % docker build -t snowfox:win-base -< win-base.dockerfile
# % docker images
#
# % docker container prune -f
# % docker system prune [-af]
#

FROM snowfox:win-arch

ENV JULIA_NUM_THREADS=auto \
	JULIA_SYS_ISDOCKER=1

RUN yes | pacman -Syu && yes | pacman -Scc && cd / && \
	git clone https://github.com/Heptazhou/Snowfox.git && cd /Snowfox/Windows && \
	julia --compile=min --color=yes make.jl / && \
	sha256sum -c *.sha256

ADD https://api.github.com/repos/Heptazhou/Snowfox/git/refs/heads/master version.json

RUN yes | pacman -Syu && yes | pacman -Scc && cd / && \
	cd /Snowfox/Windows && git pull -ftp && \
	julia --compile=min --color=yes make.jl / && \
	sha256sum -c *.sha256

RUN cd /Snowfox/Windows && ln -s /Snowfox/Windows/src /src && \
	tar fx snowfox-v`cat version`.source.tar.zst && \
	mv -fv snowfox-v`cat version` src && \
	rm -fr snowfox-*.tar.zst && git add -A && git commit -m Update && \
	cp -ft src mozconfig && ln -s /src/mach /bin/mach

RUN rustup default stable && \
	rustup target add x86_64-pc-windows-msvc

