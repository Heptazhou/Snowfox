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
	julia make.jl && sha256sum -c *.sha256 && sha3-512sum -c *.sha3-512

ADD https://api.github.com/repos/Heptazhou/Snowfox/git/refs/heads/master version.json

RUN yes | pacman -Syu && yes | pacman -Scc && cd / && \
	cd /Snowfox/Windows && git pull -ftp && \
	julia make.jl && sha256sum -c *.sha256 && sha3-512sum -c *.sha3-512

RUN cd /Snowfox/Windows && mkdir -p $MOZBUILD_STATE_PATH $RUSTUP_HOME && \
	ln -s /src/mach /bin/mach && mkdir /pkg && \
	tar fx snowfox-v`cat version`.source.tar.zst && \
	mv -fv snowfox-v`cat version` src && cp -t /pkg 7z.jl && \
	rm -fr snowfox-*.zst && mv src / && cp -t /src mozconfig sourceurl.txt

RUN cd /Snowfox/Windows && version=`cat version` && l10n=`realpath l10n.tar.zst` && \
	cd $MOZBUILD_STATE_PATH && tar Ufx $l10n && rm $l10n && \
	mv -fv l10n l10n-central && curl -LO --fail-with-body \
	https://github.com/Heptazhou/Firefox/releases/download/v${version/.*/}/vs.tar.zst

