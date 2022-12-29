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

const DKR = "docker"
const GIT = (("git") * (Sys.iswindows() ? ".exe" : ""))
const GMK = ("make") * (Sys.iswindows() ? ".exe" : "")
const JLC = ["julia" * (Sys.iswindows() ? ".exe" : ""), "--startup-file=no", "--compile=min", "--color=yes"]
const PKG = ("pkg/")
const SRC = ("src/")

const schemes =
	[
		"librewolf" => "snowfox",
		"libreWolf" => "snowfox",
		"Librewolf" => "Snowfox",
		"LibreWolf" => "Snowfox",
		"LIBREWOLF" => "SNOWFOX",
		r"\blw\_"   => "sf_",
		r"\blw\b"   => "snowfox",
		r"\bLW\b"   => "Snowfox",
		#
		"firefox\\.icns"                   => "snowfox.icns",
		"firefox\\.ico"                    => "snowfox.ico",
		"firefox\\.VisualElementsManifest" => "snowfox.VisualElementsManifest", # .xml
		"firefox64\\.ico"                  => "snowfox64.ico",
		"LICENSE\\.txt"                    => "LICENSE",
		"snowfox\\.overrides\\.cfg"        => "snowfox.config.js",
		r"\.en-US\.win64-portable\.zip\b"  => ".win64.zip",
		r"\.en-US\.win64-setup\.exe\b"     => ".win64.exe",
		r"\.sha256\Ksum(?!\?)"             => "",
	]

# https://github.com/brave/brave-core/blob/74ad0c0a/browser/net/brave_site_hacks_network_delegate_helper.cc
# https://github.com/brave/brave-core/blob/master/browser/net/brave_query_filter.cc
const strip_list =
	[
		"__hsfp"
		"__hssc"
		"__hstc"
		"__s"
		"_hsenc"
		"_openstat"
		"adpicid"
		"app_version"
		"bsft_clkid"
		"bsft_uid"
		"dclid"
		"fbclid"
		"from_source"
		"from_spmid"
		"gbraid"
		"gclid"
		"gclsrc"
		"guccounter"
		"guce_referrer_sig"
		"guce_referrer"
		"hsCtaTracking"
		"igshid"
		"isappinstalled"
		"mc_cid"
		"mc_eid"
		"ml_subscriber_hash"
		"ml_subscriber"
		"mpshare"
		"msclkid"
		"network_status"
		"oft_c"
		"oft_ck"
		"oft_d"
		"oft_id"
		"oft_ids"
		"oft_k"
		"oft_lk"
		"oft_sk"
		"oly_anon_id"
		"oly_enc_id"
		"p2p_type"
		"platform_network_status"
		"rb_clickid"
		"ref_src"
		"ref_url"
		"referfrom"
		"s_cid"
		"share_medium"
		"share_plat"
		"share_session_id"
		"share_source"
		"share_tag"
		"share_token"
		"sharer_shareid"
		"sharer_sharetime"
		"sourceFrom"
		"sourceType"
		"spm_id_from"
		"ss_campaign_id"
		"ss_campaign_name"
		"ss_campaign_sent_date"
		"ss_email_id"
		"ss_source"
		"tdsourcetag"
		"tt_from"
		"twclid"
		"unique_k"
		"usqp"
		"utm_ad"
		"utm_affiliate"
		"utm_brand"
		"utm_campaign"
		"utm_campaignid"
		"utm_channel"
		"utm_cid"
		"utm_content"
		"utm_emcid"
		"utm_emmid"
		"utm_id"
		"utm_keyword"
		"utm_medium"
		"utm_name"
		"utm_oi"
		"utm_place"
		"utm_product"
		"utm_pubreferrer"
		"utm_reader"
		"utm_referrer"
		"utm_relevant_index"
		"utm_serial"
		"utm_session"
		"utm_siteid"
		"utm_social-type"
		"utm_social"
		"utm_source"
		"utm_supplier"
		"utm_swu"
		"utm_term"
		"utm_umguk"
		"utm_user"
		"utm_userid"
		"utm_viz_id"
		"vd_source"
		"vero_conv"
		"vero_id"
		"vgo_ee"
		"wbraid"
		"weibo_id"
		"wickedid"
		"wxshare_count"
		"xhsshare"
		"yclid"
	]

