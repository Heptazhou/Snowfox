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

const zst_cmd = "zstd -17 -M1024M -T$(Sys.CPU_THREADS) --long"
const url_git = "https://github.com/0h7z/Snowfox"
const url_doc = "https://0h7z.com/snowfox/"
const url_api = "https://api.github.com/repos/0h7z/Snowfox"
const patch_g =
	[
		"../" * "4868d3a3dbc3219372a2a09a53e1230fe1807a04.patch"
		"patches/removed-patches/allow_dark_preference_with_rfp.patch"
	]
const patch_b =
	[
		"patches/allow-JXL-in-non-nightly-browser.patch"
		"patches/mozilla_dirs.patch"
		"patches/rfp-performance-api.patch"
		"patches/ui-patches/hide-default-browser.patch"
		"patches/ui-patches/pref-naming.patch"
		"patches/ui-patches/privacy-preferences.patch"
		"patches/ui-patches/remap-links.patch"
		"patches/ui-patches/remove-branding-urlbar.patch"
		"patches/ui-patches/remove-cfrprefs.patch"
		"patches/ui-patches/snowfox-logo-devtools.patch"
		"patches/unified-extensions-dont-show-recommendations.patch"
	]
const moz_tmk = "Firefox and the Firefox logos are trademarks of the Mozilla Foundation."

function update(dir::String, recursive::Bool = SUBMODULES)
	@info dir recursive
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = false)
		occursin(prefix)(r"\.git\b") && continue
		occursin(prefix)(r"\bsubmodules\b") && !recursive && continue
		cd(prefix) do
			for f ∈ fs
				if (f ∈ patch_b .|> basename)
					rm(f)
					continue
				end
				if (f ≠ ".git") && !endswith(".jl")(f) && !isbinary(f)
					s = read(f, String)
					if endswith(r"\.(diff|patch)")(f)
						s = replace(s, " [ab]/browser/components/BrowserGlue\\K\\.jsm", ".sys.mjs")
						s = replace(s, " [ab]\\K/lw/", "/snowfox/")
						s = replace(s, r"^diff --git .+?\K\blibrewolf\b"m, "snowfox")
						for p ∈ schemes
							s = replace(s -> startswith(s, '+') ? replace(s, p...) : s, split(s, '\n')) |> s -> join(s, '\n')
						end
					else
						for p ∈ schemes
							s = replace(s, p...)
						end
					end
					s = replace(s, "\r\n" => "\n")
					s = replace(s, r"^.*\bEXTRA_PATH.*\n"m => "")
					s = replace(s, r"^.*\bLOWERCASE_.*\n"m => "")
					s = replace(s, r"^.*liblowercase.*\n"m => "")
					s = replace(s, r"https://\Kraw\.(github)usercontent(\.com/[^/]+/[^/]+)/", s"\1\2/raw/")
					s = replace(s, r"https://\Ksnowfox(\.net)", s"librewolf\1")
					s = replace(s, r"https://gitlab\.com/\Ksnowfox(-community)", s"librewolf\1")
					s = replace(s, r"https://gitlab\.com/librewolf-community/\S*?\Ksnowfox"i, s"librewolf")
					s = replace(s, r"https://librewolf\.net/\S*?\Ksnowfox"i, s"librewolf")
					s = replace(s, r"WINDOWSSDKDIR=\"(\$MOZBUILD/win-cross/vs).*?\"", s"WINSYSROOT=\"\1\"")
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
					s = replace(s, "wget -qO", "curl -Lo", "w")
					s = replace(s, "www.snowfox.gitlab.io", "github.com/0h7z", "w")
					if f ∈ ("appstrings.properties", "snowfox.cfg")
						s = expands(s)
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
						s = replace(s, r"_create:=tar\K cfz$"m, " Ifc \"$zst_cmd\"")
						s = replace(s, r"@echo \"Firefox version\K  ( : \")", s"\1")
						s = replace(s, r"^ext:=\.tar\K\.gz$"m, ".zst")
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
						p = "$url_api/releases"
						s = replace(s, "\"(Up to date)\"" => "\"(up to date)\"")
						s = replace(s, "\"(Update available)\"" => "\"(update available)\"")
						s = replace(s, "https://gitlab.com/api/v4/projects/32320088/releases" => p)
						s = replace(s, r" = \K(?=AppConstants\.MOZ_APP_VERSION_DISPLAY)", "'v' + ")
						s = replace(s, r"\.\_links\.self\b", ".html_url")
						s = replace(s, r"Release = \K\"0\"", "\"1\"")
						p = """Number(oldVersion?.split(".")[i] || "0")"""
						q = """Number(newVersion.split(".")[i])"""
						s = replace(s,
							"""{\n""" *
							"""	"""^5 * """if ($q > $p) return true;\n""",
							"""{\n""" *
							"""	"""^5 * """if ($q < $p) return false;\n""" *
							"""	"""^5 * """if ($q > $p) return true;\n""", "p") # ~ do not sort this
					end
					if (f ≡ "aboutDialog.xhtml")
						s = replace(s, r"""href=\K"(https://librewolf.net)/?">\1/?</""", "\"$url_git\">$url_git</")
						s = replace(s, r"the primary\s+goals of privacy, security\K( and user freedom\.)"s, s",\1")
					end
					if (f ≡ "allow_dark_preference_with_rfp.patch")
						s = replace(s, "return ColorScheme::Light;" => "return ColorScheme::Dark;")
						s = replace(s, r"^ +\Kvalue: false"m => "value: true")
					end
					if (f ≡ "bootstrap-without-vcs.patch")
						p = "third_party/python/mozilla_repo_urls/mozilla_repo_urls/parser.py"
						s = replace(s, "--- a/$p\n+++ b/$p\n" * r"[\S\s]+?\n" * "---" => "---")
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
						s = replace(s, "\"https://support.mozilla.org\"" => "\"$url_git\"")
						s = replace(s, "\"https://www.mozilla.org\"" => "\"$(splitdir(url_git)[1])\"")
						s = replace(s, "\"mozilla.org\"" => "\"0h7z.com\"")
						s = replace(s, r"^!(?=\w+ BrandShortName)"m => "#") # ~ must not set if !DEV_EDITION
						s = replace(s, r"^(?=!define DEV_EDITION)"m => "#")
						s = replace(s, r"FONT_SIZE 28\b" => "FONT_SIZE 42")
						s = replace(s, r"https://download\.mozilla\.org/[^\"]+", "$url_git/releases")
						s = replace(s, r"https://www\.mozilla\.org/\$[^\"]+", "$url_git/releases")
						s = replace(s, r"https://www\.mozilla\.org/firefox/[^\"]*", "$url_git")
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
					if (f ≡ "firefox-view.patch")
						s = replace(s,
							"""   },\n""" *
							""" \n""" *
							"""   _updateForNewProtonVersion() {\n""",
							""" \n""" *
							"""     // Unified Extensions addon button migration, which puts any browser action\n""" *
							"""     // buttons in the overflow menu into the addons panel instead.\n""", "p")
					end
					if (f ≡ "generate-locales.sh")
						p = "  " * "find browser/locales/l10n/\$1 -type f -exec sed -i"
						q = "{} \\;\n"
						s = replace(s,
							"$p -e 's/Mozilla Firefox/Snowfox/g' $q" *
							"$p -e 's/Mozilla/Snowfox/g' $q" *
							"$p -e 's/Firefox/Snowfox/g' $q", # ~ do not sort this
							"$p -e 's/Firefox/Snowfox/g' $q" *
							"$p -e 's/Snowfox and Mozilla/Snowfox, Firefox, and Mozilla/g' $q" *
							#
							# "$p -e 's/Snowfox account/Firefox account/g' $q" * #
							# "$p -e 's/Snowfox Account/Firefox Account/g' $q" * #
							"$p -e 's/Snowfox Color/Firefox Color/g' $q" *
							"$p -e 's/Snowfox Focus/Firefox Focus/g' $q" *
							"$p -e 's/Snowfox Health Report/Firefox Health Report/g' $q" *
							# "$p -e 's/Snowfox Home/Firefox Home/g' $q" * #
							"$p -e 's/Snowfox Lockwise/Firefox Lockwise/g' $q" *
							"$p -e 's/Snowfox Monitor/Firefox Monitor/g' $q" *
							"$p -e 's/Snowfox Nightly/Firefox Nightly/g' $q" *
							"$p -e 's/Snowfox Profiler/Firefox Profiler/g' $q" *
							"$p -e 's/Snowfox Relay/Firefox Relay/g' $q" *
							# "$p -e 's/Snowfox Screenshot/Firefox Screenshot/g' $q" * #
							"$p -e 's/Snowfox Send/Firefox Send/g' $q" *
							# "$p -e 's/Snowfox Suggest/Firefox Suggest/g' $q" * #
							"$p -e 's/Snowfox Translation/Firefox Translation/g' $q" *
							# "$p -e 's/Snowfox View/Firefox View/g' $q" * #
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
						for p ∈ patch_g
							s = occursin(p, s) ? s : s * p * "\n"
						end
						for p ∈ patch_b
							s = replace(s, r"^"m * p * "\n", s"")
						end
					end
					if (f ≡ "policies.json")
						p, q = "$url_git/issues", "q={searchTerms}"
						p = replace(p, "0h7z" => "Heptazhou")
						s = replace(s, "https://gitlab.com/librewolf-community/settings/issues", p)
						s = replace(s, # Cookies
							"""		"AppUpdateURL": "https://localhost",\n""" *
							"""		"DisableAppUpdate": true,\n""",
							"""		"AppUpdateURL": "https://localhost",\n""" *
							"""		"Cookies": {\n""" *
							"""			"Allow": [\n""" *
							"""				"https://example.com",\n""" *
							"""				"https://localhost"\n""" *
							"""			],\n""" *
							"""			"Behavior": "reject-tracker-and-partition-foreign",\n""" *
							"""			"Locked": false\n""" *
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
							"""					"URLTemplate": "https://www.google.com/search?hl=en&newwindow=1&$q",\n""" *
							"""					"SuggestURLTemplate": "https://www.google.com/complete/search?$q",\n""" *
							"""					"IconURL": "$icon_goog"\n""" *
							"""				}\n""" *
							"""			]\n""", "p") # ~ do not sort this
					end
					if (f ≡ "search-config.json")
						s = cd(@__DIR__) do
							read(f, String)
						end
					end
					if (f ≡ "snowfox-patches.py")
						s = cd(@__DIR__) do
							!isfile("binary.patch") ? s :
							replace(s,
								"""	patch('../patches/xmas.patch')\n""" * "\n",
								"""	patch('../patches/xmas.patch')\n""" *
								"""	os.system('git apply -v --directory=snowfox-v{}-{} ../../binary.patch'""" *
								""".format(version, release)) == 0 or script_exit(1)\n""" * "\n", "p")
						end
					end
					if (f ≡ "snowfox-pref-pane.patch")
						p = "fxa/fxa-spinner.svg"
						s = replace(s, "spotlight.css", p, "w")
						s = replace(s, "$p$(' '^27)(" => "$p$(' '^21)(")
						p = "fxa/sync-illustration.svg"
						s = replace(s, "upgradeDialog/abstract.png", p, "w")
						s = replace(s, "$p$(' '^14)(" => "$p$(' '^15)(")
						p = "fxa/sync-illustration-issue.svg"
						s = replace(s, "upgradeDialog/cheers.png", p, "w")
						s = replace(s, "$p$(' '^16)(" => "$p$(' '^09)(")
						p = "browser/themes/shared/preferences/category-snowfox.svg"
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
							"""("browser.download.alwaysOpenPanel", false)""" => """("browser.download.alwaysOpenPanel", true)""",
							"""("browser.download.useDownloadDir", false)"""  => """("browser.download.useDownloadDir", true)""",
							"""("devtools.selfxss.count", 0)"""               => """("devtools.selfxss.count", 5)""", # 0
							"""("privacy.userContext.enabled", true)"""       => """("privacy.userContext.enabled", false)""",
							"""("webgl.disabled", true)"""                    => """("webgl.disabled", false)""",
							#
							r"""\(("privacy\.query_stripping\.strip_list"), "[^"]+"\)""" => s"""(\1, "@@STRIP_LIST@@")""", # ""
							r"""\(("security\.ssl\.require_safe_negotiation"), true\)""" => s"""(\1, false)""",
							r"@@STRIP_LIST@@" => join(strip_list, " "),
						]
							s = replace(s, p)
						end
						for p ∈ [
							"app.releaseNotesURL.aboutDialog" => "$url_doc#v%VERSION%",
							"app.releaseNotesURL"             => "$url_doc#v%VERSION%",
							"app.update.url.details"          => "$url_git/releases",
							"app.update.url.manual"           => "$url_git/releases",
						]
							s = replace(s,
								"""("$(p[1])", "https://gitlab.com/librewolf-community/browser")""",
								"""("$(p[1])", "$(p[2])")""", "p")
						end
						for p ∈ [
							"app.feedback.baseURL"                # https://ideas.mozilla.org/
							"app.support.baseURL"                 # https://support.mozilla.org/1/firefox/%VERSION%/%OS%/%LOCALE%/
							"browser.geolocation.warning.infoURL" # https://www.mozilla.org/%LOCALE%/firefox/geolocation/
							"browser.search.searchEnginesURL"     # https://addons.mozilla.org/%LOCALE%/firefox/search-engines/
						]
							s = replace(s, (r"^.*\b"m * p * r"\b.*\n"m) => "")
						end
						s = replace(s, r"^\n*"s => "\n"^2)
						s = replace(s, r"let profile_directory;.+;\n\}\K.*$"s,
							"""\n"""^2 *
							"""defaultPref("devtools.performance.new-panel-onboarding", false);\n""" *
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
							"""defaultPref("network.http.useragent.forceVersion", $UAV);\n""" *
							"""defaultPref("snowfox.app.checkVersion.enabled", true);\n""" *
							"""defaultPref("snowfox.app.checkVersion.url", "$url_api/releases");\n""" *
							"""lockPref("browser.dataFeatureRecommendations.enabled", false);\n""" *
							"""lockPref("browser.firefox-view.view-count", 0);\n""" *
							"""lockPref("browser.privacySegmentation.createdShortcut", true);\n""" *
							"""lockPref("browser.privacySegmentation.preferences.show", false);\n""" *
							"""pref("network.http.useragent.forceVersion", $UAV);\n""" *
							"""pref("privacy.donottrackheader.enabled", true);\n""" *
							"""pref("security.OCSP.require", true);\n""" *
							"""pref("security.pki.crlite_mode", 2);\n""" *
							"""\n"""^2, "p", n = 1)
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

