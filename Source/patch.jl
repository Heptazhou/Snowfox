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

include("base_func.jl")

using Dates: Year, datetime2unix, now

const d_a = "aurora/"
const d_o = "official/"
const d_s = "snowfox/"
const d_x = stdpath(@__DIR__, "gecko/")
const f_1 = stdpath(@__DIR__, "search-config.json")
const f_2 = stdpath(@__DIR__, "search-config-v2.json")

function patch(x; keep = false, text = false)
	dir = mkpath(x) / ""
	for (prefix, ds, fs) ∈ walkdir(d_x)
		for f ∈ fs
			f ∈ ("policies.json", "snowfox.cfg") && keep && continue
			p = prefix / f
			p′ = replace(p, r"^" * d_x => dir)
			mkpath(dirname(p′))
			cp(p, p′, force = true)
		end
	end
	cd(dir) do
		cd("browser/branding/")
		for (prefix, ds, fs) ∈ walkdir(d_a)
			for f ∈ fs
				if (f) ∈ ("dsstore",) && !text ||
				   endswith(r"\.(bmp|icns|ico|jpg|png)")(f) && !text ||
				   endswith(r"\.(css|svg|xml)")(f)
					p  = prefix / f
					p′ = replace(p, r"^" * d_a => d_s)
					mkpath(dirname(p′))
					cp(p, p′, force = true)
				end
			end
		end
		for (prefix, ds, fs) ∈ walkdir(d_o)
			for f ∈ fs
				if (f) ∈ ("jar.mn", "moz.build")
					p  = prefix / f
					p′ = replace(p, r"^" * d_o => d_s)
					cp(p, p′, force = true)
				end
			end
		end
		cd(d_s)
		for f ∈ readdir()
			!startswith(f, r"firefox(64)?\.") && continue
			g = replace(f, r"firefox" => "snowfox", count = 1)
			mv(f, g, force = true)
		end
		cd("content/")
		for f ∈ readdir()
			f ≡ "about-logo@2x.png" &&
				cp(f, "about.png", force = true)
			if endswith(f, ".svg")
				s = readchomp(f)
				write(f, replace(s, "\r\n" => "\n"), "\n")
			end
		end
	end
	keep && return
	cd(dir) do
		cd("browser/config/") do
			f = "version.txt"
			g = "version_display.txt"
			s = readchomp(f)
			v = VER_INFO.moz_ver
			@assert s == v "expect `$v`, got `$s`"
			write(g, "$VER\n")
		end
		cd("services/settings/dumps/main/") do
			ms = 1_000 * round(Int64, datetime2unix(trunc(now(), Year)))
			s1 = replace(readstr(f_1), "\"{{ \$timestamp }}\"" => "$ms")
			s2 = replace(readstr(f_2), "\"{{ \$timestamp }}\"" => "$ms")
			for f ∈ readdir()
				contains(f, r"^search-[a-z\d-]+\.json$") && write(f, s1)
				contains(f, r"^search-config-v2\.json$") && write(f, s2)
			end
		end
	end
	let ver = "v$(VER.major)"
		for f ∈ [
			"$ver.patch"
			"crlf.patch"
			"font.patch"
			"typo.patch"
		]
			sh("patch --binary -sf -p1 -ld '$dir' < $f || true")
		end
	end
end

const keep = any(∈(ARGS), ("-k", "--keep"))
const text = any(∈(ARGS), ("-t", "--text"))

if abspath(PROGRAM_FILE) == @__FILE__
	@time foreach((ARGS)) do arg
		startswith(arg, r"--?\w") && return
		patch(arg; keep, text)
	end
end

# time julia patch.jl ../../Firefox -k -t

