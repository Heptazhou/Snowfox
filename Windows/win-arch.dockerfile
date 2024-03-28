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
	echo -e 'Server = https://mirrors.dotsrc.org/archlinux/$repo/os/$arch' >> $MIRRORLIST      && \
	echo -e 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >> $MIRRORLIST      && \
	tac $MIRRORLIST > $MIRRORLIST~ && mv $MIRRORLIST{~,} && pacman-key --init

RUN yes | pacman -Syu dbus-daemon-units fastfetch grml-zsh-config mc zsh-completions && \
	yes | pacman -S --needed bash-completion git julia nano-syntax-highlighting sha3sum \
	clang llvm msitools nasm nodejs-lts-iron python-pip wasi-{compiler-rt,libc++{,abi}} \
	cbindgen cross dump_syms unzip upx wget && yes | pacman -Scc && chsh -s /bin/zsh

RUN  url=https://github.com/0h7z/aur/releases/download && yes | pacman -U \
	$url/7-zip-full-v23.01-4/7-zip-full-23.01-4-x86_64.pkg.tar.zst \
	$url/nsis-v3.09-1/nsis-3.09-1-x86_64.pkg.tar.zst \
	$url/wine64-v9.5-1/wine64-9.5-1-x86_64.pkg.tar.zst && yes | pacman -Scc

RUN cd /bin && ln -s clear cls && ln -s julia jl && ln -s nano nn && ln -s nano vi && \
	git config --global pull.rebase true && \
	git config --global safe.directory "*" && \
	git config --global user.email root@localhost && \
	git config --global user.name root

