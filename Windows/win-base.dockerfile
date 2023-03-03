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

RUN yes | pacman -Syu && yes | pacman -Scc && rustup update && cd / && \
	git clone https://github.com/Heptazhou/Snowfox.git && cd /Snowfox/Windows && \
	julia --compile=min --color=yes make.jl all && \
	sha256sum -c *.sha256

ADD https://api.github.com/repos/Heptazhou/Snowfox/git/refs/heads/master version.json

RUN yes | pacman -Syu && yes | pacman -Scc && rustup update && cd / && \
	cd /Snowfox/Windows && git pull -ftp && \
	julia --compile=min --color=yes make.jl all && \
	sha256sum -c *.sha256

RUN rm -rf /src && cd /Snowfox/Windows && mv src/linux /src && mv snowfox-* /src && \
	rm -rf /Snowfox && cd /src && \
	git init && git add -A ':!*.zst' && git commit -m. && \
	git remote add origin https://github.com/Heptazhou/Snowfox.git

