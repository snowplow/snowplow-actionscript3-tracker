/*
* Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
*
* This program is licensed to you under the Apache License Version 2.0,
* and you may not use this file except in compliance with the Apache License Version 2.0.
* You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the Apache License Version 2.0 is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
*/

package com.snowplowanalytics.snowplow.tracker
{
	public class Parameter
	{
		// General
		public static const SCHEMA:String = "schema";
		public static const DATA:String = "data";
		public static const EVENT:String = "e";
		public static const EID:String = "eid";
		public static const TIMESTAMP:String = "dtm";
		public static const TRACKER_VERSION:String = "tv";
		public static const APPID:String = "aid";
		public static const NAMESPACE:String = "tna";
		
		public static const UID:String = "uid";
		public static const CONTEXT:String = "co";
		public static const CONTEXT_ENCODED:String = "cx";
		public static const UNSTRUCTURED:String = "ue_pr";
		public static const UNSTRUCTURED_ENCODED:String = "ue_px";
		
		// Subject class
		public static const PLATFORM:String = "p";
		public static const RESOLUTION:String = "res";
		public static const VIEWPORT:String = "vp";
		public static const DOCUMENT_SIZE:String = "ds";
		public static const VISIT_COUNT:String = "vid";
		public static const DOMAIN_USER_ID:String = "duid";
		public static const USER_FINGERPRINT:String = "fp";
		public static const COLOR_DEPTH:String = "cd";
		public static const TIMEZONE:String = "tz";
		public static const LANGUAGE:String = "lang";

		//Flash specific subject
		public static const SHARED_OBJECT_VISIT_COUNT:String = "domainSessionIndex";
		public static const SHARED_OBJECT_DOMAIN_USER_ID:String = "domainUserId";
		public static const SHARED_OBJECT_USER_FINGERPRINT:String = "userFingerprint";

		// Page View
		public static const PAGE_URL:String = "url";
		public static const PAGE_TITLE:String = "page";
		public static const PAGE_REFR:String = "refr";
		
		// Structured Event
		public static const SE_CATEGORY:String = "se_ca";
		public static const SE_ACTION:String = "se_ac";
		public static const SE_LABEL:String = "se_la";
		public static const SE_PROPERTY:String = "se_pr";
		public static const SE_VALUE:String = "se_va";
		
		// Ecomm Transaction
		public static const TR_ID:String = "tr_id";
		public static const TR_TOTAL:String = "tr_tt";
		public static const TR_AFFILIATION:String = "tr_af";
		public static const TR_TAX:String = "tr_tx";
		public static const TR_SHIPPING:String = "tr_sh";
		public static const TR_CITY:String = "tr_ci";
		public static const TR_STATE:String = "tr_st";
		public static const TR_COUNTRY:String = "tr_co";
		public static const TR_CURRENCY:String = "tr_cu";
		
		// Transaction Item
		public static const TI_ITEM_ID:String = "ti_id";
		public static const TI_ITEM_SKU:String = "ti_sk";
		public static const TI_ITEM_NAME:String = "ti_nm";
		public static const TI_ITEM_CATEGORY:String = "ti_ca";
		public static const TI_ITEM_PRICE:String = "ti_pr";
		public static const TI_ITEM_QUANTITY:String = "ti_qu";
		public static const TI_ITEM_CURRENCY:String = "ti_cu";
		
		// Screen View
		public static const SV_ID:String = "id";
		public static const SV_NAME:String = "name";
		
		// Flash Context
		public static const FLASH_PLAYER_TYPE:String = "playerType";
		public static const FLASH_VERSION:String = "version";
		public static const FLASH_STAGE_SIZE:String = "stageSize";
		public static const FLASH_IS_DEBUGGER:String = "isDebugger";
		public static const FLASH_HAS_LOCAL_STORAGE:String = "hasLocalStorage";
		public static const FLASH_HAS_SCRIPT_ACCESS:String = "hasScriptAccess";
		
	}
}