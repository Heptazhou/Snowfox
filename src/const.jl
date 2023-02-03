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
const UAV = (UInt16)(108) # https://oeis.org/A001694

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
# https://github.com/DandelionSprout/adfilt/discussions/163
# https://github.com/Heptazhou/Heptazhou.github.io/blob/master/URLenc/main.js
# https://github.com/the1812/Bilibili-Evolved/blob/master/registry/lib/components/utils/url-params-clean/index.ts
const strip_list_msc =
	[
		"_ff"
		"_ts"
		"ab_channel"
		"accept_quality"
		"ad_od"
		"adpicid"
		"amp"
		"app_version"
		"apptime"
		"appuid"
		"bbid"
		"bddid"
		"bdtype"
		"broadcast_type"
		"bsft_clkid"
		"bsft_uid"
		"bsource"
		"buvid"
		"client"
		"current_qn"
		"current_quality"
		"device_id"
		"dm_progress"
		"dmid"
		"eqid"
		"euri"
		"fclid"
		"feature"
		"featurecode"
		"from_module"
		"from_source"
		"from_spmid"
		"from"
		"fromid"
		"fromtitle"
		"fromTitle"
		"fromurl"
		"gbv"
		"group_id"
		"gsm"
		"inputT"
		"ipn"
		"is_reflow"
		"is_story_h5"
		"isappinstalled"
		"islist"
		"issp"
		"jid"
		"lfid"
		"luicode"
		"mpshare"
		"msource"
		"network_id"
		"network_status"
		"network"
		"oid"
		"oriquery"
		"p2p_type"
		"pid"
		"plat_id"
		"platform_network_status"
		"playurl_h264"
		"playurl_h265"
		"prefixsug"
		"puid"
		"push_task_id"
		"qbl"
		"qid"
		"quality_description"
		"querylist"
		"rand"
		"referfrom"
		"req_id"
		"retcode"
		"rnid"
		"rsf"
		"rsp"
		"rsv_bp"
		"rsv_btype"
		"rsv_cq"
		"rsv_dl"
		"rsv_enter"
		"rsv_idx"
		"rsv_iqid"
		"rsv_pq"
		"rsv_spt"
		"rsv_t"
		"scene"
		"sclient"
		"sei"
		"seid"
		"session_id"
		"sfr"
		"sfrom"
		"share_from"
		"share_medium"
		"share_plat"
		"share_session_id"
		"share_source"
		"share_tag"
		"share_token"
		"sharer_shareid"
		"sharer_sharetime"
		"simid"
		"sme"
		"source"
		"sourceFrom"
		"sourceType"
		"spm_id_from"
		"spn"
		"src_campaign"
		"src_medium"
		"src_source"
		"src_term"
		"src"
		"srcid"
		"ss_campaign_id"
		"ss_campaign_name"
		"ss_campaign_sent_date"
		"ss_email_id"
		"ss_source"
		"suglabid"
		"suguuid"
		"tdsourcetag"
		"timestamp"
		"ts"
		"tt_from"
		"uct"
		"unique_k"
		"up_id"
		"usg"
		"usm"
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
		"ved"
		"visit_id"
		"weibo_id"
		"wfr"
		"wid"
		"wxa_abtest"
		"wxfid"
		"wxshare_count"
		"xhsshare"
	]

# LegitimateURLShortener
# https://github.com/DandelionSprout/adfilt/discussions/163
const strip_list_ubo =
	[
		"__hsfp"
		"__hssc"
		"__hstc"
		"__s"
		"_hsenc"
		"_openstat"
		"dclid"
		"fbclid"
		"gbraid"
		"gclid"
		"gclsrc"
		"guccounter"
		"guce_referrer_sig"
		"guce_referrer"
		"hsCtaTracking"
		"igshid"
		"lpn"
		"mc_cid"
		"mc_eid"
		"ml_subscriber_hash"
		"ml_subscriber"
		"msclkid"
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
		"rb_clickid"
		"ref_src"
		"ref_url"
		"refd"
		"s_cid"
		"spm"
		"src_content"
		"src_custom"
		"twclid"
		"vero_conv"
		"vero_id"
		"vgo_ee"
		"wbraid"
		"wickedid"
		"yclid"
	]

const strip_list = String[strip_list_msc; strip_list_ubo]

