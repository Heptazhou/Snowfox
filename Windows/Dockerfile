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
# % time docker build -t snowfox-arch - < Dockerfile
#
# % id=$(docker create snowfox-arch)
# % docker cp $id:/pkg .
# % docker rm $id
#
# % docker system prune [-af]
#

# FROM archlinux:base-devel
# FROM debian:testing
# FROM ubuntu:rolling

FROM archlinux:base-devel

WORKDIR /

# julia ≥ 1.7
ENV JULIA_NUM_THREADS=auto \
	JULIA_SYS_ISDOCKER=1

# Arch
RUN sed -i 's/NoProgressBar/Color/g' /etc/pacman.conf && \
	sed -i 's/EUID == 0/EUID < -0/g' /bin/makepkg && \
	pacman -Syu --noconfirm && \
	pacman -S --needed --noconfirm git grml-zsh-config julia mc nano-syntax-highlighting \
	mercurial msitools python-pip unzip wget zip && \
	ln -s /bin/clear /bin/cls && ln -s /bin/nano /bin/nn

# Debian
# SHELL ["/bin/bash", "-c"]
# ENV JULIA="julia-1.8.5"
# RUN \
# 	# Comment this if Ubuntu
# 	echo 'deb http://deb.debian.org/debian stable main' >> /etc/apt/sources.list && \
# 	apt update && apt list --upgradable && apt full-upgrade -y && \
# 	apt install -y curl git make mc nano patch wget zstd \
# 	dpkg-sig libssl-dev mercurial msitools p7zip-full python3-pip upx-ucl wine64-tools && \
# 	curl -LO https://julialang-s3.julialang.org/bin/linux/x64/1.8/$JULIA-linux-x86_64.tar.gz && \
# 	tar xf $JULIA-linux-x86_64.tar.gz && rm $JULIA-linux-x86_64.tar.gz && \
# 	ln -s /$JULIA/bin/julia /bin/

RUN julia --compile=min -e 'using InteractiveUtils; versioninfo()'

RUN git clone https://github.com/Heptazhou/Snowfox.git

WORKDIR /Snowfox/Windows/

RUN julia --compile=min --color=yes make.jl all && \
	rm -rf /src && mv src/linux /src && rm -rf src && cd /src && \
	git config --global init.defaultbranch master && \
	git config --global user.name root && \
	git config --global user.email root@localhost && \
	git init && git add -A ':!*.zst' && git commit -m. && \
	git remote add origin https://github.com/Heptazhou/Snowfox.git

WORKDIR /src/

RUN make fetch && make bootstrap

RUN make all   && make veryclean

