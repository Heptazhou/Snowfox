# Copyright (C) 2022-2024 Heptazhou <zhou@0h7z.com>
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

include("const.jl")

using Exts

import Base.replace

const sh(c::String) = run(`sh -c $c`)

const Curl(x::String...; v::String)::Cmd =
	Cmd(["curl", "--fail-with-body", "--http2-prior-knowledge", "--tls" * "v$v",
		"-A\"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:$ESR.0) Gecko/20100101 Firefox/$ESR.0\"", x...])
const Zip7(x::String...)::Cmd =
	Cmd(["7z", x...])

const Curl(x::Vector{String}; kw...)::Cmd = Curl(x...; kw...)
const Zip7(x::Vector{String}; kw...)::Cmd = Zip7(x...; kw...)

const curl(x...) =
	try
		Curl(x...; v = "1.3") |> run
	catch
		Curl(x...; v = "1.2") |> run
	end
const zip7(x...) = Zip7(x...) |> run

macro exec(vec)
	quote
		local x = @eval Cmd($vec)
		x |> println
		x |> run
	end
end
macro exec(vec, ret)
	quote
		local x = @eval Cmd($vec)
		x |> println
		x = (readstr)(x)
		x |> println
		$(esc(ret)) = x
	end
end

function expands(str::String)::String
	for pair ∈ (
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
	)
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
	f ∈ (".DS_Store", "dsstore") ||
		# See also
		# Firefox/browser/installer/windows/nsis/shared.nsh
		# > ${WriteApplicationsSupportedType} ${RegKey}
		# Firefox/toolkit/components/reputationservice/ApplicationReputation.cpp
		# > ApplicationReputationService::kBinaryFileExtensions[]
		# Firefox/toolkit/content/filepicker.properties
		endswith(r"\.(7z|br|bz2|gz|lz4|rar|tar|xz|zip|zlib|zstd?)")(f) ||                            # archive
		endswith(r"\.(a?png|avif|bmp|gif|hei[cf]|jfif|jxl|m?jpe?g|pjp(eg)?|svgz?|tiff?|webp)")(f) || # image
		endswith(r"\.(aac|ac3|flac|m4a|mp3|ogg|opus|wav|weba)")(f) ||                                # audio
		endswith(r"\.(aps|bin|crx|db|der|dll|exe|hyf|jar|mar|pck|pdf|pyc|wasm|xcf|xpi)")(f) ||       # binary
		endswith(r"\.(bf|otf|ttf|ttx|woff2?)")(f) ||                                                 # font
		endswith(r"\.(cache|cer|dic|lock|map|pem|sig(nature)?)|-lock\.(json|yaml)")(f) ||            # other
		endswith(r"\.(cur|icns|ico)")(f) ||                                                          # icon
		endswith(r"\.(f[4l]v|mkv|mov|mp4|mpeg|ogv|webm)")(f) ||                                      # video
		contains(r"^.+\.(bundle|min|sig(nature)?)\.[-\w]+$")(f) ||
		contains(r"binary_data"i)(f) ||
		!isvalid(f |> readstr)
end

# e => regex, p => plain, w => whole
function replace(
	str::AbstractString,
	old::NTuple{2, AbstractString},
	new::AbstractString,
	flag::String = "e"; n::Int = -1)::String
	flag ≡ "e" && ((new, old) = (SubstitutionString(new), Regex(old...)))
	flag ≡ "p" && ((new, old) = (String(new), Regex("\\Q$(old[1])\\E", old[2])))
	flag ≡ "w" && ((new, old) = (String(new), Regex("\\b\\Q$(old[1])\\E\\b", old[2])))
	replace(str, old, new; n)
end
function replace(
	str::AbstractString,
	old::AbstractString,
	new::AbstractString,
	flag::String = "e"; n::Int = -1)::String
	flag ≡ "e" && ((new, old) = (SubstitutionString(new), Regex(old)))
	flag ≡ "p" && ((new, old) = (String(new), Regex("\\Q$old\\E")))
	flag ≡ "w" && ((new, old) = (String(new), Regex("\\b\\Q$old\\E\\b")))
	replace(str, old, new; n)
end
function replace(
	str::AbstractString,
	old::AbstractPattern,
	new::AbstractString,
	flag::String = "e"; n::Int = -1)::String
	while 0 ≠ n && occursin(old, str)
		(str, n) = (replace(str, old => new), n - 1)
		(-1 - n) > +100 && error(old => new)
	end
	str
end

function replace(
	str::AbstractString,
	old::AbstractVector{<:AbstractString},
	new::AbstractVector{<:AbstractString},
	delim::String = ","; n::Int = 1)::String
	old = join("\"" .* old .* "\"", delim * " "^n)
	new = join("\"" .* new .* "\"", delim * " "^n)
	str = replace(str, old => new)
end
function replace(
	str::AbstractString,
	old::Any,
	new::Any,
	qtn::String = "\""; n::Int = -1)::String
	old = old isa AbstractString ? qtn * old * qtn : string(old)
	new = new isa AbstractString ? qtn * new * qtn : string(new)
	str = replace(str, old => new)
end

function v_read(ver::VersionNumber)::NTuple{3, String}
	vx = string(VersionNumber(ver.major, ver.minor, ver.patch))
	vy = filter(!isempty, filter.(isdigit, string.([ver.prerelease..., 0])))[1]
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
				if (d) ∈ (".gitlab", "docs") || startswith(r"\.(forgejo|woodpecker)")(d)
					rm(d, recursive = true)
					continue
				end
				if (d) ∈ ("submodules",) && !recursive
					rm(d, recursive = true)
					continue
				end
				s = d = d * "/"
				for p ∈ schemes
					d = replace(d, p...)
				end
				s ≠ d && (@info "$prefix: $(s => d)";
				(mkpath(d); foreach(p -> mv(s * p, d * p, force = true), readdir(s)); rm(s)))
			end
			for f ∈ fs
				if (f) ∈ (".gitattributes", ".gitignore", ".gitlab-ci.yml", "pack_vs.py") ||
				   endswith(r"\.(aps|cfg\.js|md|mk)")(f) || startswith(r"\.(forgejo|woodpecker)")(f) ||
				   contains(r"(build|fail|fetch|linux|module|patch|tree)\.sh$|^(category|file).*\.svg$")(f)
					rm(f)
					continue
				end
				if (f) ∈ (".gitmodules",) && !recursive
					rm(f)
					continue
				end
				if (f) ∈ ("Dockerfile",) && !isempty(prefix)
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

