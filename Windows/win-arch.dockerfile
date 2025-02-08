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
# % docker build -t snowfox:win-arch -< win-arch.dockerfile
# % docker images
#
# % docker system prune [-af]
#

FROM archlinux:base-devel

ENV PATH=/bin:$PATH MOZBUILD_STATE_PATH=/moz RUSTUP_HOME=/rust

RUN pacman-key --init && mkdir /moz /rust && cat<<< \
	'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch'<<< \
	'Server = https://mirrors.dotsrc.org/archlinux/$repo/os/$arch'<<< \
	`< /etc/pacman.d/mirrorlist` > /etc/pacman.d/mirrorlist && \
	sed -re 's/(SigLevel) .+/\1 = Optional/g' -e 's/NoProgressBar/Color/g' -i /etc/pacman.conf

RUN yes | pacman -Syu git grml-zsh-config julia nano-syntax-highlighting sha3sum && \
	yes | pacman -S --needed bash-completion fastfetch less mc tree zsh-completions \
	clang llvm nodejs-lts-jod ripgrep rustup xclip \
	cbindgen nasm unzip upx wasi-{compiler-rt,libc++{,abi}} && yes | pacman -Scc

RUN  url=https://github.com/0h7z/aur/releases/download && yes | pacman -U \
	$url/nsis-v3.10-1/nsis-3.10-1-x86_64.pkg.tar.zst \
	$url/python311-v3.11.11-1/python311-3.11.11-1-x86_64.pkg.tar.zst \
	$url/wine64-v10.0-2/wine64-10.0-2-x86_64.pkg.tar.zst && yes | pacman -Scc

RUN cd /bin && ln -s clear cls && ln -s nano nn && ln -s nano vi && \
	git config --global safe.directory "*" && \
	git config --system log.date iso8601 && git config --global user.email root@localhost && \
	git config --system pull.rebase true && git config --global user.name  root           && \
	julia -ie 'using Pkg; pkg"registry add General https://github.com/0h7z/0hjl"; exit()' && \
	julia -ie 'using Pkg; pkg"registry status; add Exts"; exit()'

