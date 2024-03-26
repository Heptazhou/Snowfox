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

ENV MIRRORLIST=/etc/pacman.d/mirrorlist MOZBUILD_STATE_PATH=/moz RUSTUP_HOME=/rust \
	PATH=/bin:$PATH

RUN sed -re 's/(SigLevel) .+/\1 = Optional/g' -e 's/NoProgressBar/Color/g' -i /etc/pacman.conf && \
	echo -e '\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf && \
	echo -e '\nNoExtract  =' usr/lib{,32}/wine/i386-\*/\*                  >> /etc/pacman.conf && \
	echo -e 'Server = https://mirrors.dotsrc.org/archlinux/$repo/os/$arch' >> $MIRRORLIST      && \
	echo -e 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >> $MIRRORLIST      && \
	tac $MIRRORLIST > $MIRRORLIST~ && mv $MIRRORLIST{~,}

RUN pacman-key --init && pacman-key --lsign-key farseerfc@archlinux.org && \
	yes | pacman -Syu dbus-daemon-units && yes | pacman -S archlinuxcn-keyring fastfetch && \
	yes | pacman -S --needed grml-zsh-config nano-syntax-highlighting zsh-completions \
	7-zip-full clang julia llvm mc nodejs-lts-iron python-pip sha3sum tree unzip wget \
	cbindgen cross dump_syms msitools nasm upx wasi-{compiler-rt,libc++{,abi}} yay && \
	yes | pacman -Sdd wine-valve && yes | pacman -Scc && chsh -s /bin/zsh

RUN cd /bin && ln -s clear cls && ln -s julia jl && ln -s nano nn && ln -s nano vi && \
	git config --global init.defaultbranch master && \
	git config --global pull.rebase true && \
	git config --global user.email root@localhost && \
	git config --global user.name root && \
	git config --global safe.directory "*"

