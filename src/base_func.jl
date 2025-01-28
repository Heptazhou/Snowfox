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

include("const.jl")

using Base: Filesystem
using Exts

Base.:/(s1::String, ss::String...)::String = stdpath(s1, ss...)

const sh(c::String) = run(`sh -c $c`)

const hash_chk(f::String, h::SymOrStr) = sh("$(h)sum -c $(f).$(h)")
const hash_gen(f::String, h::SymOrStr) = sh("$(h)sum $(f) | tee $(f).$(h)")

const hash_chk(f::String, hs::VecOrTup = HASH_ALGOS) = hash_chk.(f, hs)
const hash_gen(f::String, hs::VecOrTup = HASH_ALGOS) = hash_gen.(f, hs)

macro skip_ds(path)
	quote
		any(occursin($(esc(path))),
			[
				".git/"
				"/android/"
				"/benchmarks/"
				"/ci/"
				"/crashtests/"
				"/dist/"
				"/docs/"
				"/documentation/"
				"/fuzztest/"
				"/gtest/"
				"/gtests/"
				"/jsapi-tests/"
				"/node_modules/"
				"/perfdocs/"
				"/PerformanceTests/"
				"/reftests/"
				"/source-test/"
				"/test/"
				"/testdata/"
				"/testing/"
				"/tests/"
				"/unittest/"
				"/unittests/"
			],
		) && continue
	end
end

function curl(url::String, f::String = basename(url); force::Bool = false)::String
	force && rm(f; force)
	isfile(f) || sh("$CURL $CURL_ARGS -Lo '$f' $url")
	f
end

function expands(str::String)::String
	f(t::NTuple{2, String}) = r"\b" * t[1] * r"\b" => t[2]
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
		tup = (pair...,) .* ("n't", "")
		str = replace(str, f(lowercasefirst.(tup)))
		str = replace(str, f(uppercasefirst.(tup)))
		tup = (pair...,) .* ("n’t", "")
		str = replace(str, f(lowercasefirst.(tup)))
		str = replace(str, f(uppercasefirst.(tup)))
	end
	str
end

"""
	walkdir(path = pwd(); topdown = true)

Return an iterator that walks the directory tree of a directory.

The iterator returns a tuple containing `(path, dirs, files)`. Each iteration
`path` will change to the next directory in the tree; then `dirs` and `files`
will be vectors containing the directories and files in the current `path`
directory. The directory tree can be traversed top-down or bottom-up. The
returned iterator is stateful so when accessed repeatedly each access will
resume where the last left off, like [`Iterators.Stateful`](@ref).

See also: [`readdir`](@ref).

# Examples
```julia
for (path, ds, fs) ∈ walkdir(".")
	println("Directories in \$path")
	for d ∈ ds
		println(path / d) # path to directories
	end
	println("Files in \$path")
	for f ∈ fs
		println(path / f) # path to files
	end
end
```
"""
function walkdir(path = pwd(); topdown::Bool = true)
	function _walk(ch, pf)
		ds = String[]
		fs = String[]
		xs = @static VERSION ≥ v"1.11" ? Filesystem._readdirx(pf) : readdir(pf)
		for x ∈ xs
			push!(isdir(x) ? ds : fs, @static VERSION ≥ v"1.11" ? x.name : x)
		end
		topdown && push!(ch, (pf, ds, fs))
		for d ∈ ds
			_walk(ch, stdpath(pf, d))
		end
		topdown || push!(ch, (pf, ds, fs))
		nothing
	end
	Channel{Tuple{String, Vararg{Vector{String}, 2}}}() do chnl
		_walk(chnl, stdpath(path))
	end
end

