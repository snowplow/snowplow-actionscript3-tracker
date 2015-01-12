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

package
{
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	public class Helpers
	{
		/**
		 *  Returns <code>true</code> if the object reference specified
		 *  is a simple data type. The simple data types include the following:
		 *  <ul>
		 *    <li><code>String</code></li>
		 *    <li><code>Number</code></li>
		 *    <li><code>uint</code></li>
		 *    <li><code>int</code></li>
		 *    <li><code>Boolean</code></li>
		 *    <li><code>Date</code></li>
		 *    <li><code>Array</code></li>
		 *  </ul>
		 *
		 *  @param value Object inspected.
		 *
		 *  @return <code>true</code> if the object specified
		 *  is one of the types above; <code>false</code> otherwise.
		 */
		public static function isSimple(value:Object):Boolean
		{
			var type:String = typeof(value);
			switch (type)
			{
				case "number":
				case "string":
				case "boolean":
				{
					return true;
				}
					
				case "object":
				{
					return (value is Date) || (value is Array);
				}
			}
			
			return false;
		}
		
		public static function getItemIndex (array:Array, obj:*):int
		{
			for (var i:int = 0; i < array.length ; i++)
			{
				if (array[i] == obj)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		public static function compareObjects (o1:*, o2:*, excludedFields:Array = null):Boolean
		{
			if (o1 == null && o2 == null)
			{
				return true;
			}
			else if (o1 == null || o2 == null)
			{
				return false;
			}
			else if (flash.utils.getQualifiedClassName(o1) == flash.utils.getQualifiedClassName(o2))
			{
				if (o1 is Number)
				{
					if (isNaN(o1) && isNaN(o2))
					{
						return true;
					}
				}
				
				if (o1 is Array)
				{
					if ((o1 as Array).length != (o2 as Array).length)
					{
						return false;
					}
					else
					{
						for (var i:int=0;i<(o1 as Array).length;i++)
						{
							if (!compareObjects((o1 as Array)[i], (o2 as Array)[i]))
							{
								return false;
							}
						}
						return true;
					}
				}
				else if (isSimple(o1))
				{
					return o1 == o2;
				}
				else if (o1 is XML)
				{
					return (o1 as XML).toXMLString() == (o2 as XML).toXMLString();
				}
				else
				{
					var type:XML = describeType(o1);
					var variables:XMLList = type.child("variable");
					
					for each (var variable:XML in type.variable)
					{
						if (excludedFields == null || getItemIndex(excludedFields, variable.@name) < 0)
						{
							if (!compareObjects(o1[variable.@name], o2[variable.@name]))
							{
								return false;
							}
						}
					}
					
					for each (var accessor:XML in type.accessor)
					{
						if(accessor.@access == "readwrite") 
						{
							if (excludedFields == null || getItemIndex(excludedFields, variable.@name) < 0)
							{
								if (!compareObjects(o1[accessor.@name], o2[accessor.@name]))
								{
									return false;
								}
							}
						}
					}
					
					var p:*;
					
					for (p in o1)
					{
						if (o2.hasOwnProperty(p))
						{
							if (!compareObjects(o1[p], o2[p]))
							{
								return false;
							}
						}
						else
						{
							return false;
						}
					}
					
					for (p in o2)
					{
						if (o1.hasOwnProperty(p))
						{
							if (!compareObjects(o1[p], o2[p]))
							{
								return false;
							}
						}
						else
						{
							return false;
						}
					}
					
					
					return true;
				}
			}
			else
			{
				return false;
			}
		}

	}
}