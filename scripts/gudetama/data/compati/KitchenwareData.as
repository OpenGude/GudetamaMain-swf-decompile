package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class KitchenwareData
   {
      
      public static const TARGET_SUCCESS:int = 0;
      
      public static const TARGET_HAPPENING:int = 1;
       
      
      public var type:int;
      
      public var paramMap:Object;
      
      public var recipeNoteId:int;
      
      public var gudetamaId:int;
      
      public var restTimeSecs:int;
      
      public var assistUsefulIds:Array;
      
      public var assistEncodedUids:Array;
      
      public var target:int;
      
      public function KitchenwareData()
      {
         super();
      }
      
      public function isCooking() : Boolean
      {
         return recipeNoteId > 0;
      }
      
      public function existsUsefulIdInAssist(param1:int) : Boolean
      {
         if(!assistUsefulIds)
         {
            return false;
         }
         for each(var _loc2_ in assistUsefulIds)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         type = param1.readInt();
         _loc2_ = uint(param1.readShort());
         paramMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            paramMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         recipeNoteId = param1.readInt();
         gudetamaId = param1.readInt();
         restTimeSecs = param1.readInt();
         assistUsefulIds = CompatibleDataIO.read(param1) as Array;
         assistEncodedUids = CompatibleDataIO.read(param1) as Array;
         target = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(type);
         CompatibleDataIO.write(param1,paramMap,7);
         param1.writeInt(recipeNoteId);
         param1.writeInt(gudetamaId);
         param1.writeInt(restTimeSecs);
         CompatibleDataIO.write(param1,assistUsefulIds,2);
         CompatibleDataIO.write(param1,assistEncodedUids,2);
         param1.writeInt(target);
      }
   }
}
