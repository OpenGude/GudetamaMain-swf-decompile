package muku.display
{
   import starling.display.DisplayObjectContainer;
   import starling.events.Event;
   
   public class EffectPlayerWrapper extends EffectPlayer
   {
      
      private static const WRAP_EVENT:String = "wrap_event";
       
      
      public var wrappee:EffectPlayer;
      
      public function EffectPlayerWrapper(param1:String, param2:Boolean)
      {
         super(param1,param2);
      }
      
      public function wrap(param1:EffectPlayer) : void
      {
         wrappee = param1;
         wrappee.cacheEnabled = cacheEnabled;
         wrappee.effectName = effectName;
         addChild(wrappee);
         dispatchEventWith("wrap_event");
      }
      
      override public function start() : void
      {
         if(!wrappee)
         {
            addEventListener("wrap_event",function(param1:Event):void
            {
               removeEventListener("wrap_event",arguments.callee);
               wrappee.start();
            });
            return;
         }
         wrappee.start();
      }
      
      override public function init(param1:DisplayObjectContainer, param2:DisplayObjectContainer = null) : void
      {
         var parent:DisplayObjectContainer = param1;
         var targetSpace:DisplayObjectContainer = param2;
         if(wrappee)
         {
            wrappee.init(parent,targetSpace);
         }
         else
         {
            parent.addChild(this);
            addEventListener("wrap_event",function(param1:Event):void
            {
               removeEventListener("wrap_event",arguments.callee);
               wrappee.setTargetSpace(targetSpace);
            });
         }
      }
      
      override public function isLoaded() : Boolean
      {
         return wrappee.isLoaded();
      }
      
      override public function finishAll() : void
      {
         wrappee.finishAll();
      }
      
      override public function changeColor(param1:uint) : void
      {
         wrappee.changeColor(param1);
      }
      
      public function addEventListenerToWrappee(param1:String, param2:Function) : void
      {
         var type:String = param1;
         var callback:Function = param2;
         addEventListener("wrap_event",function(param1:Event):void
         {
            removeEventListener("wrap_event",arguments.callee);
            wrappee.addEventListener(type,callback);
         });
      }
      
      public function removeEventListenerFromWrappee(param1:String, param2:Function) : void
      {
         wrappee.removeEventListener(param1,param2);
      }
   }
}
