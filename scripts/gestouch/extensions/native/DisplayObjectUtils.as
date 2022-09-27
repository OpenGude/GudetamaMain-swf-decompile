package gestouch.extensions.native
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.geom.Point;
   
   public class DisplayObjectUtils
   {
       
      
      public function DisplayObjectUtils()
      {
         super();
      }
      
      public static function getTopTarget(param1:Stage, param2:Point, param3:Boolean = true, param4:uint = 0) : InteractiveObject
      {
         var _loc7_:* = 0;
         var _loc10_:* = null;
         var _loc8_:* = null;
         var _loc5_:* = null;
         var _loc9_:Array;
         if(!(_loc9_ = param1.getObjectsUnderPoint(param2)).length)
         {
            return param1;
         }
         var _loc6_:int;
         if((_loc6_ = _loc9_.length - 1 - param4) < 0)
         {
            return param1;
         }
         _loc7_ = _loc6_;
         while(_loc7_ >= 0)
         {
            _loc10_ = _loc9_[_loc7_] as DisplayObject;
            while(_loc10_ != param1)
            {
               if(_loc10_ is InteractiveObject)
               {
                  if((_loc10_ as InteractiveObject).mouseEnabled)
                  {
                     if(param3)
                     {
                        _loc8_ = _loc10_ as InteractiveObject;
                        _loc5_ = _loc10_.parent;
                        while(_loc5_)
                        {
                           if(!_loc8_ && _loc5_.mouseEnabled)
                           {
                              _loc8_ = _loc5_;
                           }
                           else if(!_loc5_.mouseChildren)
                           {
                              if(_loc5_.mouseEnabled)
                              {
                                 _loc8_ = _loc5_;
                              }
                              else
                              {
                                 _loc8_ = null;
                              }
                           }
                           _loc5_ = _loc5_.parent;
                        }
                        if(_loc8_)
                        {
                           return _loc8_;
                        }
                        return param1;
                     }
                     return _loc10_ as InteractiveObject;
                  }
                  break;
               }
               _loc10_ = _loc10_.parent;
            }
            _loc7_--;
         }
         return param1;
      }
   }
}
