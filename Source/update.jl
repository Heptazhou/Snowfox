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

include("base_func.jl")

using Dates: Year, datetime2unix, now

const zst_cmd = "zstdmt -18 -M1024M --long"
const url_git = "https://github.com/0h7z/Snowfox"
const url_doh = "https://cloudflare-dns.com/dns-query" # https://mozilla.cloudflare-dns.com/dns-query
const url_doc = "https://0h7z.com/en/snowfox/"
const url_api = "https://api.github.com/repos/0h7z/Snowfox"
const patch_g =
	[
		"../" * "$(string(:v, VER.major)).patch"
		"../" * "crlf.patch" * " --binary"
		"../" * "font.patch"
		"../" * "typo.patch"
	]
const patch_b =
	[
		"patches/1550_1549.diff"
		"patches/allow-JXL-in-non-nightly-browser.patch"
		"patches/bootstrap-without-vcs.patch"
		"patches/bootstrap.patch"
		"patches/dbus_name.patch"
		"patches/encoding_rs.patch"
		"patches/flatpak-autoconf.patch"
		"patches/fullpage-translations-customization.patch"
		"patches/fullpage-translations.patch"
		"patches/JXL_enable_by_default.patch"
		"patches/JXL_improved_support.patch"
		"patches/mozilla_dirs.patch"
		"patches/msix.patch"
		"patches/removed-patches/about-dialog.patch"
		"patches/removed-patches/add-language-warning.patch"
		"patches/removed-patches/allow_dark_preference_with_rfp.patch"
		"patches/removed-patches/megabar.patch"
		"patches/removed-patches/mozilla-vpn-ad.patch"
		"patches/removed-patches/mozilla-vpn-ad2.patch"
		"patches/removed-patches/native-messaging-registry-path.patch"
		"patches/removed-patches/sanitizing-description.patch"
		"patches/rust-gentoo-musl.patch"
		"patches/rust-unaligned-access-backport.patch"
		"patches/sed-patches/allow-searchengines-non-esr.patch"
		"patches/sed-patches/stop-undesired-requests.patch"
		"patches/tumbleweed-bootstrap.patch"
		"patches/ui-patches/allow_cookies_for_site.patch"
		"patches/ui-patches/firefox-view.patch"
		"patches/ui-patches/hide-default-browser.patch"
		"patches/ui-patches/pref-naming.patch"
		"patches/ui-patches/privacy-preferences.patch"
		"patches/ui-patches/remove-branding-urlbar.patch"
		"patches/ui-patches/remove-cfrprefs.patch"
		"patches/ui-patches/remove-snippets-from-home.patch"
		"patches/ui-patches/rename-firefox-labs.patch"
		"patches/ui-patches/snowfox-logo-devtools.patch"
		"patches/ui-patches/website-appearance-ui-rfp.patch"
		"patches/unified-extensions-dont-show-recommendations.patch"
		"patches/unity_kde/firefox-kde.patch"
		"patches/unity_kde/mozilla-kde.patch"
		"patches/unity_kde/unity-menubar.patch"
		"patches/urlbarprovider-interventions.patch"
		"patches/windows-theming-bug.patch"
	]
const moz_tmk = "Firefox and the Firefox logos are trademarks of the Mozilla Foundation."

function update(dir::String, recursive::Bool = SUBMODULES)
	@info dir recursive
	let d = "$dir/assets/"
		isdir(d) && touch.(d .* ["search-config.json", "search-config-v2.json"])
	end
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
					s = readstr(f)
					if endswith(r"\.(diff|patch)")(f)
						s = replace(s, " [ab]/browser/components/BrowserGlue\\K\\.jsm", ".sys.mjs")
						s = replace(s, " [ab]\\K/lw/", "/snowfox/")
						s = replace(s, r"^\+[\t ]+$"m, "+")
						s = replace(s, r"^diff --git .+?\K\blibrewolf\b"m, "snowfox")
						s = replace(s, r"^rename to\ .+?\K\blibrewolf\b"m, "snowfox")
						for p ∈ schemes
							s = replace(s -> startswith(s, '+') ? replace(s, p...) : s, split(s, '\n')) |> s -> join(s, '\n')
						end
					else
						for p ∈ schemes
							s = replace(s, p...)
						end
					end
					p, q = "privacy." .* ["resistFingerprinting", "fingerprintingProtection"]
					s = replace(s, "\"$p\"" => "\"$q\"")
					s = replace(s, "\r\n" => "\n")
					s = replace(s, r"^.*\bEXTRA_PATH.*\n"m => "")
					s = replace(s, r"^.*\bLOWERCASE_.*\n"m => "")
					s = replace(s, r"^.*liblowercase.*\n"m => "")
					s = replace(s, r"https://\Kraw\.(github)usercontent(\.com/[^/]+/[^/]+)/", s"\1\2/raw/")
					s = replace(s, r"https://\Ksnowfox(\.net)", s"librewolf\1")
					s = replace(s, r"https://codeberg\.org/\Ksnowfox", s"librewolf")
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
					s = replace(s, "overriden", "overridden", "w")
					s = replace(s, "pacakged", "packaged", "w")
					s = replace(s, "referes", "referrers", "w")
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
						s = replace(s, r"^\+.*ColorScheme::\KLight"m, s"Dark")
						s = replace(s, r"^\+.*https://support.mozilla.org/\Ken-US/"im, "")
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
					if endswith(".sh")(f)
						s = replace(s, r"[\t ]{1,}$"m => s"")
						s = replace(s, r"^\t*\K {2}"m, s"\t")
						s = replace(s, r"^\t+\K {1}"m => s"")
					end
					if endswith(".xhtml")(f)
						s = replace(s, r"[\t ]{1,}$"m => s"")
						s = replace(s, r"^\t*\K {2}"m, s"\t")
					end
					if startswith(r"mozconfig\b")(f)
						p = "ac_add_options"
						s = replace(s, r"distribution-id=\K(com\.0h7z)\.snowfox" => s"\1")
						s = replace(s,
							"$p --with-app-name=\\w+\n" *
							"$p --with-branding=browser/branding/\\w+\n",
							"$p --enable-update-channel=release\n" *
							"$p --with-branding=browser/branding/snowfox\n", "e") # ~ do not sort this
					end
					if (f ≡ "Makefile") || endswith(".mk")(f)
						p = raw"${version}-${release}"
						s = replace(s, ("\\bsource archive \\K(\\Q$p.\\E)"), s"v\1")
						s = replace(s, r"_create:=tar\K cfz$"m, " Ifc \"$zst_cmd\"")
						s = replace(s, r"@echo \"Firefox version\K  ( : \")", s"\1")
						s = replace(s, r"^.*\btouch\b.*\n"m => (("")))
						s = replace(s, r"^ext:=\.tar\K\.gz$"m, ".zst")
						s = replace(s, r"\btar cf .+\n\s*gzip .+$"m =>
							raw"$(archive_create) $(sf_source_tarball) $(sf_source_dir)")
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
							"""	color-scheme: only dark;\n""" *
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
						s = replace(s, r"""href=\K"(https://librewolf.net)/?">\1/?</""", "\"$url_doc\">$url_doc</")
						s = replace(s, r"the primary\s+goals of privacy, security\K( and user freedom\.)"s, s",\1")
					end
					if (f ≡ "allow-ubo-private-mode.patch")
						s = replace(s, r"\bduring\K install and\b" => "", r"// \K(upgrade)\b" => s"install and \1")
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
						s = replace(s, r"^MOZ_APP_DISPLAYNAME\=\K.*$"m => "Snowfox")
						s = replace(s, r"^MOZ_APP_PROFILE=\K.*$"m => "Snowfox")
						s = replace(s, r"^MOZ_APP_REMOTINGNAME=\K.*$"m => "snowfox")
						s = replace(s, r"^MOZ_DEV_EDITION=\K.*$"m => "0")
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
							"MOZ_DISTRIBUTION_ID=com.0h7z\n" *
							"MOZ_MACBUNDLE_ID=snowfox\n" * # MOZ_MACBUNDLE_ID=MOZ_DISTRIBUTION_ID.MOZ_MACBUNDLE_ID
							"MOZ_MACBUNDLE_NAME=Snowfox.app\n", "e")
					end
					if (f ≡ "generate-locales.sh")
						p = "julia ../../locale.jl browser/locales/{en-US,l10n}"
						q = "\necho '$p'\n$p\n"
						s = endswith(s, q) ? s : s * q
					end
					if (f ≡ "patches.txt")
						s = endswith(s, "\n") ? s : s * "\n"
						for p ∈ patch_g
							s = occursin(p, s) ? s : s * p * "\n"
						end
						for p ∈ patch_b
							s = replace(s, r"^"m * p * "\n", s"")
						end
					end
					if (f ≡ "policies.json")
						o = "https://addons.mozilla.org/firefox/downloads/latest"
						p = "https://github.com/Heptazhou"
						q = "q={searchTerms}"
						q_duck = "k1=-1&kaj=m&kak=-1&kao=-1&kaq=-1&kau=-1&kn=1&kp=-2"
						q_goog = "hl={language}&filter=0&newwindow=1"
						s = replace(s, "https://.+/librewolf.*/issues", "$p/Snowfox/issues")
						s = replace(s, "https://localhost/*" => "https://example.invalid/*")
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
							"""		"SanitizeOnShutdown": {\n""" *
							"""			"Cache": true,\n""" *
							"""			"Cookies": false,\n""" *
							"""			"Downloads": false,\n""" *
							"""			"FormData": true,\n""" *
							"""			"History": false,\n""" *
							"""			"OfflineApps": true,\n""" *
							"""			"Sessions": true,\n""" *
							"""			"SiteSettings": false,\n""" *
							"""			"Locked": false\n""" *
							"""		},\n""" *
							"""		"EncryptedMediaExtensions": {\n""" *
							"""			"Enabled": false,\n""" *
							"""			"Locked": false\n""" *
							"""		},\n""" *
							"""		"DisableAppUpdate": true,\n""", "p") # ~ do not sort this
						s = replace(s, # Extensions
							"""			"Install": [\n""" *
							"""				"$o/ublock-origin/latest.xpi"\n""" *
							"""			],\n""" *
							"""			"Uninstall": [\n""" *
							"""				"google@search.mozilla.org",\n""" *
							"""				"bing@search.mozilla.org",\n""" *
							"""				"amazondotcom@search.mozilla.org",\n""" *
							"""				"ebay@search.mozilla.org",\n""" *
							"""				"twitter@search.mozilla.org"\n""" *
							"""			]\n""",
							"""			"Install": [\n""" *
							"""				"$o/ublock-origin/latest.xpi",\n""" *
							"""				"$p/firefox-qr/releases/latest/download/latest.xpi"\n""" *
							"""			],\n""" *
							"""			"Uninstall": []\n""", "p") # ~ do not sort this
						s = replace(s, # SearchEngines
							"""			"Remove": [\n""" *
							"""				"Google",\n""" *
							"""				"Bing",\n""" *
							"""				"Amazon.com",\n""" *
							"""				"eBay",\n""" *
							"""				"Twitter"\n""" *
							"""			],\n""", # ~ do not sort this
							"""			"Remove": ["Google"],\n""", "p")
						s = replace(s, # SearchEngines
							"""			"Default": "DuckDuckGo",\n""" *
							"""			"Add": [\n""" * """[\\S\\s]+?\n""" *
							"""			]\n""",
							"""			"Default": "Duckduckgo",\n""" *
							"""			"Add": []\n""", "e") # ~ do not sort this
						s = replace(s, # SearchEngines
							"""			"Default": "Duckduckgo",\n""" *
							"""			"Add": []\n""",
							"""			"Default": "Duckduckgo.com",\n""" *
							"""			"Add": [\n""" *
							"""				{\n""" *
							"""					"Name": "Duckduckgo.com",\n""" *
							"""					"Description": "Search Duckduckgo.com",\n""" *
							"""					"Alias": "@ddg",\n""" *
							"""					"Method": "GET",\n""" *
							"""					"URLTemplate": "https://duckduckgo.com/?$q_duck&$q",\n""" *
							"""					"SuggestURLTemplate": "https://ac.duckduckgo.com/ac/?$q",\n""" *
							"""					"IconURL": "$icon_duck"\n""" *
							"""				},\n""" *
							"""				{\n""" *
							"""					"Name": "Google.com",\n""" *
							"""					"Description": "Search Google.com",\n""" *
							"""					"Alias": "@goog",\n""" *
							"""					"Method": "GET",\n""" *
							"""					"URLTemplate": "https://www.google.com/search?$q_goog&$q",\n""" *
							"""					"SuggestURLTemplate": "https://www.google.com/complete/search?$q",\n""" *
							"""					"IconURL": "$icon_goog"\n""" *
							"""				}\n""" *
							"""			]\n""", "p") # ~ do not sort this
						s = replace(s, r"\"DisableSetDesktopBackground\": \Kfalse(?=,)" => "true")
					end
					if (f ≡ "search-config.json" || f ≡ "search-config-v2.json") && pwd() ≠ @__DIR__
						t = round(Int64, datetime2unix(trunc(now(), Year)))
						s = cd(@__DIR__) do
							readstr(f)
						end
						s = replace(s, raw"\"${timestamp}\"" => "$(1000t)") # s -> ms
					end
					if (f ≡ "snowfox-patches.py")
						s = replace(s, r"\bpatch -p1 \K-i\b" => "-li")
						s = replace(s, r"^.*/category-snowfox\.svg\b.*\n"m => "")
						s = replace(s, r"^.*/mozfetch\.sh\b.*\n"m => "")
						s = replace(s, r"^.*/pack_vs\.py\b.*\n"m => "")
						s = replace(s, r"^.*\bmozconfigs?.*\n"m => "")
						s = replace(s,
							r"^(\t+)\K# override the firefox version\n(\1.+\n)+"m,
							"exec('echo $VER > browser/config/version_display.txt')" * "\n")
						s = replace(s,
							r"'cp -v (\.\./assets)/(search-config\.json) (services/settings/dumps/main)/\2'",
							s"'cat \1/\2 | tee \3/search-*.json && cp -vf \1/search-*.json \3/'")
						s = replace(s,
							r"'wget -q https://[^/]+/[^/]+/settings/raw/branch/[^/]+/(.+?)'",
							s"'cp -v ../../submodules/settings/\1 .'")
						s = replace(s,
							s"'cp -v ../../settings/",
							s"'cp -v ../../submodules/settings/", "p")
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
						p = "browser/themes/shared/preferences/category-snowfox.svg"
						p = "diff --git a/$p b/$p"
						s = replace(s,
							"$p\n[^+-]+\n" * "--- [^\n]+\n" * "\\+\\+\\+ [^\n]+\n" *
							"@@[^\n]+@@\n" * "(\\+[^\n]*\n)+", "", "e")
					end
					if (f ≡ "snowfox-prefs.patch")
						n = count(startswith(r"\+(?!\+\+ )"), eachsplit(s, "\n"))
						s = replace(s, r"@@ -(\d+),0 \+\1,\K\d+ @@" => ("$n @@"))
					end
					if (f ≡ "snowfox.cfg")
						s = replace(s, "(?<!\b)'|'(?!\b)", "\"")
						s = replace(s, "\n //", "\n//") * ("\n")
						s = replace(s, "what\"s", "what's", "w")
						s = replace(s, ("\"none\""), ("'none'"))
						s = replace(s, ("https://dns.quad9.net/dns-query"), (url_doh), "w")
						url_log = url_doc * "changelog/"
						let p = "[^`]*?"
							for m ∈ collect(eachmatch(Regex("^$p\\K`$p\\n$p`(?=$p\$)", "m"), s))
								s = replace(s, m.match => replace(m.match, r"[\t\n]+"s => s" "))
							end
						end
						for p ∈ [
							"""("browser.download.alwaysOpenPanel", false)""" => """("browser.download.alwaysOpenPanel", true)""",
							"""("browser.download.useDownloadDir", false)"""  => """("browser.download.useDownloadDir", true)""",
							"""("devtools.selfxss.count", 0)"""               => """("devtools.selfxss.count", 5)""", # 0
							"""("privacy.userContext.enabled", true)"""       => """("privacy.userContext.enabled", false)""",
							"""("webgl.disabled", true)"""                    => """("webgl.disabled", false)""",
							#
							r"""\(("privacy\.query_stripping\.strip_list"), *"[^"]*"\)""" => s"""(\1, "@@STRIP_LIST@@")""", # ""
							r"""\(("privacy\.resistFingerprinting\.letterboxing"), *true\)""" => s"""(\1, false)""",
							r"""\(("security\.ssl\.require_safe_negotiation"), *true\)""" => s"""(\1, false)""",
							r"@@STRIP_LIST@@" => join(strip_list, " "),
							r"^.*( brave |/brave/|[/#](1569|1975|1275887)\b).*\n"m => "",
						]
							s = replace(s, p)
						end
						for p ∈ [
							"app.releaseNotesURL.aboutDialog"       => "$url_log#v%VERSION%",
							"app.releaseNotesURL"                   => "$url_log#v%VERSION%",
							"app.update.url.details"                => "$url_git/releases",
							"app.update.url.manual"                 => "$url_git/releases",
							"browser.toolbars.bookmarks.visibility" => "newtab",
						]
							s = replace(s,
								"""("$(p[1])", *"[^\"]*")""" |> s -> escape_string(s, "(.)"),
								"""("$(p[1])", "$(p[2])")""", n = 1)
						end
						for p ∈ [
							"app.feedback.baseURL"                # https://ideas.mozilla.org/
							"app.support.baseURL"                 # https://support.mozilla.org/1/firefox/%VERSION%/%OS%/%LOCALE%/
							"browser.download.start_downloads_in_tmp_dir"
							"browser.geolocation.warning.infoURL" # https://www.mozilla.org/%LOCALE%/firefox/geolocation/
							"browser.search.searchEnginesURL"     # https://addons.mozilla.org/%LOCALE%/firefox/search-engines/
							"doh-rollout.provider-list"
							"intl.accept_languages"
							"javascript.use_us_english_locale"
							"network.trr."                # network.trr.*
							"privacy.clearOnShutdown_v2." # privacy.clearOnShutdown_v2.*
							"privacy.clearOnShutdown."    # privacy.clearOnShutdown.*
							"privacy.sanitize."           # privacy.sanitize.*
							"security.family_safety.mode"
						]
							s = replace(s, (r"^.*\b"m * p * r"\b.*\n"m) => "")
						end
						s = replace(s, r"^\n{3,}\K\n+"m, s"") # (again)
						s = replace(s, r"^\n*"s => "\n"^2)
						s = replace(s, r"let profile_directory;.+;\n\}\K.*$"s,
							"""\n"""^2 *
							"""clearPref("browser.newtabpage.activity-stream.weather.temperatureUnits");\n""" *
							"""clearPref("browser.safebrowsing.blockedURIs.enabled");\n""" *
							"""clearPref("browser.safebrowsing.downloads.enabled");\n""" *
							"""clearPref("browser.safebrowsing.malware.enabled");\n""" *
							"""clearPref("browser.safebrowsing.phishing.enabled");\n""" *
							"""clearPref("general.useragent.compatMode.firefox");\n""" *
							"""clearPref("image.avif.force-loop");\n""" *
							"""clearPref("image.http.accept");\n""" *
							"""clearPref("image.rgbx-mode");\n""" *
							"""clearPref("layout.css.prefers-color-scheme.content-override");\n""" *
							"""clearPref("network.http.accept");\n""" *
							"""clearPref("network.http.referer.XOriginPolicy");\n""" *
							"""clearPref("network.http.windows-sso.enabled");\n""" *
							"""clearPref("privacy.donottrackheader.enabled");\n""" *
							"""clearPref("privacy.fingerprintingProtection.overrides");\n""" *
							"""clearPref("privacy.fingerprintingProtection.pbmode");\n""" *
							"""clearPref("privacy.fingerprintingProtection");\n""" *
							"""clearPref("privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts");\n""" *
							"""clearPref("privacy.spoof_english");\n""" *
							"""clearPref("security.OCSP.enabled");\n""" *
							"""clearPref("security.OCSP.require");\n""" *
							"""clearPref("security.pki.crlite_mode");\n""" *
							"""clearPref("xpinstall.signatures.required");\n""" *
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
							"""defaultPref("media.cubeb.force_sample_rate", 0);\n""" *
							"""defaultPref("media.eme.showBrowserMessage", false);\n""" *
							"""defaultPref("network.trr.custom_uri", "$url_doh");\n""" *
							"""defaultPref("network.trr.default_provider_uri", "$url_doh");\n""" *
							"""defaultPref("pdfjs.externalLinkTarget", 2);\n""" * # 0 NONE 1 SELF 2 BLANK 3 PARENT 4 TOP
							"""defaultPref("snowfox.app.checkVersion.enabled", true);\n""" *
							"""defaultPref("snowfox.app.checkVersion.url", "$url_api/releases");\n""" *
							"""defaultPref("xpinstall.signatures.required", false);\n""" *
							"""lockPref("browser.dataFeatureRecommendations.enabled", false);\n""" *
							"""lockPref("browser.firefox-view.view-count", 0);\n""" *
							"""lockPref("browser.privacySegmentation.preferences.show", false);\n""" *
							"""\n"""^2, "p", n = 1)
					end
					if (f ≡ "snowfox.inc.xhtml")
						o = "privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts"
						p = "(?:\\t+.+\\Q\"$o\"\\E.+\\n)+"
						q = "(?:\\t+.+\\n)+"
						s = replace(s, Regex("^\\n$q$p$q", "m") => "")
					end
					if (f ≡ "snowfox.js")
						s = replace(s, "[2], [0]" => "[1], [0]")
					end
					if (f ≡ "uBOAssets.json")
						s = replace(s, "\t", " "^2)
						s = replace(s, r"^\t*\K {2}"m, ("\t"))
					end
					write(f, s)
				end
			end
		end
	end
end

const SUBMODULES = something(tryparse.(Bool, [ARGS; "0"])...)

filter!(!=("/"), ARGS)
if isempty(ARGS)
	(dir, arg) = @__DIR__, pwd()
	update(startswith(arg, dir) ? arg : dir)
else
	(dir, arg) = @__DIR__, abspath.(ARGS[1])
	isdir(arg) || throw(SystemError(arg, 2))
	update(startswith(arg, dir) ? arg : dir)
end

