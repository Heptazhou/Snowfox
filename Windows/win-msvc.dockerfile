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
# % docker build -t snowfox:win-msvc -< win-msvc.dockerfile
# % docker images
#
# % docker container prune -f
# % docker system prune [-af]
#

FROM snowfox:win-arch

ENV JULIA_NUM_THREADS=auto \
	JULIA_SYS_ISDOCKER=1

RUN yes | pacman -Syu && yes | pacman -Scc && cd / && \
	git clone https://github.com/Heptazhou/Firefox.git --depth=1 -b v124 && \
	mv -fv Firefox src && git config --global core.pager ""

ADD https://api.github.com/repos/Heptazhou/Snowfox/git/refs/heads/master version.json

RUN yes | pacman -Syu && yes | pacman -Scc && cd / && \
	cd /src && git describe --always --tags > version && \
	curl -LOf https://github.com/Heptazhou/Snowfox/raw/master/Windows/vs.jl

RUN cd /src && mkdir -p $MOZBUILD_STATE_PATH && \
	git log --date=iso --show-signature && \
	ln -s /src/mach /bin/mach && mkdir /pkg && \
	jl vs.jl / && cd $MOZBUILD_STATE_PATH && \
	cp -t /pkg *.zst

FROM scratch
COPY --from=0 /pkg /pkg

# % id=`docker create snowfox:win-msvc -q` && docker cp $id:pkg . -q && docker rm $id

