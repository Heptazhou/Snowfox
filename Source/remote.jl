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

# [compat]
# julia = "≥ 1.5"

include("base_func.jl")

const remotes =
	[
		"browser/branding/snowfox/"
		"browser/branding/snowfox/content/"
		"browser/branding/snowfox/locales/"
		"browser/branding/snowfox/locales/en-US/"
		"browser/branding/snowfox/msix/" # nothing
		"browser/branding/snowfox/msix/Assets/"
		"browser/branding/snowfox/stubinstaller/"
	]

function remote(src::String, dst::String)
	src = replace(src, "\\" => "/")
	dst = replace(dst, "\\" => "/")
	src *= endswith(src, "/") ? "" : "/"
	dst *= endswith(dst, "/") ? "" : "/"
	@info src => dst
	for p ∈ remotes
		s = src * replace(p, "snowfox", "aurora", "w")
		d = dst * p
		@info Pair([s, d] .* "*"...)
		for f ∈ readdir(s)
			isfile(s * f) || continue
			!isdir(d) && mkpath(d)
			p = [s, d] .* f
			cp(p..., force = true, follow_symlinks = true)
		end
	end
	cd(dst * "browser/branding/snowfox/") do
		for p ∈ [
			"content/about-logo@2x.png" => "content/about.png",
			"stubinstaller/bgstub.jpg"  => "bgstub_2x.jpg",
			"stubinstaller/bgstub.jpg"  => "bgstub.jpg",
		]
			isfile.([p...]) |> all || continue
			cp(p..., force = true, follow_symlinks = true)
		end
	end
end

filter!(!=("/"), ARGS)
if isempty(ARGS)
	DIR = @__DIR__()
	try
		begin
			d = filter!(isdir, "$DIR/" .* ["../" .^ [1 2] .* ["Firefox", "firefox"]...])[1]
			remote(d, "$(isdir("$DIR/themes/") ? "$DIR/" : "$DIR/$SRC")" .* ("themes/"))
		end
	catch
		cd(mktempdir()) do
			@info replace(pwd(), "\\" => "/")
			u = "https://hg.mozilla.org/mozilla-central/archive/tip.zip/browser/branding/aurora/"
			curl("-LO", "-J", u)
			f = something(filter!(x -> isfile(x) && startswith(x, "mozilla-cent"), readdir())...)
			zip7("x", f), rm(f)
			d = splitext(f)[1]
			remote(d, "$(isdir("$DIR/themes/") ? "$DIR/" : "$DIR/$SRC")" .* ("themes/"))
		end
	end
else
	len = length(ARGS)
	src = ARGS[1]
	len < ((2)) && throw(SystemError(src, 22)) # EINVAL 22 Invalid argument
	dst = ARGS[2]
	!isdir(src) && throw(SystemError(src, 20)) # ENOTDIR 20 Not a directory
	!isdir(dst) && throw(SystemError(dst, 20)) # ENOTDIR 20 Not a directory
	remote(src, dst)
end

