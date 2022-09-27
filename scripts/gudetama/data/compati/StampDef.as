package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class StampDef
   {
      
      public static const RARE_NONE:int = 0;
      
      public static const RARE_AUTO:int = 1;
      
      public static const RARE_MANUAL:int = 2;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var privately:Boolean;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var conditionDesc:String;
      
      public var price:ItemParam;
      
      public var isNew:Boolean;
      
      public var rare:int;
      
      public var isSpine:Boolean;
      
      public var homeStampSettingId:int;
      
      public function StampDef()
      {
         super();
      }
      
      public function isRare() : Boolean
      {
         return rare == 1 || rare == 2;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         privately = param1.readBoolean();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         conditionDesc = param1.readUTF();
         price = CompatibleDataIO.read(param1) as ItemParam;
         isNew = param1.readBoolean();
         rare = param1.readInt();
         isSpine = param1.readBoolean();
         homeStampSettingId = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeBoolean(privately);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeUTF(conditionDesc);
         CompatibleDataIO.write(param1,price);
         param1.writeBoolean(isNew);
         param1.writeInt(rare);
         param1.writeBoolean(isSpine);
         param1.writeInt(homeStampSettingId);
      }
   }
}
