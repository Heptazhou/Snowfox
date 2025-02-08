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
# % docker system prune [-af]
#

FROM snowfox:win-arch

ENV JULIA_NUM_THREADS=auto

RUN cd /moz && curl -LR -fw"%{url}\n" --retry 3 --retry-delay 5 \
	https://crates.io/api/v1/crates/windows/${WRS:=0.58.0}/download -o rs.tar.gz \
	https://github.com/Heptazhou/Firefox/releases/download/v135/vs.tar.zst -O && \
	tar fx rs.tar.gz  && rm rs.tar.gz  && mv windows-{$WRS,rs} && \
	tar fx vs.tar.zst && rm vs.tar.zst

RUN yes | pacman -Syu && yes | pacman -Scc && git clone \
	https://github.com/Heptazhou/Snowfox.git && cd /Snowfox/Source && \
	julia make.jl fetch && julia l10n.jl fetch

ADD https://api.github.com/repos/Heptazhou/Snowfox/git/refs/heads/master version.json

RUN yes | pacman -Syu && yes | pacman -Scc && cd /Snowfox/Source && git pull -ftp && \
	julia l10n.jl fetch unpack patch && \
	julia make.jl fetch unpack patch && \
	ln -v src/l10n -srt /moz && \
	mv -v src/snowfox-*/ -T /src && mkdir /pkg

RUN cd /Snowfox/Windows && \
	cp -t /pkg 7z.jl && \
	cp -t /src -a {,*.}mozconfig && \
	ln -s /src/mach /bin/mach

