package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ComicDef
   {
       
      
      public var id#2:int;
      
      public var rsrcs:Array;
      
      public var comicSpine:Array;
      
      public function ComicDef()
      {
         super();
      }
      
      public function getComicSpine(param1:int) : ComicSpineDef
      {
         if(!comicSpine)
         {
            return null;
         }
         if(param1 >= comicSpine.length)
         {
            return null;
         }
         return comicSpine[param1];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrcs = CompatibleDataIO.read(param1) as Array;
         comicSpine = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,rsrcs,2);
         CompatibleDataIO.write(param1,comicSpine,1);
      }
   }
}
