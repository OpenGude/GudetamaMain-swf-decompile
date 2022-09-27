package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RecipeNoteDef
   {
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var kitchenwareId:int;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var minutes:int;
      
      public var premises:Array;
      
      public var conditionDesc:String;
      
      public var eventId:int;
      
      public var price:int;
      
      public var defaults:Array;
      
      public var appends:Array;
      
      public var happeningIds:Array;
      
      public var failureIds:Array;
      
      public var hasBonusPrize:Boolean;
      
      public var targetType:int;
      
      public var targetId:int;
      
      public function RecipeNoteDef()
      {
         super();
      }
      
      public function existsInRecipe(param1:int) : Boolean
      {
         for each(var _loc2_ in defaults)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         for each(_loc2_ in appends)
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
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         kitchenwareId = param1.readInt();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         minutes = param1.readInt();
         premises = CompatibleDataIO.read(param1) as Array;
         conditionDesc = param1.readUTF();
         eventId = param1.readInt();
         price = param1.readInt();
         defaults = CompatibleDataIO.read(param1) as Array;
         appends = CompatibleDataIO.read(param1) as Array;
         happeningIds = CompatibleDataIO.read(param1) as Array;
         failureIds = CompatibleDataIO.read(param1) as Array;
         hasBonusPrize = param1.readBoolean();
         targetType = param1.readInt();
         targetId = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeInt(kitchenwareId);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeInt(minutes);
         CompatibleDataIO.write(param1,premises,2);
         param1.writeUTF(conditionDesc);
         param1.writeInt(eventId);
         param1.writeInt(price);
         CompatibleDataIO.write(param1,defaults,2);
         CompatibleDataIO.write(param1,appends,2);
         CompatibleDataIO.write(param1,happeningIds,2);
         CompatibleDataIO.write(param1,failureIds,2);
         param1.writeBoolean(hasBonusPrize);
         param1.writeInt(targetType);
         param1.writeInt(targetId);
      }
   }
}
