# Copyright (C) 2022-2024 Heptazhou <zhou@0h7z.com>
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
	jl make.jl / && sha256sum -c *.sha256 && sha3-512sum -c *.sha3-512

ADD https://api.github.com/repos/Heptazhou/Snowfox/git/refs/heads/master version.json

RUN yes | pacman -Syu && yes | pacman -Scc && cd / && \
	cd /Snowfox/Windows && git pull -ftp && \
	jl make.jl / && sha256sum -c *.sha256 && sha3-512sum -c *.sha3-512

RUN cd /Snowfox/Windows && mkdir -p $MOZBUILD_STATE_PATH $RUSTUP_HOME && \
	ln -s /src/browser/locales/l10n $MOZBUILD_STATE_PATH/l10n-central && \
	ln -s /src/mach /bin/mach && mkdir /pkg && \
	tar fx snowfox-v`cat version`.source.tar.zst && \
	mv -fv snowfox-v`cat version` src && \
	rm -fr snowfox-*.zst && mv src / && \
	cp -t /src mozconfig && cp -t /pkg 7z.jl

RUN cd $MOZBUILD_STATE_PATH && curl -LO \
	https://github.com/Heptazhou/Firefox/releases/latest/download/vs.tar.zst

