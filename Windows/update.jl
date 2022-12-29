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
# julia = "≥ 1.6"

include("base_func.jl")
include("const.jl")

const website = "https://github.com/0h7z/Snowfox"
const patches =
	[
		"linux/assets/tryfix-reslink-fail.patch";
	]

function update(dir::String, recursive::Bool = SUBMODULES)
	@info dir recursive
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = false)
		occursin(prefix)(r"\.git\b") && continue
		occursin(prefix)(r"\bsubmodules\b") && !recursive && continue
		cd(prefix) do
			for d ∈ ds
				if (d ∈ ("linux-mar", "winbuild"))
					rm(d, recursive = true)
					continue
				end
			end
			for f ∈ fs
				if (f ∈ patches .|> basename)
					rm(f)
					continue
				end
				if (f ≠ ".git") && !endswith(".jl")(f) && !isbinary(f)
					s = read(f, String)
					for p ∈ schemes
						s = replace(s, p...)
					end
					s = replace(s, "(?<!=['\"])http://(?!www\\.w3\\.org/)", "https://")
					s = replace(s, "(/github\\.com)/ltGuillaume/(Snowfox-Portable)", s"\1/Heptazhou/\2")
					s = replace(s, "\r\n" => "\n")
					s = replace(s, "apt-get", "apt", "w")
					s = replace(s, "ubuntu:jammy", "ubuntu:rolling", "w")
					s = replace(s, raw"snowfox-{}-{}" => raw"snowfox-v{}-{}")
					s = replace(s, raw"snowfox-$(full_version)" => raw"snowfox-v$(full_version)")
					s = replace(s, raw"snowfox-$(version)" => raw"snowfox-v$(version)")
					s = replace(s, raw"snowfox-$$(cat version)" => raw"snowfox-v$$(cat version)")
					s = replace(s, raw"snowfox-v\$\(full_version\)\.source\.tar\K\.gz", (".zst"))
					s = replace(s, raw"snowfox-v\$\$\(cat version\)-\$\$\(cat source_release\)\.source\.tar\K\.gz", (".zst"))
					#
					s = replace(s, r"[\t ]+$"m => "")
					s = replace(s, r"https://\Kraw\.(github)usercontent(\.com/[^/]+/[^/]+)/", s"\1\2/raw/")
					s = replace(s, r"https://\Ksnowfox(\.net)", s"librewolf\1")
					s = replace(s, r"https://gitlab\.com/\Ksnowfox(-community)", s"librewolf\1")
					s = replace(s, r"https://gitlab\.com/librewolf-community/\S*?\Ksnowfox"i, s"librewolf")
					s = replace(s, r"https://librewolf\.net/\S*?\Ksnowfox"i, s"librewolf")
					if (f ≡ "Makefile") || endswith(".mk")(f)
						p = raw"v$$(cat version)-$$(cat source_release).source.tar.zst"
						q = raw"https://gitlab.com/librewolf-community/browser/source/"
						s = replace(s,
							"""	wget -q -O version "$q-/raw/main/version"\n""" *
							"""	wget -q -O source_release "$q-/raw/main/release"\n""" *
							"""	wget -q -O "snowfox-$p.sha256" "$q-/jobs/artifacts/main/raw/librewolf-$p.sha256sum?job=Build"\n""" *
							"""	wget --progress=bar:force -O "snowfox-$p" "$q-/jobs/artifacts/main/raw/librewolf-$p?job=Build"\n""" *
							"""	cat "snowfox-$p.sha256"\n""" *
							"""	sha256sum -c "snowfox-$p.sha256"\n""", # ~ do not sort this
							"""	sha256sum -c "snowfox-$p.sha256"\n""", "p")
						p = raw"$(release)"
						s = replace(s, "[ $p -gt 1 ] && echo \"-$p\"" => "[[ $p -ge 1 ]] && echo \"+$p\"")
						s = replace(s, "s/pkg_version/\$(full_version)/g" => "s/pkg_version/v\$(full_version)/g")
						s = replace(s, r"^.*\btryfix-reslink-fail\.patch\b.*\n"m => "")
					end
					if (f ≡ "Makefile")
						s = replace(s, "Build snowfox and it's windows artifact" => "Build Snowfox and its Windows artifact")
						s = replace(s, r"^.*\brm -f version source_release\b.*"m => "")
						s = replace(s,
							"""	\${MAKE} -f assets/artifacts.mk artifacts\n""" * "\n",
							"""	\${MAKE} -f assets/artifacts.mk artifacts\n""" *
							"""	rm -rf /pkg && mkdir /pkg\n""" *
							"""	cp -pt /pkg snowfox-*.exe snowfox-*.zip\n""" * "\n", "p")
					end
					if (f ≡ "artifacts.mk")
						p = "Snowfox-Portable"
						q = "snowfox-v\$(full_version)"
						s = replace(s, ("/$p/$p.* ") => ("/$p/*.ahk "))
						s = replace(s, r"^.*\bWinUpdater\b.*\n"m => "")
						s = replace(s,
							"""	( cd work/$q && wine64 ../ahk/Compiler/Ahk2Exe.exe /in $p.ahk /icon $p.ico )\n""" *
							"""	( cd work/$q && rm -f $p.ahk $p.ico dejsonlz4.exe jsonlz4.exe )\n""", # ~ do not sort this
							"""	( cd work/$q && rm -f -r  Compiler  &&  mkdir  Compiler )\n""" * # ~ do not move this
							"""	( cd work/$q && cp ../ahk/Compiler/*64-bit.bin Compiler )\n""" *
							"""	( cd work/$q && cp ../ahk/Compiler/Ahk2Exe.exe Compiler )\n""" *
							"""	( cd work/$q && cp ../snowfox/snowfox.ico ./Snowfox.ico )\n""", "p")
					end
					if (f ≡ "mozconfig")
						p = "ac_add_options"
						s = replace(s,
							"$p --with-app-name=\\w+\n" *
							"$p --with-branding=browser/branding/\\w+\n",
							"$p --with-app-name=firefox\n" *
							"$p --enable-update-channel=release\n" *
							"$p --with-branding=browser/branding/snowfox\n", "e") # ~ do not sort this
						p = "mk_add_options"
						s = replace(s,
							"$p MOZ_CRASHREPORTER=0\n" *
							"$p MOZ_DATA_REPORTING=0\n" *
							"$p MOZ_NORMANTY=0\n" *
							"$p MOZ_SERVICES_HEALTHREPORT=0\n" *
							"$p MOZ_TELEMETRY_REPORTING=0\n", # ~ do not sort this
							"$p MOZ_CRASHREPORTER=0\n" *
							"$p MOZ_DATA_REPORTING=0\n" *
							"$p MOZ_SERVICES_HEALTHREPORT=0\n" *
							"$p MOZ_TELEMETRY_REPORTING=0\n", "p", n = 1)
						s = replace(s, r"^.*--disable-verify-mar\b.*\n"m => "")
						s = replace(s, r"^export MOZ_REQUIRE_SIGNING=\K1?$"m, '"'^2)
					end
					if (f ≡ "setup.nsi")
						s = expand(s)
					end
					write(f, s)
				end
			end
		end
	end
end

const SUBMODULES = something(tryparse.(Bool, ARGS)..., false)

filter!(!=("/"), ARGS)
if isempty(ARGS)
	(dir, arg) = @__DIR__, pwd()
	update(startswith(arg, dir) ? arg : dir)
else
	(dir, arg) = @__DIR__, abspath.(ARGS[1])
	isdir(arg) || throw(SystemError(arg, 2))
	update(startswith(arg, dir) ? arg : dir)
end

