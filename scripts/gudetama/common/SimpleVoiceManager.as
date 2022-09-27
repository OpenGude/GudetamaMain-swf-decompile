package gudetama.common
{
   import flash.utils.Dictionary;
   import gudetama.engine.SoundManager;
   
   public class SimpleVoiceManager
   {
       
      
      private var showCallback:Function;
      
      private var hideCallback:Function;
      
      private var paramIndex:int;
      
      private var soundParamMap:Dictionary;
      
      private var soundParamKeys:Array;
      
      private var id:int;
      
      private var path:String;
      
      public function SimpleVoiceManager(param1:Function = null, param2:Function = null)
      {
         soundParamMap = new Dictionary();
         soundParamKeys = [];
         super();
         this.showCallback = param1;
         this.hideCallback = param2;
      }
      
      public function playVoice(param1:int, param2:String) : void
      {
         id = param1;
         path = param2;
         paramIndex = -1;
         stopVoice();
         nextVoice();
      }
      
      private function nextVoice() : Boolean
      {
         if(!path)
         {
            return false;
         }
         _playVoice(id);
         if(showCallback)
         {
            showCallback();
         }
         return true;
      }
      
      private function _playVoice(param1:int) : void
      {
         var id:int = param1;
         SoundManager.playVoice(path,true,0,0,function(param1:*):void
         {
            soundParamMap[param1] = [id];
            soundParamKeys.push(param1);
         });
      }
      
      public function updateVoice() : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:* = undefined;
         var _loc1_:* = null;
         if(!soundParamMap)
         {
            return false;
         }
         if(soundParamKeys.length > 0)
         {
            _loc3_ = soundParamKeys.length - 1;
            while(_loc3_ >= 0)
            {
               _loc2_ = soundParamKeys[_loc3_];
               if(!SoundManager.isPlayingVoice(_loc2_))
               {
                  _loc1_ = soundParamMap[_loc2_];
                  for(var _loc4_ in _loc2_)
                  {
                     delete _loc2_[_loc4_];
                  }
                  delete soundParamMap[_loc2_];
                  soundParamKeys.removeAt(_loc3_);
                  if(hideCallback)
                  {
                     hideCallback(_loc1_[0]);
                  }
               }
               _loc3_--;
            }
         }
         return true;
      }
      
      private function stopVoice() : void
      {
         var _loc2_:int = 0;
         var _loc1_:* = undefined;
         if(!soundParamMap)
         {
            return;
         }
         _loc2_ = soundParamKeys.length - 1;
         while(_loc2_ >= 0)
         {
            _loc1_ = soundParamKeys[_loc2_];
            SoundManager.stopVoice(_loc1_);
            for(var _loc3_ in _loc1_)
            {
               delete _loc1_[_loc3_];
            }
            delete soundParamMap[_loc1_];
            soundParamKeys.removeAt(_loc2_);
            _loc2_--;
         }
         soundParamKeys.length = 0;
      }
      
      public function dispose() : void
      {
         stopVoice();
         soundParamMap = null;
      }
   }
}
