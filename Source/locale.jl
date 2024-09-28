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

# [compat]
# julia = "≥ 1.6"

const lc = cd(@__DIR__) do
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
			"^-send"
			"^-translations"
		] .* "-brand-"
	] .|> Regex

@time foreach(ARGS) do (dir)
	endswith(r"\bl10n")(dir) && cd(dir) do
		for x ∈ readdir()
			x ∈ [lc; ".git"] || rm(x, recursive = true)
		end
	end
	for (prefix, ds, fs) ∈ walkdir(dir, topdown = false)
		occursin(prefix)(r"\.git\b") && continue
		cd(prefix) do
			for d ∈ ds
				if basename(prefix) ≡ "branding" && d ≡ "official"
					mv(d, "snowfox", force = true)
				end
			end
			for f ∈ fs
				if endswith(".ftl")(f) || endswith(".ini")(f) ||
				   endswith(".properties")(f)
					v = readlines(f)
					replace!(v) do s
						any(occursin(s), rs) && return s
						# = { DATETIME(\$dateObj, dateStyle: "short", timeStyle: "medium") }
						s = replace(s, r"^[^#]*?=.*?\K\{.*?(\$dateObj)\b.*?\}" => s"{ \1 }")
						s = replace(s, r"^[^#]*?=.*?\K\b(Mozilla +)?Firefox\b" => "Snowfox")
						s = replace(s, r"^[^#]*?=.*?\K\bMozilla\b" => "Snowfox")
						return s
					end
					write(f, join(v, "\n"), "\n")
				end
			end
		end
	end
end

