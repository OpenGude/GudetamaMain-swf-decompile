package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GudetamaData
   {
      
      public static const GUDETAMA_MAX:int = 999;
       
      
      public var id#2:int;
      
      public var count:int;
      
      public var num:int;
      
      public var unlockedVoiceIndex:int;
      
      public var available:Boolean;
      
      public var unlocked:Boolean;
      
      public var alreadyChallenge:Boolean;
      
      public var cookedHappening:Boolean;
      
      public var cookedFailure:Boolean;
      
      public var targetValue:int;
      
      public var currentValue:int;
      
      public var currentTarget:int;
      
      public function GudetamaData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         count = param1.readShort();
         num = param1.readShort();
         unlockedVoiceIndex = param1.readByte();
         available = param1.readBoolean();
         unlocked = param1.readBoolean();
         alreadyChallenge = param1.readBoolean();
         cookedHappening = param1.readBoolean();
         cookedFailure = param1.readBoolean();
         targetValue = param1.readInt();
         currentValue = param1.readInt();
         currentTarget = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeShort(count);
         param1.writeShort(num);
         param1.writeByte(unlockedVoiceIndex);
         param1.writeBoolean(available);
         param1.writeBoolean(unlocked);
         param1.writeBoolean(alreadyChallenge);
         param1.writeBoolean(cookedHappening);
         param1.writeBoolean(cookedFailure);
         param1.writeInt(targetValue);
         param1.writeInt(currentValue);
         param1.writeInt(currentTarget);
      }
   }
}
