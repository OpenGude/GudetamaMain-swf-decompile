package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class PromotionInterstitialSettingDef
   {
       
      
      public var id#2:int;
      
      public var allowCountriyCodes:Array;
      
      public var allowCountryLocales:Array;
      
      public var imageIDs:Array;
      
      public var visible:Boolean;
      
      public var startTimeSecs:int;
      
      public var limitTimeSecs:int;
      
      public var endTimeStr:String;
      
      public var browserType:int;
      
      public var webURL:Array;
      
      public var rate:int;
      
      public var intervalSec:int;
      
      public function PromotionInterstitialSettingDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         allowCountriyCodes = CompatibleDataIO.read(param1) as Array;
         allowCountryLocales = CompatibleDataIO.read(param1) as Array;
         imageIDs = CompatibleDataIO.read(param1) as Array;
         visible = param1.readBoolean();
         startTimeSecs = param1.readInt();
         limitTimeSecs = param1.readInt();
         endTimeStr = param1.readUTF();
         browserType = param1.readByte();
         webURL = CompatibleDataIO.read(param1) as Array;
         rate = param1.readInt();
         intervalSec = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,allowCountriyCodes,2);
         CompatibleDataIO.write(param1,allowCountryLocales,1);
         CompatibleDataIO.write(param1,imageIDs,1);
         param1.writeBoolean(visible);
         param1.writeInt(startTimeSecs);
         param1.writeInt(limitTimeSecs);
         param1.writeUTF(endTimeStr);
         param1.writeByte(browserType);
         CompatibleDataIO.write(param1,webURL,1);
         param1.writeInt(rate);
         param1.writeInt(intervalSec);
      }
   }
}
