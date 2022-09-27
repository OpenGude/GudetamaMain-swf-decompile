package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class Packet
   {
      
      public static const HEADER_SIZE:int = 4;
       
      
      public var type:int;
      
      public var time:int;
      
      public var payloadInt:Array;
      
      public var payloadObj0:Object;
      
      public var payloadObj1:Object;
      
      public var payloadExtra:Array;
      
      public var sequence:int;
      
      public var relogin:Boolean;
      
      public var receivedTime:int;
      
      public function Packet()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         type = param1.readInt();
         time = param1.readInt();
         payloadInt = CompatibleDataIO.read(param1) as Array;
         payloadObj0 = CompatibleDataIO.read(param1) as Object;
         payloadObj1 = CompatibleDataIO.read(param1) as Object;
         payloadExtra = CompatibleDataIO.read(param1) as Array;
         sequence = param1.readShort();
         relogin = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(type);
         param1.writeInt(time);
         CompatibleDataIO.write(param1,payloadInt,2);
         CompatibleDataIO.write(param1,payloadObj0);
         CompatibleDataIO.write(param1,payloadObj1);
         CompatibleDataIO.write(param1,payloadExtra,1);
         param1.writeShort(sequence);
         param1.writeBoolean(relogin);
      }
   }
}
