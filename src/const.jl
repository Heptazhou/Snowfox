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

const DKR = "docker"
const GIT = (("git") * (Sys.iswindows() ? ".exe" : ""))
const GMK = ("make") * (Sys.iswindows() ? ".exe" : "")
const JLC = ["julia" * (Sys.iswindows() ? ".exe" : ""), "--startup-file=no", "--compile=min", "--color=yes"]
const PKG = ("pkg/")
const SRC = ("src/")

# https://archive.mozilla.org/pub/firefox/
# https://whattrainisitnow.com
const ESR = v"128".major # 140
const VER = v"131.0.3-1"

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
		r"\.sha\K256sum\b"                 => "256",
		r"\.sha\K512sum\b"                 => "3-512",
		r"\bsha\K512sum\b"                 => "3-512sum",
	]

# https://duckduckgo.com/favicon.ico
# https://github.com/Heptazhou/Firefox/blob/FIREFOX_NIGHTLY_128_END/browser/components/search/extensions/ddg/favicon.ico
const icon_duck = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAG9ElEQVRYR5VXe2xTVRj/3duuLXtvuGF5bCsgiSyRQUdCMIEtGgmgOAMG9hBGRB4JYcNhRM1gC4lgIopEFKeEsUQGZAQQDMSEsPmHEsdkiYA6gW7C3KPMwbpnu97r+c7d6W7bC5vnn7bnnH7f7/u+3/c4Esa5XIU58X7v3zkRirRYUaUMmNQ0VUE8/V2S8RB+qVmR1EZVVutMlpSzjsqzD8cjWhrrkqswK00e6CtSTEqhUDjWf+hcBSplW0y5o7K2+Un3HwuALJaH7u/2q2qxEGB71onI+VmYMNsJc5IdcmQMP1L6PfA2N2GopQn99bUY/L0hoFOV5AOyNYqAGHrEEABZjUHPFWZFGkmKXvQKEla9xZROHo/xGHb/g+6ar9H743l+nylphi0m28gbYQBcefMzoChnSDkpnFTyMSypswKWPrpYjcFbDUxJG1dES46K4XciM7MQlbk4AJTO2/Zs5vc4CFl+zXG8vlFvRRAAveUxzOrEdW9zN5OAvtZmWC1W7u6++jr0N9RC6fMYeiR6MfPYSs1jdN/9ZTn6r9UaeiIYwBqniywnS8hyWmRxz5VziC/YDsmeCktcIiwWCwfVVfUJF2y0CHj8qo2IW5rLjx8cLoen7rwAMVdwIgCgJTfzUyIcoZ6y71tueffpCjysqRiVb4uCJa8YTy1aBqvVyvd76y7weyIcoWAIRMLKjdwTrTvz+T0i5ozq+u0j/ADI9eqgx0Ub0w5+x11Hlv9btT8gz5Kdg4mvb4EtYaKhxcJCo8PEtSXcE16WJa078zRi2mIcRErugTtrnEfZl0Jie9KW3Rxl63v5gRhblubDXlDEOCQbKqdNvYWhl8ib5FUyjPhA2aFK+GxGdUOx5CrOilfbPd16690sXr0sXnwlJHOv3GzqRMcDDxZmpiE6UnO/WLdbutDh9sDuvgGpqswQpI3VDnvpV9y4e9tWaNXTEuOQbufNK5QV6SgVGfuu0QtCimlJLlIKS0BKZqYau1/cJS+Q8MdlR+qRK5xbbXs28VRWZHm9JNwv4hQae9uGUthfeJXr6O0fQm+fF08naRVQv76o+glzZtsxs+7QYzMjnpExgZFS6DCxci258jKvq4qaQe4hNwl0Qrht6z7Yn3+R/9z0fg2iJ1hRXvJSWBgKio5joTMNq/EzehiBjZYIgyCjJMuNDICzm5qMcE/LhuwgF5pWb0NKzlour+r0Nf65dmWmoQLa7GZp+5ClpWxjJTwdmDANcF9iJB0EJyHxiULV8mY254F0d42T1R7AUa0Jd+UGC1eXFWL6G1vDFfpZFey6APQ3BZ0Nt/8JDDTBHKttD94D2k6OXgnVMzaAeVmYWvQhr35B67cVgFfrBaFLGWJHnYDnBuPNzeDTMAChISAWB1U1uwOJu79BXFzcqCRmIW5pBWWAWdh5bsTFzGrFq303WpQBFOqgEAgSTtl7HJa0WWEkJEFRH9UgOSVtVCa5nzzAPr1uoOMsMPzIWKl+V6Q6pSCRXSNhrrNSVbFOpKEgkf6P0sZypGUvD9ZAsb+7AxjSwkBA9JabmcMoDAROrNBU52kYKEQjlUq4R69NXbgcKVtKYTabw8wc/qMCA79UwJrE5gLGfA6mg+FigHp+DQYl+oxIdUlW1/NSjE6Pi1Ix9EJAmyMdie8eDObByKGRx4yCoe8zxDNarCElaM0oz3lAUlBEg0TS5vBmRHci953CpNTpYbKpHbsPlwX2/7KbMMGrYmqXEtijiWnK3pFmNNJnyP2pJxrWcwCuwgWsHft4OxZkpGrWpWvHgge9Pg9cntuYHvsMoszRPGMaP8jhSi9lmFGbbsZzLX5suMzSYWRNZO04lrVj0Yg06yNYO76qtWO9F/QDCQ0jNGzQIh7YN+zE961ncMz1Jd9Lj5uDzsF2uIc6oPgVxmoJkiQhsVdF2SktF2kYoaEkeCDRWjEHIgBwLrR7rtNIJkJBZ+QJAqEkpyD+nQO43HUxAMA/7OcSTCYTm2MVDsIcoRH185Nmrpwsp9Wxf0dgLnScaHAIvSFD6QI2jvv4OE5zIQ0nYiilMdu3JB8d0d0obWTzIbPU5/XBqlo5APv9HiT0+HFnsgkW+zQcST8UGEppdqT5QhvPI9h4frXZEABtho7l9tLDo2P28DAG1QEU/PAyoiJisSNjF+Ymz+eyxOwYuyw38GChrkeWj3ssD4SDkVJ4gvb0Yzb9JiJGR4TPBOL//GFymj1MRqYqI8sf6wFxQJ8iPcUe9XMKjZU9Qqhs659mw51tGGBPMhrTqdSKRbOfbI0p+19PMz0ISlEM+cqoXOv3n/Sd+ryi4phsjTigj7fRf8Z8HY+GJYs9z3tyTKqUxfJtDiuywc9zyM2yIjf6ZB97nsey57nxYzQUxH/8M40Y3xhjQwAAAABJRU5ErkJggg=="

# https://www.google.com/favicon.ico
# https://github.com/Heptazhou/Firefox/blob/FIREFOX_NIGHTLY_128_END/browser/components/search/extensions/google/favicon.ico
const icon_goog = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAFZUlEQVRYR71XDUyUdRj/vXdyBwfHyYeKimlEIYSDpCI/ckxWWNmX9qG2liaZpUtNc7SGZk6TOTdZthXoXE601mZbLWe6cIvBMChkls0MkJwf+I1yx3Fw9/b7v7738r7HwR2M9b89d++9/+f5Pb//8zz/LwlhNlmWY6k61+fzzZYkKYvPKRS7an6bvy3UaTSZTD/z+UfqiHchmxRKg6BpdFpEwAWUyFD6op82nZSDJLONNmcHsumXAAFsdLyZAKso5nAcB+oQo4eyk0Q2EKMzGEZQAjR6gPIdjTKG4jgIkVPEmkf5J7CvDwE6nkr5icqJgcreSxfQdfwouhvq0dPaDF/7LRFvmGIdME9MgSVrKqz5c2AeP6EPb2JeJeaTlJP6TgMBdeTVgc69ly/CWfYZuqoqFYcDNkmCdUYeopevgjlpnEFVJTFdHwmNADujKb8Ght197DA6Sksgu4OmsF8uUpQN9rUfwZr3RCAJkY5cf01oBLxe7w4Wy/t6bdfXX8G5+/Mhl0FkwVzYP9jQx57Fvd1sNq8XHQoBMdUof+qrXYz8TsnHQZ2PSEmF5dHpMI8dTwQJ3osX4KmrQU9T74yLfOZF2FcXKf3BZgd9pYtUKL0c/V6OfrFfURTbzcKFkLvcBlvhMIaglpzcoMQ89bW4s2MLrDPzELNi7YCRYxT2MAqFEkfuoFzWLzLO0vfg+qHWABCRngnH1lJIdv/iFxxfdjkh2aJDpo0+XfSZJAgsonaF30LubIa3KgOuyrHoqh+lvDbFJyCu/ABMjriQwINUWCAx/LsZ/qV+Q9+5T+Fr2qj89fw1Eq7DExGzaiNEQQ13YxrKJH7VMRQPa/n/vQDyzeOaL9/tZFie/RsYMWK4/YviPyEIXCeBeD96TxVXMU+b5kwa8xLMmQf6dZ6/1Rk2seIXrMjL6B2IsjCRgIcEIjQCldzwZJ8GappUBNN9nwwLgaV5FiyarrkSEfD8rwRenxmBxbMs2mD8BK4xAgn9pmD0fJinHByWCCzPt+DlXEMElBQYi7BhDuQb3HTU1mZJx+gZvyHCNLgibLnqQ2G5cf/YOM+KWZMNNXAiyDQs4TQsVtwf6UpGyZ0srHtkJZ5PyQ+72ITiN7XdKKv0GGwqVtiQ5OhdmpVpyDwspJZW5nLnObhrMrCzIwOH3JMUgPhIBw4U7EBC5MiwSHS4ZSz5shM3nL1b9z2JJuxdFhVo/6ogEKsuxVrvztrNqGhtNChPjkvBrrxiOCwDL8XdXqD4Wzfqmvmga28z/68Y8y+W4jH+zWgPV8M3/fqXnFex4MgauHqMm1GSLRHrc97C4+Nygkbi7K1WlPxSi5Y/nmJ/7zEyPlrCvneiEGUxhL+cm9Ey/3Z8P6Nwmoy0CjnSWoXi2tKgjibFjse0pIcwISaJu62EK53X0XDlNBqvnYHMj9mdClvbSkg9d/eOTfMjMTOtlxB9davbcZP+QLKdUVin97j/zPcoPbkvrLwHKkleO6La3sWSnCzD3Bd6LL5tHP2H4ll/JLMpa7MkZerBjv5bjS11XzAdgzuSmXmSL0x/DYVTnjNwE5cX+niMouQ38FCaSoUadt7dh9V22XUNuxr349j5avhCHUppkzP6QazOfgOicPWN2G3EFofSZv/7YMfybCoeDSQhDERxChJ1bafQ1H4eN7valUOyw2rHRPs4ZI+ajPzkaUiLu7dP2lTnBcQ1TK/+LiYiEoeoPGVIBRBgpIZdXEy0kfcbAX8HjaJYLJtotEY/OwZDSFQ7RZy2BY5xTqtA4VxOU9XL6UKC2MIhIM57lAo6LqFN00A2IQnoIiKWwKcDrucOtb+dv80i1Or1/DAdd4RD9j/w5nJL3xmBhgAAAABJRU5ErkJggg=="

# https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/query-stripping/records
# https://github.com/brave/brave-core/blob/74ad0c0a/browser/net/brave_site_hacks_network_delegate_helper.cc
# https://github.com/brave/brave-core/blob/master/browser/net/brave_query_filter.cc
# https://github.com/DandelionSprout/adfilt/blob/master/LegitimateURLShortener.txt
# https://github.com/Heptazhou/Heptazhou.github.io/blob/master/URLenc/main.js
# https://github.com/the1812/Bilibili-Evolved/blob/master/registry/lib/components/utils/url-params-clean/index.ts
const strip_list_msc =
	[
		"__cft__[0]"
		"__sale_info__"
		"__tn__"
		"_at_"
		"_cldee"
		"_f"
		"_ff"
		"_nc_sid"
		"_rand"
		"_ts"
		"_wv"
		"ab_channel"
		"accept_quality"
		"ad_od"
		"adpicid"
		"adsVersion"
		"ADTAG"
		"amp"
		"app_version"
		"appshare"
		"appsongtype"
		"apptime"
		"appuid"
		"bbid"
		"bddid"
		"bdtype"
		"brand_redir"
		"broadcast_type"
		"bsft_clkid"
		"bsft_uid"
		"bsource"
		"buvid"
		"ckanonid"
		"client"
		"comefrom"
		"comment_on"
		"comment_root_id"
		"curator_clanid"
		"current_qn"
		"current_quality"
		"device_id"
		"device_type"
		"dm_progress"
		"dmid"
		"embeds_origin"
		"embeds_referring_origin"
		"embeds_widget_referrer"
		"enctid"
		"eqid"
		"esid"
		"euid"
		"euri"
		"fclid"
		"feature"
		"featurecode"
		"from_id"
		"from_idtype"
		"from_module"
		"from_name"
		"from_source"
		"from_spmid"
		"fromid"
		"fromtitle"
		"fromTitle"
		"fromurl"
		"game_version"
		"gbv"
		"group_id"
		"gsm"
		"hosteuin"
		"ig_cache_key"
		"inputT"
		"ipn"
		"is_reflow"
		"is_room_feed"
		"is_story_h5"
		"isappinstalled"
		"islist"
		"issp"
		"jid"
		"keywords"
		"lemmaIdFrom"
		"lfid"
		"live_from"
		"live_play_network"
		"lpsn"
		"luicode"
		"media_mid"
		"mktgSourceCode"
		"mpshare"
		"msource"
		"network_id"
		"network_status"
		"network"
		"newreg"
		"oid"
		"orgRef"
		"orig_msid"
		"oriquery"
		"p2p_type"
		"paipv"
		"pic_share_from"
		"pid"
		"plat_id"
		"platform_network_status"
		"platform"
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
		"rawFrom"
		"rdfrom"
		"recipientid"
		"refer_flag"
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
		"sca_esv"
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
		"share"
		"sharefrom"
		"sharer_shareid"
		"sharer_sharetime"
		"sid"
		"sigin"
		"simid"
		"sme"
		"source"
		"sourcecode"
		"sourceFrom"
		"sourceType"
		"spm_id_from"
		"spmref"
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
		"starNodeId"
		"suglabid"
		"suguuid"
		"tdsourcetag"
		"teclient"
		"timestamp"
		"treatmentID"
		"ts"
		"tt_from"
		"uct"
		"ufe"
		"uk"
		"unique_k"
		"up_id"
		"userCode"
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
		"utrc"
		"vd_source"
		"ved"
		"visit_id"
		"weibo_id"
		"wfr"
		"wid"
		"wvr"
		"wxa_abtest"
		"wxfid"
		"wxshare_count"
		"xhsshare"
	]

# LegitimateURLShortener
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
		"fromModule"
		"gbraid"
		"gclid"
		"gclsrc"
		"guccounter"
		"guce_referrer_sig"
		"guce_referrer"
		"hsCtaTracking"
		"igshid"
		"lemmaFrom"
		"lpn"
		"mc_cid"
		"mc_eid"
		"mkt_tok"
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
		"scm_id"
		"scm-url"
		"scm"
		"spm"
		"src_content"
		"src_custom"
		"srsltid"
		"sudaref"
		"twclid"
		"vero_conv"
		"vero_id"
		"vgo_ee"
		"wbraid"
		"wickedid"
		"yclid"
		"ysclid"
	]

# Exemption
const strip_list_xpt =
	[
		"cid"  #* Azure DevOps Services
		"from" #* Zoom SSO
	]

const strip_list = String[strip_list_msc; strip_list_ubo]

