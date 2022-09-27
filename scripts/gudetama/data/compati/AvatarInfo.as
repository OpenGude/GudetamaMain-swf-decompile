package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class AvatarInfo
   {
       
      
      public var updateAvatars:Array;
      
      public var removeAvatarIds:Array;
      
      public function AvatarInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         updateAvatars = CompatibleDataIO.read(param1) as Array;
         removeAvatarIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,updateAvatars,1);
         CompatibleDataIO.write(param1,removeAvatarIds,2);
      }
   }
}
