package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class KitchenwareDef
   {
      
      public static const TYPE_BOARD:int = 0;
      
      public static const TYPE_PAN:int = 1;
      
      public static const TYPE_POT:int = 2;
      
      public static const TYPE_OVEN:int = 3;
      
      public static const TYPE_EVENT:int = 4;
      
      public static const TYPE_NUM:int = 5;
      
      public static const LAYER_BACK:int = 0;
      
      public static const LAYER_FRONT:int = 1;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var type:int;
      
      public var grade:int;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var recipeNoteIds:Array;
      
      public var conditionDesc:String;
      
      public var existsImage:Boolean;
      
      public var bgPos:Array;
      
      public var materialLayer:int;
      
      public var eventIds:Array;
      
      public function KitchenwareDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         type = param1.readInt();
         grade = param1.readInt();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         recipeNoteIds = CompatibleDataIO.read(param1) as Array;
         conditionDesc = param1.readUTF();
         existsImage = param1.readBoolean();
         bgPos = CompatibleDataIO.read(param1) as Array;
         materialLayer = param1.readInt();
         eventIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeInt(type);
         param1.writeInt(grade);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         CompatibleDataIO.write(param1,recipeNoteIds,2);
         param1.writeUTF(conditionDesc);
         param1.writeBoolean(existsImage);
         CompatibleDataIO.write(param1,bgPos,2);
         param1.writeInt(materialLayer);
         CompatibleDataIO.write(param1,eventIds,2);
      }
   }
}
