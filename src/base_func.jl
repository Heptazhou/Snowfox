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

include("const.jl")

import Base.replace

const Curl(x::String...)::Cmd =
	Cmd(["curl", "--http2", "--tlsv1.2",
		"-A\"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:$UAV.0) Gecko/20100101 Firefox/$UAV.0\"", x...])
const Zip7(x::String...)::Cmd =
	Cmd(["7z", x...])

const Curl(x::Vector{String})::Cmd = Curl(x...)
const Zip7(x::Vector{String})::Cmd = Zip7(x...)

const curl(x...) = Curl(x...) |> run
const zip7(x...) = Zip7(x...) |> run

macro run(vec)
	quote
		local x = @eval Cmd($vec)
		x |> println
		x = read(x, String)
		x |> println
		x
	end
end
macro run(vec, ret)
	quote
		local x = @eval Cmd($vec)
		x |> println
		x = read(x, String)
		x |> println
		$(esc(ret)) = x
	end
end

function expands(str::String)::String
	for pair ∈ [
		"are"    => "are not",
		"ca"     => "cannot",
		"could"  => "could not",
		"did"    => "did not",
		"do"     => "do not",
		"does"   => "does not",
		"had"    => "had not",
		"has"    => "has not",
		"have"   => "have not",
		"is"     => "is not",
		"must"   => "must not",
		"sha"    => "shall not",
		"should" => "should not",
		"was"    => "was not",
		"were"   => "were not",
		"wo"     => "will not",
		"would"  => "would not",
	]
		vec = [pair...] .* ["n't", ""]
		str = replace(str, lowercasefirst.(vec)..., "w")
		str = replace(str, uppercasefirst.(vec)..., "w")
		vec = [pair...] .* ["n’t", ""]
		str = replace(str, lowercasefirst.(vec)..., "w")
		str = replace(str, uppercasefirst.(vec)..., "w")
	end
	str
end

function isbinary(f::String)::Bool
	f == "dsstore" ||
		# See also
		# Firefox/browser/installer/windows/nsis/shared.nsh
		# > ${WriteApplicationsSupportedType} ${RegKey}
		# Firefox/toolkit/components/reputationservice/ApplicationReputation.cpp
		# > ApplicationReputationService::kBinaryFileExtensions[]
		# Firefox/toolkit/content/filepicker.properties
		endswith(r"\.(7z|br|bz2|gz|lz4|rar|tar|xz|zip|zlib|zst)")(f) ||                           # archive
		endswith(r"\.(a?png|avif|bmp|cur|gif|icns|ico|jfif|jxl|m?jpe?g|pjp(eg)?|svg|webp)")(f) || # image
		endswith(r"\.(aac|ac3|flac|m4a|mp3|ogg|opus|wav|weba)")(f) ||                             # audio
		endswith(r"\.(aps|bin|crx|db|der|dll|exe|hyf|jar|mar|pck|pdf|pyc|wasm|xcf|xpi)")(f) ||    # binary
		endswith(r"\.(bf|otf|ttf|ttx|woff2?)")(f) ||                                              # font
		endswith(r"\.(cache|cer|dic|lock|map|pem|sig(nature)?)|-lock\.(json|yaml)")(f) ||         # other
		endswith(r"\.(flv|mkv|mp4|mpeg|ogv|webm)")(f) ||                                          # video
		contains(r"^.+\.(bundle|min|sig(nature)?)\.[-\w]+$")(f) ||
		contains(r"binary_data"i)(f) ||
		!isvalid(read(f, String))
end

function pause(Msg = missing; up::Int = 0, down::Int = 0)
	isinteractive() && return
	print('\n'^up)
	pause(stdin, stdout, Msg)
	print('\n'^down)
end
function pause(In::IO, Out::IO, Msg = missing)
	print(Out, Msg isa String ? Msg : "Press any key to continue . . . ")
	ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid}, Int32), In.handle, 1)
	read(In, Char)
	ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid}, Int32), In.handle, 0)
	println(Out)
end

# e => regex, p => plain, w => whole
function replace(str::R, old::T, new::S, flag::String = "e"; n::Int = -1)::String where
R <: AbstractString where S <: AbstractString where T <: NTuple{2, AbstractString}
	flag ≡ "e" && ((new, old) = (SubstitutionString(new), Regex(old...)))
	flag ≡ "p" && ((new, old) = (String(new), Regex("\\Q$(old[1])\\E", old[2])))
	flag ≡ "w" && ((new, old) = (String(new), Regex("\\b\\Q$(old[1])\\E\\b", old[2])))
	replace(str, old, new; n)
end
function replace(str::R, old::T, new::S, flag::String = "e"; n::Int = -1)::String where
R <: AbstractString where S <: AbstractString where T <: AbstractString
	flag ≡ "e" && ((new, old) = (SubstitutionString(new), Regex(old)))
	flag ≡ "p" && ((new, old) = (String(new), Regex("\\Q$old\\E")))
	flag ≡ "w" && ((new, old) = (String(new), Regex("\\b\\Q$old\\E\\b")))
	replace(str, old, new; n)
end
function replace(str::R, old::T, new::S, flag::String = "e"; n::Int = -1)::String where
R <: AbstractString where S <: AbstractString where T <: AbstractPattern
	while 0 ≠ n && occursin(old, str)
		(str, n) = (replace(str, old => new), n - 1)
		(-1 - n) > +100 && error(old => new)
	end
	str
end

function v_read(ver::VersionNumber)::NTuple{3, String}
	vx = string(VersionNumber(ver.major, ver.minor, ver.patch)) |> s -> replace(s, r"\.0$" => "")
	vy = filter(!isempty, filter.(isdigit, string.([ver.prerelease..., 1])))[1]
	vz = filter(!isempty, filter.(isdigit, string.([ver.build..., 0])))[1]
	vx, vy, vz
end

# move(dir::String, recursive::Bool = false)
function move(dir::String, recursive::Bool = SUBMODULES)
	@info dir recursive
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = false)
		occursin(prefix)(r"\.git\b") && continue
		occursin(prefix)(r"\bsubmodules\b") && !recursive && continue
		cd(prefix) do
			for d ∈ ds
				if d ∈ (".gitlab",)
					rm(d, recursive = true)
					continue
				end
				s = d = d * "/"
				for p ∈ schemes
					d = replace(d, p...)
				end
				s ≠ d && (@info "$prefix: $(s => d)"; mv(s, d, force = true))
			end
			for f ∈ fs
				if (f) ∈ (".gitignore", ".gitlab-ci.yml") || endswith(r"\.(aps|md)")(f)
					rm(f)
					continue
				end
				s = d = f
				for p ∈ schemes
					d = replace(d, p...)
				end
				s ≠ d && (@info "$prefix: $(s => d)"; mv(s, d, force = true))
			end
		end
	end
end

