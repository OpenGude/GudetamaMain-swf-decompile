package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RecipeNoteData
   {
       
      
      public var id#2:int;
      
      public var visible:Boolean;
      
      public var available:Boolean;
      
      public var purchased:Boolean;
      
      public var targetValue:int;
      
      public var currentValue:int;
      
      public function RecipeNoteData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         visible = param1.readBoolean();
         available = param1.readBoolean();
         purchased = param1.readBoolean();
         targetValue = param1.readInt();
         currentValue = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeBoolean(visible);
         param1.writeBoolean(available);
         param1.writeBoolean(purchased);
         param1.writeInt(targetValue);
         param1.writeInt(currentValue);
      }
   }
}
