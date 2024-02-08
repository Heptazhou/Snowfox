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
# % docker build -t snowfox:win-arch -< win-arch.dockerfile
# % docker images
#
# % docker container prune -f
# % docker system prune [-af]
#

FROM archlinux:base-devel

ENV MOZBUILD_STATE_PATH=/moz RUSTUP_HOME=/rust \
	PATH=/bin:$PATH

RUN sed -ri 's/(EUID) == 0/\1 <= -1/g'            /bin/makepkg     && \
	sed -ri 's/^.*Color/DisableDownloadTimeout/g' /etc/pacman.conf && \
	sed -ri 's/^NoProgressBar/Color/g'            /etc/pacman.conf && \
	echo -e '''#!/bin/env sh\njulia --compile=min --color=yes $@\nexit $?' >> /bin/jl && \
	echo -e '\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf && \
	echo -e 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

RUN pacman-key --init && pacman-key --lsign-key farseerfc@archlinux.org && \
	yes | pacman -Syu dbus-broker-units && yes | pacman -S archlinuxcn-keyring fastfetch && \
	yes | pacman -S --needed grml-zsh-config nano-syntax-highlighting zsh-completions \
	7-zip-full clang git julia llvm mc nodejs-lts-iron python-pip sha3sum tree unzip wget \
	cbindgen cross dump_syms mercurial msitools nasm upx wasi-{compiler-rt,libc++{,abi}} && \
	yes | pacman -Scc && chsh -s /bin/zsh && chmod +x /bin/jl

RUN cd /bin && ln -s clear cls && ln -s nano nn && ln -s nano vi && \
	git config --global init.defaultbranch master && \
	git config --global pull.rebase true && \
	git config --global user.email root@localhost && \
	git config --global user.name root && \
	git config --global safe.directory "*"

