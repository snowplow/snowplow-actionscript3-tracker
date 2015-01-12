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
	public dynamic class TransactionItem
	{
		public function TransactionItem(order_id:String, sku:String, price:Number, quantity:int, name:String,
										category:String, currency:String, context:Array = null)
		{
			put(Parameter.EVENT, "ti");
			put(Parameter.TI_ITEM_ID, order_id);
			put(Parameter.TI_ITEM_SKU, sku);
			put(Parameter.TI_ITEM_NAME, name);
			put(Parameter.TI_ITEM_CATEGORY, category);
			put(Parameter.TI_ITEM_PRICE, price);
			put(Parameter.TI_ITEM_QUANTITY, quantity);
			put(Parameter.TI_ITEM_CURRENCY, currency);
			
			put(Parameter.CONTEXT, context);
			
			put(Parameter.TIMESTAMP, Util.getTimestamp());
		}
		
		public function get(key:String):*
		{
			if (this.hasOwnProperty(key)) 
			{
				return this[key];
			}
			else
			{
				return null;
			}
		}
		
		public function put(key:String, value:*):* 
		{
			if (!Util.isNullOrEmpty(value)) 
			{
				var oldValue:* = null;
				if (this.hasOwnProperty(key)) {
					oldValue = this[key];
				}
				
				this[key] = value;
				
				return oldValue;
			}
			else
				return null;
		}
	}
}