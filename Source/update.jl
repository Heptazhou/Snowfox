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

using Base64: base64encode

const website = "https://github.com/0h7z/Snowfox"
const patches =
	[
		"patches/ui-patches/hide-default-browser.patch"
		"patches/ui-patches/pref-naming.patch"
		"patches/ui-patches/privacy-preferences.patch"
		"patches/ui-patches/remove-branding-urlbar.patch"
		"patches/ui-patches/snowfox-logo-devtools.patch"
	]
const moz_tmk = "Firefox and the Firefox logos are trademarks of the Mozilla Foundation."

function update(dir::String, recursive::Bool = SUBMODULES)
	@info dir recursive
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = false)
		occursin(prefix)(r"\.git\b") && continue
		occursin(prefix)(r"\bsubmodules\b") && !recursive && continue
		cd(prefix) do
			for f ∈ fs
				if (f ∈ patches .|> basename)
					rm(f)
					continue
				end
				if (f ≠ ".git") && !endswith(".jl")(f) && !isbinary(f)
					s = read(f, String)
					if endswith(r"\.(diff|patch)")(f)
						s = replace(s, " [ab]\\K/lw/", "/snowfox/")
						for p ∈ schemes
							s = replace(s -> startswith(s, '+') ? replace(s, p...) : s, split(s, '\n')) |> s -> join(s, '\n')
						end
					else
						for p ∈ schemes
							s = replace(s, p...)
						end
					end
					s = replace(s, "\r\n" => "\n")
					s = replace(s, r"https://\Kraw\.(github)usercontent(\.com/[^/]+/[^/]+)/", s"\1\2/raw/")
					s = replace(s, r"https://\Ksnowfox(\.net)", s"librewolf\1")
					s = replace(s, r"https://gitlab\.com/\Ksnowfox(-community)", s"librewolf\1")
					s = replace(s, r"https://gitlab\.com/librewolf-community/\S*?\Ksnowfox"i, s"librewolf")
					s = replace(s, r"https://librewolf\.net/\S*?\Ksnowfox"i, s"librewolf")
					#
					s = replace(s, "aboutMenu.checkVersion", "app.checkVersion.enabled", "w")
					s = replace(s, "aboutMenu.versionCheckGitlabUrl", "app.checkVersion.url", "w")
					s = replace(s, "apt-get", "apt", "w")
					s = replace(s, "github.com/Snowfox-Browser", "github.com/0h7z", "w")
					s = replace(s, "io.gitlab", "com.0h7z", "w")
					s = replace(s, "io/gitlab", "com/0h7z", "w")
					s = replace(s, "referes", s"referrers", "w")
					s = replace(s, "snowfox-{}-{}", "snowfox-v{}-{}", "p")
					s = replace(s, "snowfox-\$(full_version)", "snowfox-v\$(full_version)", "p")
					s = replace(s, "snowfox-\$(version)", "snowfox-v\$(version)", "p")
					s = replace(s, "snowfox-\$\$(cat version)", "snowfox-v\$\$(cat version)", "p")
					s = replace(s, "snowfox-community", ("snowfox"), "w")
					s = replace(s, "ubuntu:jammy", "ubuntu:rolling", "w")
					s = replace(s, "www.snowfox.gitlab.io", "github.com/0h7z", "w")
					if f ∈ ("appstrings.properties", "snowfox.cfg")
						s = expand(s)
					end
					p = "(?<!=['\"])http://(?!www\\.w3\\.org/)" => "https://"
					if endswith(r"\.(diff|patch)")(f)
						s = replace(s -> startswith(s, '+') ? replace(s, p...) : s, split(s, '\n')) |> s -> join(s, '\n')
						s = replace(s, ("does-snowfox-use-https-only-mode"), ("does-librewolf-use-https-only-mode"), "w")
						s = replace(s, r"^\+.*ColorScheme::\KLight"m, s"Dark")
						s = replace(s, r"^\+.*https://support.mozilla.org/\Ken-US/"im, "")
						s = replace(s, r"privacy\_\Koverride_rfp_for_color_scheme", "resistFingerprinting_override_color_scheme")
						s = replace(s, r"privacy\.\Koverride_rfp_for_color_scheme", "resistFingerprinting.override-color-scheme")
						s = replace(s, r"Snowfox will force web content to display in \Ka light (theme\.\")", s"dark \1")
					else
						s = replace(s, p...)
					end
					if endswith(".cfg")(f) || endswith(".js")(f)
						s = replace(s, r";[\t ]+//"m, s";//")
						s = replace(s, r"(?<=;)//"m => " //")
						s = replace(s, r"[\t ]+$\n"m => "\n")
						s = replace(s, r"//\K(\S+)"m, s" \1")
						s = replace(s, r"^.+://\K +"m => s"")
						s = replace(s, r"^\n{3,}\K\n+"m, s"")
						s = replace(s, r"^\t*\K {2}"m, s"\t")
					end
					if endswith(".css")(f)
						s = replace(s, r"^\t*\K {2}"m, s"\t")
					end
					if endswith(".json")(f)
						s = replace(s, r"^\t*\K {4}"m, s"\t")
					end
					if endswith(".py")(f)
						s = replace(s, r"[\t ]{1,}$"m => s"")
						s = replace(s, r"^\t*\K {4}"m, s"\t")
					end
					if startswith(r"mozconfig\b")(f)
						p = "ac_add_options"
						s = replace(s,
							"$p --with-app-name=\\w+\n" *
							"$p --with-branding=browser/branding/\\w+\n",
							"$p --with-app-name=snowfox\n" *
							"$p --enable-update-channel=release\n" *
							"$p --with-branding=browser/branding/snowfox\n", "e") # ~ do not sort this
						p = "mk_add_options"
						s = replace(s,
							"$p MOZ_CRASHREPORTER=0\n" *
							"$p MOZ_DATA_REPORTING=0\n" *
							#	MOZ_NORMANDY=0
							"$p MOZ_SERVICES_HEALTHREPORT=0\n" *
							"$p MOZ_TELEMETRY_REPORTING=0\n", # ~ do not sort this
							"$p MOZ_CRASHREPORTER=0\n" *
							"$p MOZ_DATA_REPORTING=0\n" *
							"$p MOZ_SERVICES_HEALTHREPORT=0\n" *
							"$p MOZ_TELEMETRY_REPORTING=0\n", "p", n = 1)
						s = replace(s, "com.0h7z.snowfox" => s"com.0h7z")
						s = replace(s, r"^export MOZ_REQUIRE_SIGNING=\K1?$"m, '"'^2)
					end
					if (f ≡ "Makefile") || endswith(".mk")(f)
						p = raw"${version}-${release}"
						s = replace(s, ("\\bsource archive \\K(\\Q$p.\\E)"), s"v\1")
						s = replace(s, r"@echo \"Firefox version\K  ( : \")", s"\1")
						s = replace(s, r"^archive_create\K:=tar cfz$"m, ":=tar fca")
						s = replace(s, r"^ext\K:=\.tar\.gz$"m, (":=.tar.zst"))
						s = replace(s,
							"""	mv \$(ff_source_dir) \$(sf_source_dir)\n""" *
							"""	python3 scripts/snowfox-patches.py \$(version) \$(release)\n""",
							"""	mv \$(ff_source_dir) \$(sf_source_dir)\n""" *
							"""	cp \$(sf_source_dir)/devtools/client/themes/images/aboutdebugging-firefox-logo.svg""" *
							"" * " \$(sf_source_dir)/browser/themes/shared/preferences/category-snowfox.svg\n" *
							"""	python3 scripts/snowfox-patches.py \$(version) \$(release)\n""", "p") # ~ do not sort this
					end
					if (f ≡ "aboutDialog.css")
						s = replace(s, r"url\(\"data:[^\"]+\"\);" => "url(\"chrome://branding/content/about-logo.svg\");")
						s = replace(s,
							"""#aboutDialog {\n""" *
							"""	border-bottom: #00acff 2px solid;\n""" *
							"""}\n""",
							"""#aboutDialog {\n""" *
							"""	border-bottom: #1d1133 2px solid;\n""" *
							"""	line-height: 1.5;\n""" *
							"""}\n""" * """\n""" *
							"""#grid {\n""" *
							"""	background-color: #20123a;\n""" *
							"""	color: #ffffff;\n""" *
							"""	color-scheme: dark;\n""" *
							"""}\n""" * """\n""" *
							""".text-link {\n""" *
							"""	color: #00ddff !important;\n""" *
							"""	text-decoration: none;\n""" *
							"""}\n""", "p") # ~ do not sort this
					end
					if (f ≡ "aboutDialog.js")
						p = "api.github.com"
						p = replace(website, ("/github.com/" => "/$p/repos/")) * ("/releases")
						s = replace(s, "https://gitlab.com/api/v4/projects/32320088/releases" => p)
						s = replace(s, r" = \K(?=AppConstants\.MOZ_APP_VERSION_DISPLAY)", "'v' + ")
						s = replace(s, r"\.\_links\.self\b", ".html_url")
						s = replace(s, r"Release = \K\"0\"", "\"1\"")
					end
					if (f ≡ "aboutDialog.xhtml")
						s = replace(s, r" with the primary\s+goals of privacy, security\K( and user freedom\.)"s, s",\1")
						s = replace(s, r"""href=\K"(https://librewolf.net)/?">\1/?</""", "\"$website\">$website</")
					end
					if (f ≡ "allow_dark_preference_with_rfp.patch")
						s = replace(s, "return ColorScheme::Light;" => "return ColorScheme::Dark;")
						s = replace(s, r"^ +\Kvalue: false"m => "value: true")
					end
					if (f ≡ "brand.ftl" || f ≡ "brand.properties")
						s = replace(s, "Firefox Developer Edition", "Snowfox", "w")
						s = replace(s, r"\b(?:Mozilla )?Firefox\b", "Snowfox", "e")
						s = replace(s, r"Snowfox\K( and Mozilla)", s", Firefox,\1")
						s = replace(s, r"trademarkInfo = \K\{ \" \" \}", (moz_tmk))
						s = replace(s, r"trademarkInfo = \KSnowfox.+"im, (moz_tmk))
						s = replace(s, r"vendor-short-name = \KMozilla", "Snowfox")
						s = replace(s, r"(Snowfox, )\1(?=and Moz)", s"\1Firefox, ") # ~ do not move this
					end
					if (f ≡ "branding.nsi")
						s = replace(s, "!define Channel \"aurora\"" => "!define Channel \"release\"")
						s = replace(s, "(Firefox )?Developer Edition", "Snowfox")
						s = replace(s, "\"https://support.mozilla.org\"" => "\"$website\"")
						s = replace(s, "\"https://www.mozilla.org\"" => "\"$(splitdir(website)[1])\"")
						s = replace(s, "\"mozilla.org\"" => "\"0h7z.com\"")
						s = replace(s, r"^!(?=\w+ BrandShortName)"m => "#") # ~ must not set if !DEV_EDITION
						s = replace(s, r"^(?=!define DEV_EDITION)"m => "#")
						s = replace(s, r"FONT_SIZE 28\b" => "FONT_SIZE 42")
						s = replace(s, r"https://download\.mozilla\.org/[^\"]+", "$website/releases/latest")
						s = replace(s, r"https://www\.mozilla\.org/\$[^\"]+", "$website/releases/latest")
						s = replace(s, r"https://www\.mozilla\.org/firefox/[^\"]*", "$website")
					end
					if (f ≡ "configure.sh")
						s = replace(s, r"^MOZ_APP_DISPLAYNAME=\K.*$"m => "Snowfox")
						s = replace(s, r"^MOZ_APP_PROFILE=\K.*$"m => "Snowfox")
						s = replace(s, r"^MOZ_APP_REMOTINGNAME=\K.*$"m => "snowfox")
						s = replace(s,
							"MOZ_APP_DISPLAYNAME=[^\n]*\n" *
							"MOZ_APP_REMOTINGNAME=[^\n]*\n" *
							"MOZ_DEV_EDITION=[^\n]*\n", # ~ do not sort this
							"MOZ_APP_BASENAME=Snowfox\n" *
							"MOZ_APP_DISPLAYNAME=Snowfox\n" *
							"MOZ_APP_NAME=snowfox\n" *
							"MOZ_APP_PROFILE=Snowfox\n" *
							"MOZ_APP_REMOTINGNAME=snowfox\n" *
							"MOZ_APP_VENDOR=0h7z\n" *
							"MOZ_MACBUNDLE_NAME=Snowfox.app\n", "e")
					end
					if (f ≡ "generate-locales.sh")
						p = "  " * "find browser/locales/l10n/\$1 -type f -exec sed -i"
						q = "{} \\;\n"
						s = replace(s,
							"$p -e 's/Mozilla Firefox/Snowfox/g' $q" *
							"$p -e 's/Mozilla/Snowfox/g' $q" *
							"$p -e 's/Firefox/Snowfox/g' $q", # ~ do not sort this
							#
							"$p -e 's/Firefox and Mozilla/Snowfox, Firefox, and Mozilla/g' $q" *
							"$p -e 's/Firefox/Snowfox/g' $q" *
							"$p -e 's/Snowfox Account/Firefox Account/g' $q" *             # 2
							"$p -e 's/Snowfox Color/Firefox Color/g' $q" *                 # 2
							"$p -e 's/Snowfox Focus/Firefox Focus/g' $q" *                 # 2
							"$p -e 's/Snowfox Health Report/Firefox Health Report/g' $q" * # 2
							# "$p -e 's/Snowfox Home/Firefox Home/g' $q" *                   # -1
							"$p -e 's/Snowfox Lockwise/Firefox Lockwise/g' $q" *           # 2
							"$p -e 's/Snowfox Monitor/Firefox Monitor/g' $q" *             # 2
							"$p -e 's/Snowfox Nightly/Firefox Nightly/g' $q" *             # 1
							"$p -e 's/Snowfox Profiler/Firefox Profiler/g' $q" *           # 1
							"$p -e 's/Snowfox Relay/Firefox Relay/g' $q" *                 # 2
							# "$p -e 's/Snowfox Screenshots/Firefox Screenshots/g' $q" *     # -1
							"$p -e 's/Snowfox Send/Firefox Send/g' $q" *                   # 2
							"$p -e 's/Snowfox Translations/Firefox Translations/g' $q" *   # 2
							# "$p -e 's/Snowfox View/Firefox View/g' $q" *                   # -2
							#
							"$p -e 's/\"Fire\" in \"Snowfox\"/\"Fire\" in \"Firefox\"/g' $q" *
							"$p -e 's/DisableSnowfox/DisableFirefox/g' $q" *
							"$p -e 's/mozilla.org\\/Snowfox/mozilla.org\\/Firefox/g' $q" *
							"$p -e 's/prefSnowfox/prefFirefox/g' $q" *
							"$p -e 's/shareSnowfox/shareFirefox/g' $q" *
							"$p -e 's/SnowfoxHome/FirefoxHome/g' $q" *
							"$p -r 's/(MozillaMaintenanceDescription\\s*=.*)Mozilla Snowfox/\\1Mozilla Firefox/g' $q" *
							"$p -r 's/(MozillaMaintenanceDescription\\s*=.*)Snowfox/\\1Firefox/g' $q" *
							"$p -r 's/(trademarkInfo)\\s*=.*Snowfox.*/\\1 = $moz_tmk/g' $q" *
							"$p -z -r 's/(import-from-firefox\\s*=\\s*\\.label\\s*=\\s*)Snowfox/\\1Firefox/g' $q" *
							#
							"$p -e 's/Mozilla Snowfox/Snowfox/g' $q", "p")
						s = replace(s, r"^N=8$"m => raw"N=`[[ $(nproc) -ge 8 ]] && nproc || echo 8`")
					end
					if (f ≡ "patches.txt")
						for p ∈ patches
							s = replace(s, ("^\\Q$p\\E\n", "m"), "")
						end
						p = "../" * "164283e1448523a73f98587a38ac296fe8bf3918.patch" * "\n" *
							"patches/removed-patches/allow_dark_preference_with_rfp.patch" * "\n"
						s = replace(s * p, p * p, p, "p")
					end
					if (f ≡ "policies.json")
						s = replace(s, "https://gitlab.com/librewolf-community/settings/issues", "$website/issues")
						s = replace(s, # Cookies
							"""		"AppUpdateURL": "https://localhost",\n""" *
							"""		"DisableAppUpdate": true,\n""",
							"""		"AppUpdateURL": "https://localhost",\n""" *
							"""		"Cookies": {\n""" *
							"""			"Allow": [\n""" *
							"""				"https://librewolf.net",\n""" *
							"""				"https://localhost"\n""" *
							"""			],\n""" *
							"""			"Behavior": "reject-tracker-and-partition-foreign",\n""" *
							"""			"Locked": true\n""" *
							"""		},\n""" *
							"""		"EncryptedMediaExtensions": {\n""" *
							"""			"Enabled": false,\n""" *
							"""			"Locked": false\n""" *
							"""		},\n""" *
							"""		"DisableAppUpdate": true,\n""", "p") # ~ do not sort this
						s = replace(s, # Extensions
							"""			"Uninstall": [\n""" *
							"""				"google@search.mozilla.org",\n""" *
							"""				"bing@search.mozilla.org",\n""" *
							"""				"amazondotcom@search.mozilla.org",\n""" *
							"""				"ebay@search.mozilla.org",\n""" *
							"""				"twitter@search.mozilla.org"\n""" *
							"""			]\n""", # ~ do not sort this
							"""			"Uninstall": []\n""", "p")
						s = replace(s, # SearchEngines
							"""			"Remove": [\n""" *
							"""				"Google",\n""" *
							"""				"Bing",\n""" *
							"""				"Amazon.com",\n""" *
							"""				"eBay",\n""" *
							"""				"Twitter"\n""" *
							"""			],\n""", # ~ do not sort this
							"""			"Remove": [],\n""", "p")
						s = replace(s, # SearchEngines
							"""			"Default": "DuckDuckGo",\n""" *
							"""			"Add": [\n""" * """[\\S\\s]+?\n""" *
							"""			]\n""",
							"""			"Default": "Duckduckgo",\n""" *
							"""			"Add": []\n""", "e") # ~ do not sort this
						s = replace(s, # SearchEngines
							"""			"Default": "Duckduckgo",\n""" *
							"""			"Add": []\n""",
							"""			"Default": "Duckduckgo",\n""" *
							"""			"Add": [\n""" *
							"""				{\n""" *
							"""					"Name": "Google",\n""" *
							"""					"Description": "Search Google",\n""" *
							"""					"Alias": "@goog",\n""" *
							"""					"Method": "GET",\n""" *
							"""					"URLTemplate": "https://www.google.com/search?hl=en&newwindow=1&q={searchTerms}",\n""" *
							"""					"SuggestURLTemplate": "https://www.google.com/complete/search?q={searchTerms}",\n""" *
							"""					"IconURL": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAFZUlEQVRYR71XDUyUdRj/vXdyBwfHyYeKimlEIYSDpCI/ckxWWNmX9qG2liaZpUtNc7SGZk6TOTdZthXoXE601mZbLWe6cIvBMChkls0MkJwf+I1yx3Fw9/b7v7738r7HwR2M9b89d++9/+f5Pb//8zz/LwlhNlmWY6k61+fzzZYkKYvPKRS7an6bvy3UaTSZTD/z+UfqiHchmxRKg6BpdFpEwAWUyFD6op82nZSDJLONNmcHsumXAAFsdLyZAKso5nAcB+oQo4eyk0Q2EKMzGEZQAjR6gPIdjTKG4jgIkVPEmkf5J7CvDwE6nkr5icqJgcreSxfQdfwouhvq0dPaDF/7LRFvmGIdME9MgSVrKqz5c2AeP6EPb2JeJeaTlJP6TgMBdeTVgc69ly/CWfYZuqoqFYcDNkmCdUYeopevgjlpnEFVJTFdHwmNADujKb8Ght197DA6Sksgu4OmsF8uUpQN9rUfwZr3RCAJkY5cf01oBLxe7w4Wy/t6bdfXX8G5+/Mhl0FkwVzYP9jQx57Fvd1sNq8XHQoBMdUof+qrXYz8TsnHQZ2PSEmF5dHpMI8dTwQJ3osX4KmrQU9T74yLfOZF2FcXKf3BZgd9pYtUKL0c/V6OfrFfURTbzcKFkLvcBlvhMIaglpzcoMQ89bW4s2MLrDPzELNi7YCRYxT2MAqFEkfuoFzWLzLO0vfg+qHWABCRngnH1lJIdv/iFxxfdjkh2aJDpo0+XfSZJAgsonaF30LubIa3KgOuyrHoqh+lvDbFJyCu/ABMjriQwINUWCAx/LsZ/qV+Q9+5T+Fr2qj89fw1Eq7DExGzaiNEQQ13YxrKJH7VMRQPa/n/vQDyzeOaL9/tZFie/RsYMWK4/YviPyEIXCeBeD96TxVXMU+b5kwa8xLMmQf6dZ6/1Rk2seIXrMjL6B2IsjCRgIcEIjQCldzwZJ8GappUBNN9nwwLgaV5FiyarrkSEfD8rwRenxmBxbMs2mD8BK4xAgn9pmD0fJinHByWCCzPt+DlXEMElBQYi7BhDuQb3HTU1mZJx+gZvyHCNLgibLnqQ2G5cf/YOM+KWZMNNXAiyDQs4TQsVtwf6UpGyZ0srHtkJZ5PyQ+72ITiN7XdKKv0GGwqVtiQ5OhdmpVpyDwspJZW5nLnObhrMrCzIwOH3JMUgPhIBw4U7EBC5MiwSHS4ZSz5shM3nL1b9z2JJuxdFhVo/6ogEKsuxVrvztrNqGhtNChPjkvBrrxiOCwDL8XdXqD4Wzfqmvmga28z/68Y8y+W4jH+zWgPV8M3/fqXnFex4MgauHqMm1GSLRHrc97C4+Nygkbi7K1WlPxSi5Y/nmJ/7zEyPlrCvneiEGUxhL+cm9Ey/3Z8P6Nwmoy0CjnSWoXi2tKgjibFjse0pIcwISaJu62EK53X0XDlNBqvnYHMj9mdClvbSkg9d/eOTfMjMTOtlxB9davbcZP+QLKdUVin97j/zPcoPbkvrLwHKkleO6La3sWSnCzD3Bd6LL5tHP2H4ll/JLMpa7MkZerBjv5bjS11XzAdgzuSmXmSL0x/DYVTnjNwE5cX+niMouQ38FCaSoUadt7dh9V22XUNuxr349j5avhCHUppkzP6QazOfgOicPWN2G3EFofSZv/7YMfybCoeDSQhDERxChJ1bafQ1H4eN7valUOyw2rHRPs4ZI+ajPzkaUiLu7dP2lTnBcQ1TK/+LiYiEoeoPGVIBRBgpIZdXEy0kfcbAX8HjaJYLJtotEY/OwZDSFQ7RZy2BY5xTqtA4VxOU9XL6UKC2MIhIM57lAo6LqFN00A2IQnoIiKWwKcDrucOtb+dv80i1Or1/DAdd4RD9j/w5nJL3xmBhgAAAABJRU5ErkJggg=="\n""" *
							"""				}\n""" *
							"""			]\n""", "p") # ~ do not sort this
					end
					if (f ≡ "search-config.json")
						s = cd(@__DIR__) do
							read(f, String)
						end
					end
					if (f ≡ "snowfox-pref-pane.patch")
						p = "browser/themes/shared/preferences/category-librewolf.svg"
						p = "diff --git a/$p b/$p"
						s = replace(s,
							"$p\n[^+-]+\n" * "--- [^\n]+\n" * "\\+\\+\\+ [^\n]+\n" *
							"@@[^\n]+@@\n" * "(\\+[^\n]*\n)+", "", "e")
					end
					if (f ≡ "snowfox.cfg")
						s = replace(s, "(?<!\b)'|'(?!\b)", "\"")
						s = replace(s, "\n //", "\n//") * ("\n")
						s = replace(s, "what\"s", "what's", "w")
						s = replace(s, ("\"none\""), ("'none'"))
						s = replace(s, ("https://dns.quad9.net/dns-query"), ("https://cloudflare-dns.com/dns-query"), "w")
						for p ∈ [
							"""("devtools.selfxss.count", 0)"""         => """("devtools.selfxss.count", 5)""", # 0
							"""("privacy.userContext.enabled", true)""" => """("privacy.userContext.enabled", false)""", # false
							#
							r"""\(("privacy\.query_stripping\.strip_list"), "[^"]+"\)""" => s"""(\1, "@@QUERY_STRIP_LIST@@")""", # ""
							r"""\(("security\.ssl\.require_safe_negotiation"), true\)""" => s"""(\1, false)""", # false
							r"@@QUERY_STRIP_LIST@@" => join(strip_list, " "),
						]
							s = replace(s, p)
						end
						for p ∈ [
							"app.releaseNotesURL.aboutDialog" => "$website/releases",
							"app.releaseNotesURL"             => "$website/releases",
							"app.update.url.details"          => "$website/releases/latest",
							"app.update.url.manual"           => "$website/releases/latest",
						]
							s = replace(s,
								"""("$(p[1])", "https://gitlab.com/librewolf-community/browser")""",
								"""("$(p[1])", "$(p[2])")""", "p")
						end
						s = replace(s, r"^\n*"s => "\n"^2)
						s = replace(s, r"let profile_directory;.+;\n\}\K.*$"s,
							"""\n"""^2 *
							"""defaultPref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");\n""" *
							"""defaultPref("intl.date_time.pattern_override.connector_short", "{1} {0}");\n""" *
							"""defaultPref("intl.date_time.pattern_override.date_full", "yyyy-MM-dd DDD");\n""" *
							"""defaultPref("intl.date_time.pattern_override.date_long", "yyyy-MM-dd DDD");\n""" *
							"""defaultPref("intl.date_time.pattern_override.date_medium", "yyyy-MM-dd");\n""" *
							"""defaultPref("intl.date_time.pattern_override.date_short", "yyyy-DDD");\n""" *
							"""defaultPref("intl.date_time.pattern_override.time_full", "HH:mm:ss.SSS XXX");\n""" *
							"""defaultPref("intl.date_time.pattern_override.time_long", "HH:mm:ss XXX");\n""" *
							"""defaultPref("intl.date_time.pattern_override.time_medium", "HH:mm:ss XXX");\n""" *
							"""defaultPref("intl.date_time.pattern_override.time_short", "HH:mm:ss");\n""" *
							"""defaultPref("snowfox.app.checkVersion.enabled", false);\n""" *
							"""lockPref("browser.firefox-view.view-count", 0);\n""" *
							"""lockPref("privacy.donottrackheader.enabled", true);\n""" *
							"""\n"""^2, "p", n = 1) # ~ do not move this
					end
					if (f ≡ "uBOAssets.json")
						s = replace(s, "\t", " "^2)
						s = replace(s, r"^\t*\K {2}"m, ("\t"))
					end
					if (f ≡ "website-appearance-ui-rfp.patch")
						p = """+      document.getElementById("web-appearance-chooser").style"""
						s = replace(s, ("@@ -3771,5 +3773,33 @@") => ("@@ -3771,5 +3773,32 @@"))
						s = replace(s, ("^\\Q$p.opacity\\E.+;\n", "m"), (""))
						s = replace(s, ("^\\Q$p.pointerEvents\\E.+;\n", "m"), (""))
						s = replace(s,
							""" feature is disabled """,
							""" setting is not taking effect """, "p")
						s = replace(s,
							""" will force web content """,
							""" will continue to force web content """, "p")
						s = replace(s,
							""" theme.";""",
							""" theme, unless privacy.resistFingerprinting.override-color-scheme is set to true.";""", "p")
						s = replace(s,
							"""+    if (Services.prefs.getBoolPref("privacy.resistFingerprinting")) {\n""",
							"""+    if (Services.prefs.getBoolPref("privacy.resistFingerprinting") &&\n""" *
							"""+       !Services.prefs.getBoolPref("privacy.resistFingerprinting.override-color-scheme")) {\n""" *
							"""+      document.getElementById("web-appearance-rfp-warning")?.remove();\n""", "p")
						s = replace(s,
							"""+      learnMore.innerText = "Learn more";\n""" *
							"""+      infoBox.appendChild(learnMore);\n""",
							"""+      learnMore.innerText = "Learn more";\n""" *
							"""+      learnMore.target = "_blank";\n""" *
							"""+      infoBox.appendChild(learnMore);\n""", "p")
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

