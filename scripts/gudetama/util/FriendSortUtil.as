package gudetama.util
{
   public final class FriendSortUtil
   {
      
      public static const ORDER_ASCENDING:int = 1;
      
      public static const ORDER_DESCENDING:int = 2;
      
      public static const SORTTYPE_FRIENDLY:int = 0;
      
      public static const SORTTYPE_LEVEL:int = 1;
      
      public static const SORTTYPE_NAME:int = 2;
      
      public static const SORTTYPE_LAST_ACTIVE:int = 3;
      
      public static const SORTTYPE_MAX:int = 4;
      
      private static const defaultCompareFunctions:Array = [function():*
      {
         var compareFriendly:Function;
         return compareFriendly = function(param1:CompareData, param2:CompareData):int
         {
            return param1.friendly - param2.friendly;
         };
      }(),function():*
      {
         var compareLevel:Function;
         return compareLevel = function(param1:CompareData, param2:CompareData):int
         {
            return param1.level - param2.level;
         };
      }(),function():*
      {
         var compareName:Function;
         return compareName = function(param1:CompareData, param2:CompareData):int
         {
            if(param1.name#2 == param2.name#2)
            {
               return 0;
            }
            return param1.name#2 < param2.name#2 ? 1 : -1;
         };
      }(),function():*
      {
         var compareLastActive:Function;
         return compareLastActive = function(param1:CompareData, param2:CompareData):int
         {
            return -(param1.lastActiveSec - param2.lastActiveSec);
         };
      }()];
      
      private static const compareListData:Vector.<CompareData> = new Vector.<CompareData>();
       
      
      public function FriendSortUtil()
      {
         super();
      }
      
      public static function dispose() : void
      {
         compareListData.length = 0;
      }
      
      public static function processSort(param1:Vector.<Object>, param2:Boolean, param3:int) : Vector.<Object>
      {
         var sources:Vector.<Object> = param1;
         var orderDescending:Boolean = param2;
         var sortCategory:int = param3;
         var cmpLen:int = compareListData.length;
         var cmpCount:int = 0;
         sources.forEach(function(param1:Object, param2:int, param3:Vector.<Object>):void
         {
            if(cmpLen <= cmpCount)
            {
               compareListData.push(new CompareData(param1));
            }
            else
            {
               compareListData[cmpCount].setup(param1);
            }
            cmpCount++;
         });
         var workCompareList:Vector.<CompareData> = compareListData.slice(0,cmpCount);
         var compares:Array = [];
         compares = defaultCompareFunctions.concat();
         compares.removeAt(sortCategory);
         compares.unshift(defaultCompareFunctions[sortCategory]);
         if(orderDescending)
         {
            workCompareList.sort(function(param1:CompareData, param2:CompareData):int
            {
               var _loc3_:int = 0;
               for each(var _loc4_ in compares)
               {
                  _loc3_ = _loc4_(param2,param1);
                  if(_loc3_ != 0)
                  {
                     return _loc3_;
                  }
               }
               return 0;
            });
         }
         else
         {
            workCompareList.sort(function(param1:CompareData, param2:CompareData):int
            {
               var _loc3_:int = 0;
               for each(var _loc4_ in compares)
               {
                  _loc3_ = _loc4_(param1,param2);
                  if(_loc3_ != 0)
                  {
                     return _loc3_;
                  }
               }
               return 0;
            });
         }
         var count:int = 0;
         cmpLen = sources.length;
         while(cmpLen > count)
         {
            var data:CompareData = workCompareList[count];
            sources[count] = data.source#2;
            count++;
         }
         return sources;
      }
      
      public static function processCopyAndSort(param1:Array, param2:Boolean, param3:int) : Array
      {
         var sources:Array = param1;
         var orderDescending:Boolean = param2;
         var sortCategory:int = param3;
         var copy:Array = sources.concat();
         var cmpLen:int = compareListData.length;
         var cmpCount:int = 0;
         copy.forEach(function(param1:Object, param2:int, param3:Array):void
         {
            if(cmpLen <= cmpCount)
            {
               compareListData.push(new CompareData({"profile":param1}));
            }
            else
            {
               compareListData[cmpCount].setup({"profile":param1});
            }
            cmpCount++;
         });
         var workCompareList:Vector.<CompareData> = compareListData.slice(0,cmpCount);
         var compares:Array = [];
         compares = defaultCompareFunctions.concat();
         compares.removeAt(sortCategory);
         compares.unshift(defaultCompareFunctions[sortCategory]);
         if(orderDescending)
         {
            workCompareList.sort(function(param1:CompareData, param2:CompareData):int
            {
               var _loc3_:int = 0;
               for each(var _loc4_ in compares)
               {
                  _loc3_ = _loc4_(param2,param1);
                  if(_loc3_ != 0)
                  {
                     return _loc3_;
                  }
               }
               return 0;
            });
         }
         else
         {
            workCompareList.sort(function(param1:CompareData, param2:CompareData):int
            {
               var _loc3_:int = 0;
               for each(var _loc4_ in compares)
               {
                  _loc3_ = _loc4_(param1,param2);
                  if(_loc3_ != 0)
                  {
                     return _loc3_;
                  }
               }
               return 0;
            });
         }
         var count:int = 0;
         cmpLen = copy.length;
         while(cmpLen > count)
         {
            var data:CompareData = workCompareList[count];
            copy[count] = data.source#2.profile;
            count++;
         }
         return copy;
      }
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserProfileData;

class CompareData
{
    
   
   public var source#2:Object;
   
   public var friendly:int;
   
   public var level:int;
   
   public var name#2:String;
   
   public var lastActiveSec:int;
   
   function CompareData(param1:Object)
   {
      super();
      setup(param1);
   }
   
   public function setup(param1:Object) : void
   {
      this.source#2 = param1;
      var _loc2_:UserProfileData = param1.profile;
      friendly = UserDataWrapper.wrapper.getFriendly(_loc2_.encodedUid);
      level = _loc2_.playerRank;
      name#2 = _loc2_.playerName;
      lastActiveSec = _loc2_.lastActiveSec;
   }
   
   public function toString() : String
   {
      return "friendly : " + friendly + ", level : " + level + ", name : " + name#2 + ", lastActiveSec : " + lastActiveSec;
   }
}
