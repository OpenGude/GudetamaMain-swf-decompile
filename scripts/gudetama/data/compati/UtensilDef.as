package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UtensilDef
   {
      
      public static const UTENSIL_PICTURE_BOOK:int = 1;
      
      public static const UTENSIL_TIMING_PLATE:int = 3;
      
      public static const UTENSIL_MICROWAVE:int = 4;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var conditionDesc:String;
      
      public var price:ItemParam;
      
      public var isNew:Boolean;
      
      public function UtensilDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         conditionDesc = param1.readUTF();
         price = CompatibleDataIO.read(param1) as ItemParam;
         isNew = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeUTF(conditionDesc);
         CompatibleDataIO.write(param1,price);
         param1.writeBoolean(isNew);
      }
   }
}
