package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class PromotionVideoDef
   {
       
      
      public var id#2:int;
      
      public var movie:int;
      
      public var endcard:int;
      
      public var landscape:Boolean;
      
      public var urlApple:String;
      
      public var urlGoogle:String;
      
      public var link:String;
      
      public var locales:Array;
      
      public function PromotionVideoDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         movie = param1.readInt();
         endcard = param1.readInt();
         landscape = param1.readBoolean();
         urlApple = param1.readUTF();
         urlGoogle = param1.readUTF();
         link = param1.readUTF();
         locales = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(movie);
         param1.writeInt(endcard);
         param1.writeBoolean(landscape);
         param1.writeUTF(urlApple);
         param1.writeUTF(urlGoogle);
         param1.writeUTF(link);
         CompatibleDataIO.write(param1,locales,1);
      }
   }
}
