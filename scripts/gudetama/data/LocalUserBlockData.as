package gudetama.data
{
   import flash.errors.IOError;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   import gudetama.data.compati.UserProfileData;
   
   public class LocalUserBlockData implements IExternalizable
   {
      
      private static const VERSION:uint = 0;
       
      
      public var profiles:Array;
      
      public function LocalUserBlockData()
      {
         super();
         profiles = [];
      }
      
      public function reset() : void
      {
         profiles = [];
         DataStorage.saveUserBlockData(this);
      }
      
      private function getBlockIndex(param1:int) : int
      {
         var _loc2_:int = 0;
         if(profiles == null)
         {
            return -1;
         }
         while(_loc2_ < profiles.length)
         {
            if(UserProfileData(profiles[_loc2_]).encodedUid == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function containsBlock(param1:int) : Boolean
      {
         return getBlockIndex(param1) > -1;
      }
      
      public function addBlock(param1:UserProfileData) : void
      {
         var _loc2_:int = getBlockIndex(param1.encodedUid);
         if(_loc2_ == -1)
         {
            profiles.push(param1);
         }
         else
         {
            profiles[_loc2_] = param1;
         }
         DataStorage.saveUserBlockData(this);
      }
      
      public function removeBlock(param1:UserProfileData) : Boolean
      {
         var _loc2_:int = getBlockIndex(param1.encodedUid);
         if(_loc2_ == -1)
         {
            return false;
         }
         profiles.removeAt(_loc2_);
         DataStorage.saveUserBlockData(this);
         return true;
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc3_:int = 0;
         try
         {
            param1.writeByte(0);
            param1.writeUnsignedInt(DataStorage.getHashId());
            _loc2_ = profiles != null ? profiles.length : 0;
            param1.writeInt(_loc2_);
            while(_loc4_ < _loc2_)
            {
               _loc5_ = profiles[_loc4_];
               param1.writeInt(_loc5_.encodedUid);
               param1.writeUTF(_loc5_.playerName);
               param1.writeInt(_loc5_.playerRank);
               param1.writeInt(_loc5_.avatar);
               param1.writeInt(_loc5_.area);
               param1.writeInt(_loc5_.comment);
               _loc3_ = _loc5_.snsProfileImage != null ? _loc5_.snsProfileImage.length : 0;
               param1.writeInt(_loc3_);
               if(_loc3_ > 0)
               {
                  param1.writeBytes(_loc5_.snsProfileImage,0,_loc3_);
               }
               param1.writeByte(_loc5_.snsType);
               _loc4_++;
            }
         }
         catch(e:Error)
         {
            trace("LocalUserBlockData writeExternal reset ");
            reset();
         }
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         var _loc5_:int = 0;
         var _loc7_:* = null;
         var _loc4_:int = 0;
         var _loc6_:uint = param1.readByte();
         var _loc2_:* = param1.readUnsignedInt() != DataStorage.getHashId();
         if(_loc2_)
         {
            throw new IOError("LocalUserBlockData broken");
         }
         var _loc3_:int = param1.readInt();
         profiles = [];
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            (_loc7_ = new UserProfileData()).encodedUid = param1.readInt();
            _loc7_.playerName = param1.readUTF();
            _loc7_.playerRank = param1.readInt();
            _loc7_.avatar = param1.readInt();
            _loc7_.area = param1.readInt();
            _loc7_.comment = param1.readInt();
            if((_loc4_ = param1.readInt()) > 0)
            {
               _loc7_.snsProfileImage = new ByteArray();
               param1.readBytes(_loc7_.snsProfileImage,0,_loc4_);
            }
            _loc7_.snsType = param1.readByte();
            profiles.push(_loc7_);
            _loc5_++;
         }
      }
   }
}
