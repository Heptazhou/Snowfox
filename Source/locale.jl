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

const lc = cd(@__DIR__) do
	f = "../../Firefox/browser/locales/shipped-locales"
	isfile(f) && cp(f, basename(f), force = true)
	readlines("shipped-locales")
end

const rs =
	[
		[
			"^(mr2022-)?onboarding-gratitude-"
			"^\\s*?\\.(label|title)\\b"
			"^about-debugging-browser-version-too-old-fennec"
			"^about-debugging-setup-usb-step-enable-debug-"
			"^about-mozilla-"
			"^about-telemetry-"
			"^app-basics-key-"
			"^cert-error-mitm"
			"^certErrorMitM"
			"^default-bookmarks-(bugzilla|mdn|planet)"
			"^default-bookmarks-nightly-"
			"^DrawWindowCanvasRenderingContext2DWarning"
			"^e10s\\.accessibilityNotice\\.jawsMessage"
			"^ion-enroll-"
			"^ion-summary"
			"^ManufacturerID"
			"^migration-wizard-migrator-display-name-"
			"^MozillaMaintenanceDescription"
			"^plugins-openh264-"
			"^process-type-privilegedmozilla"
			"^protections-panel-content-blocking-breakage-"
			"^recommended-theme-"
			"^rights-intro-point-"
			"^sync-mobile-promo"
			"^trademarkInfo"
		]
		[
			"^-fakespot"
			"^-focus"
			"^-fxaccount"
			"^-lockwise"
			"^-monitor"
			"^-mozilla-vpn"
			"^-mozmonitor"
			"^-profiler"
			"^-relay"
			"^-secure-proxy"
			"^-send"
			"^-translations"
		] .* "-brand-"
	] .|> Regex

function patch(x; keep = false)
	dir = mkpath(x) / ""
	keep || endswith(dir, r"\bl10n/") && cd(dir) do
		for x ∈ readdir()
			x ∈ [lc; ".git"] || rm(x, recursive = true)
		end
	end
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = keep)
		@skip_ds prefix
		endswith(prefix, "/browser/branding/") || continue
		print("\r\e[2K", prefix)
		cd(prefix) do
			d  = "official"
			d′ = "snowfox"
			isdir(d) || return
			ps = [
				"brand.ftl"
				"brand.properties"
				"locales/jar.mn"
				"locales/moz.build"
			]
			_ = keep ? for (p, p′) ∈ eachrow([d d′] ./ ps)
				ispath(p) ? mkpath(dirname(p′)) : continue
				cp(p, p′, force = true)
			end :
				mv(d, d′, force = true)
		end
	end
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = true)
		@skip_ds prefix
		contains(prefix, r"/browser/branding/(?!snowfox|$)") && continue
		print("\r\e[2K", prefix)
		for f ∈ fs
			if endswith(".dtd")(f) || endswith(".ftl")(f) ||
			   endswith(".ini")(f) || endswith(".properties")(f)
				x = f ∈ ("appstrings", "dom") .* ".properties"
				v = readlines(prefix / f, keep = true)
				_ = replace!(v) do s
					any(occursin(s), rs) && return s
					# = { DATETIME(\$dateObj, dateStyle: "short", timeStyle: "medium") }
					s = replace(s, r"^[^#]*?=.*?\K\{.*?(\$dateObj)\b.*?\}" => s"{ \1 }")
					s = replace(s, r"^[^#]*?=.*?\K\b(Mozilla +)?Firefox\b" => "Snowfox")
					x ? expands(s) : (s)
				end
				write(prefix / f, join(v))
			end
		end
	end
	print("\r\e[2K")
end

const keep = any(∈(ARGS), ("-k", "--keep"))

if abspath(PROGRAM_FILE) == @__FILE__
	@time foreach((ARGS)) do arg
		startswith(arg, r"--?\w") && return
		patch(arg; keep)
	end
end

# time julia locale.jl ../../Firefox -k
# time julia locale.jl ../../firefox-l10n-source ../../firefox-l10n/zh-CN

