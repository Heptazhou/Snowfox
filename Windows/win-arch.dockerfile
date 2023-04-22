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
# % docker build -t snowfox:win-arch -< win-arch.dockerfile
# % docker images
#
# % docker container prune -f
# % docker system prune [-af]
#

FROM archlinux:base-devel

ENV MOZBUILD_STATE_PATH=/moz \
	RUSTUP_HOME=/rust

RUN sed -ri 's/(EUID) == 0/\1 <= -1/g'            /bin/makepkg     && \
	sed -ri 's/^.*Color/DisableDownloadTimeout/g' /etc/pacman.conf && \
	sed -ri 's/^(ParallelDownloads) = 5/\1 = 8/g' /etc/pacman.conf && \
	sed -ri 's/^NoProgressBar/Color/g'            /etc/pacman.conf && \
	echo -e '\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf && \
	echo -e 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

RUN yes | pacman -Syu && pacman-key --init && yes | pacman -S archlinuxcn-keyring && \
	yes | pacman -S --needed \
	git grml-zsh-config julia mc nano-syntax-highlighting zsh-completions \
	7-zip-full mercurial msitools python-pip unzip wget \
	cbindgen clang cross dump_syms nasm nodejs-lts-hydrogen rustup upx && \
	yes | pacman -Scc && chsh -s /bin/zsh

RUN cd /bin && ln -s clear cls && ln -s nano nn && ln -s nano vi && \
	git config --global init.defaultbranch master && \
	git config --global pull.rebase true && \
	git config --global user.email root@localhost && \
	git config --global user.name root && \
	mkdir -p /moz /pkg /rust

