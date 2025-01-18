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

RUN yes | pacman -Syu 7zip git grml-zsh-config julia sha3sum && \
	yes | pacman -S --needed bash-completion fastfetch mc nano zsh-completions \
	clang llvm msitools nasm nodejs-lts-jod python-pip wasi-{compiler-rt,libc++{,abi}} \
	cbindgen cross dump_syms unzip upx wget && yes | pacman -Scc && chsh -s /bin/zsh

RUN  url=https://github.com/0h7z/aur/releases/download && yes | pacman -U \
	$url/nsis-v3.10-1/nsis-3.10-1-x86_64.pkg.tar.zst \
	$url/python311-v3.11.11-1/python311-3.11.11-1-x86_64.pkg.tar.zst \
	$url/wine64-v9.21-1/wine64-9.21-1-x86_64.pkg.tar.zst && yes | pacman -Scc

RUN cd /bin && ln -s clear cls && ln -s nano nn && ln -s nano vi && \
	git config --global pull.rebase true && git config --global safe.directory "*" && \
	git config --global user.name root && git config --global user.email root@localhost && \
	julia -ie 'using Pkg; pkg"registry add General https://github.com/0h7z/0hjl.git"; exit()' && \
	julia -ie 'using Pkg; pkg"registry status; add Exts"; exit()'

