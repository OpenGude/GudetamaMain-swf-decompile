package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class CupGachaDef
   {
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var rarity:int;
      
      public var prizes:Array;
      
      public var oddses:Array;
      
      public var cookMin:int;
      
      public var price:ItemParam;
      
      public var isNew:Boolean;
      
      public var conditionDesc:String;
      
      public var sortIndex:int;
      
      public var enableCountryFlags:Array;
      
      public var missionCommonID:int;
      
      public function CupGachaDef()
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
         rarity = param1.readByte();
         prizes = CompatibleDataIO.read(param1) as Array;
         oddses = CompatibleDataIO.read(param1) as Array;
         cookMin = param1.readInt();
         price = CompatibleDataIO.read(param1) as ItemParam;
         isNew = param1.readBoolean();
         conditionDesc = param1.readUTF();
         sortIndex = param1.readInt();
         enableCountryFlags = CompatibleDataIO.read(param1) as Array;
         missionCommonID = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeByte(rarity);
         CompatibleDataIO.write(param1,prizes,1);
         CompatibleDataIO.write(param1,oddses,2);
         param1.writeInt(cookMin);
         CompatibleDataIO.write(param1,price);
         param1.writeBoolean(isNew);
         param1.writeUTF(conditionDesc);
         param1.writeInt(sortIndex);
         CompatibleDataIO.write(param1,enableCountryFlags,2);
         param1.writeInt(missionCommonID);
      }
   }
}
