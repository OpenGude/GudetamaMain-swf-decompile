package gudetama.common
{
   import flash.utils.Dictionary;
   import gudetama.data.compati.VoiceDef;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import muku.core.MukuGlobal;
   
   public class VoiceManager
   {
       
      
      private var showCallback:Function;
      
      private var hideCallback:Function;
      
      private var voiceDef:VoiceDef;
      
      private var paramIndex:int;
      
      private var delayedVoicesMap:Dictionary;
      
      private var delayedVoicesKeys:Array;
      
      private var soundParamMap:Dictionary;
      
      private var soundParamKeys:Array;
      
      public function VoiceManager(param1:Function = null, param2:Function = null)
      {
         delayedVoicesMap = new Dictionary();
         delayedVoicesKeys = [];
         soundParamMap = new Dictionary();
         soundParamKeys = [];
         super();
         this.showCallback = param1;
         this.hideCallback = param2;
      }
      
      public static function getPaths(param1:VoiceDef) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            if(_loc5_ = param1.getResources(_loc4_))
            {
               for each(var _loc2_ in _loc5_)
               {
                  _loc3_.push(MukuGlobal.makePathFromVoiceName(param1.id#2,_loc2_));
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function getCombinedNames(param1:VoiceDef) : String
      {
         var _loc7_:int = 0;
         var _loc8_:* = null;
         var _loc2_:* = null;
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:* = null;
         var _loc4_:String = "";
         var _loc5_:int = param1.length;
         _loc7_ = 0;
         while(_loc7_ < _loc5_)
         {
            if(_loc8_ = param1.getResources(_loc7_))
            {
               _loc2_ = param1.getNames(_loc7_);
               _loc9_ = 0;
               while(_loc9_ < _loc8_.length)
               {
                  _loc3_ = _loc8_[_loc9_];
                  if(_loc3_ > 0)
                  {
                     _loc6_ = _loc2_ && _loc9_ < _loc2_.length ? _loc2_[_loc9_] : "";
                     if(_loc4_.length > 0)
                     {
                        _loc4_ += "\n";
                     }
                     _loc4_ += _loc6_;
                  }
                  _loc9_++;
               }
            }
            _loc7_++;
         }
         return _loc4_;
      }
      
      public function playVoice(param1:VoiceDef) : void
      {
         this.voiceDef = param1;
         paramIndex = -1;
         stopVoice();
         nextVoice();
      }
      
      private function nextVoice() : Boolean
      {
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:* = null;
         var _loc2_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:* = null;
         var _loc12_:* = 0;
         if(!voiceDef)
         {
            return false;
         }
         clearDelayedVoiceInfoMaps();
         var _loc8_:Array;
         if(!(_loc8_ = voiceDef.getResources(++paramIndex)))
         {
            return false;
         }
         var _loc1_:Array = voiceDef.getNames(paramIndex);
         var _loc6_:Array = voiceDef.getDelays(paramIndex);
         var _loc10_:Array = voiceDef.getPositions(paramIndex);
         var _loc4_:Array = voiceDef.getOffsets(paramIndex);
         _loc9_ = 0;
         while(_loc9_ < _loc8_.length)
         {
            _loc5_ = _loc8_[_loc9_];
            _loc7_ = _loc1_ && _loc9_ < _loc1_.length ? _loc1_[_loc9_] : "";
            _loc2_ = _loc6_ && _loc9_ < _loc6_.length ? _loc6_[_loc9_] : 0;
            _loc11_ = _loc10_ && _loc9_ < _loc10_.length ? _loc10_[_loc9_] : 0;
            _loc3_ = _loc4_ && _loc9_ < _loc4_.length ? _loc4_[_loc9_] : null;
            if(_loc2_ <= 0 || !delayedVoicesMap)
            {
               _playVoice(voiceDef.id#2,_loc5_,_loc7_,_loc11_);
               if(showCallback)
               {
                  showCallback(_loc7_,_loc11_,_loc3_);
               }
            }
            else
            {
               _loc12_ = uint(Engine.now + _loc2_);
               if(delayedVoicesMap[_loc12_])
               {
                  delayedVoicesMap[_loc12_].push({
                     "resource":_loc5_,
                     "name":_loc7_,
                     "position":_loc11_,
                     "offset":_loc3_
                  });
               }
               else
               {
                  delayedVoicesMap[_loc12_] = [{
                     "resource":_loc5_,
                     "name":_loc7_,
                     "position":_loc11_,
                     "offset":_loc3_
                  }];
                  delayedVoicesKeys.push(_loc12_);
               }
            }
            _loc9_++;
         }
         return true;
      }
      
      private function _playVoice(param1:int, param2:int, param3:String, param4:int) : void
      {
         var id:int = param1;
         var rsrc:int = param2;
         var name:String = param3;
         var position:int = param4;
         SoundManager.playVoice(MukuGlobal.makePathFromVoiceName(id,rsrc),true,0,0,function(param1:*):void
         {
            soundParamMap[param1] = [name,position];
            soundParamKeys.push(param1);
         });
      }
      
      public function updateVoice() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc5_:* = null;
         var _loc1_:* = undefined;
         var _loc4_:* = null;
         if(!delayedVoicesMap || !soundParamMap)
         {
            return false;
         }
         if(delayedVoicesKeys.length > 0)
         {
            _loc2_ = delayedVoicesKeys.length - 1;
            while(_loc2_ >= 0)
            {
               _loc3_ = uint(delayedVoicesKeys[_loc2_]);
               if(Engine.now >= _loc3_)
               {
                  _loc5_ = delayedVoicesMap[_loc3_];
                  for each(var _loc7_ in _loc5_)
                  {
                     _playVoice(voiceDef.id#2,_loc7_.resource,_loc7_.name,_loc7_.position);
                     if(showCallback)
                     {
                        showCallback(_loc7_.name,_loc7_.position,_loc7_.offset);
                     }
                  }
                  delayedVoicesKeys.removeAt(_loc2_);
               }
               _loc2_--;
            }
         }
         if(soundParamKeys.length > 0)
         {
            _loc2_ = soundParamKeys.length - 1;
            while(_loc2_ >= 0)
            {
               _loc1_ = soundParamKeys[_loc2_];
               if(!SoundManager.isPlayingVoice(_loc1_))
               {
                  _loc4_ = soundParamMap[_loc1_];
                  for(var _loc6_ in _loc1_)
                  {
                     delete _loc1_[_loc6_];
                  }
                  delete soundParamMap[_loc1_];
                  soundParamKeys.removeAt(_loc2_);
                  if(hideCallback)
                  {
                     hideCallback(_loc4_[0],_loc4_[1]);
                  }
               }
               _loc2_--;
            }
            if(delayedVoicesKeys.length + soundParamKeys.length <= 0)
            {
               return nextVoice();
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
      
      private function clearDelayedVoiceInfoMaps() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         var _loc3_:* = null;
         if(!delayedVoicesMap)
         {
            return;
         }
         _loc1_ = delayedVoicesKeys.length - 1;
         while(_loc1_ >= 0)
         {
            _loc2_ = uint(delayedVoicesKeys[_loc1_]);
            _loc3_ = delayedVoicesMap[_loc2_];
            for each(var _loc5_ in _loc3_)
            {
               for(var _loc4_ in _loc5_)
               {
                  delete _loc5_[_loc4_];
               }
            }
            _loc3_.length = 0;
            delete delayedVoicesMap[_loc2_];
            delayedVoicesKeys.removeAt(_loc1_);
            _loc1_--;
         }
         delayedVoicesKeys.length = 0;
      }
      
      public function dispose() : void
      {
         voiceDef = null;
         clearDelayedVoiceInfoMaps();
         delayedVoicesMap = null;
         stopVoice();
         soundParamMap = null;
      }
   }
}
