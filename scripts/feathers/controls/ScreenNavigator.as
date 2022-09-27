package feathers.controls
{
   import feathers.controls.supportClasses.BaseScreenNavigator;
   import feathers.skins.IStyleProvider;
   import starling.display.DisplayObject;
   import starling.events.Event;
   
   public class ScreenNavigator extends BaseScreenNavigator
   {
      
      public static const AUTO_SIZE_MODE_STAGE:String = "stage";
      
      public static const AUTO_SIZE_MODE_CONTENT:String = "content";
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var _transition:Function;
      
      protected var _screenEvents:Object;
      
      public function ScreenNavigator()
      {
         _screenEvents = {};
         super();
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return ScreenNavigator.globalStyleProvider;
      }
      
      public function get transition() : Function
      {
         return this._transition;
      }
      
      public function set transition(param1:Function) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._transition = param1;
      }
      
      public function addScreen(param1:String, param2:ScreenNavigatorItem) : void
      {
         this.addScreenInternal(param1,param2);
      }
      
      public function removeScreen(param1:String) : ScreenNavigatorItem
      {
         return ScreenNavigatorItem(this.removeScreenInternal(param1));
      }
      
      public function getScreen(param1:String) : ScreenNavigatorItem
      {
         if(this._screens.hasOwnProperty(param1))
         {
            return ScreenNavigatorItem(this._screens[param1]);
         }
         return null;
      }
      
      public function showScreen(param1:String, param2:Function = null) : DisplayObject
      {
         if(this._activeScreenID === param1)
         {
            return this._activeScreen;
         }
         if(param2 === null)
         {
            param2 = this._transition;
         }
         return this.showScreenInternal(param1,param2);
      }
      
      public function clearScreen(param1:Function = null) : void
      {
         if(param1 == null)
         {
            param1 = this._transition;
         }
         this.clearScreenInternal(param1);
         this.dispatchEventWith("clear");
      }
      
      override protected function prepareActiveScreen() : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc1_:ScreenNavigatorItem = ScreenNavigatorItem(this._screens[this._activeScreenID]);
         var _loc7_:Object = _loc1_.events;
         var _loc2_:Object = {};
         for(var _loc4_ in _loc7_)
         {
            _loc5_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc4_))
            {
               _loc5_ = this._activeScreen[_loc4_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if((_loc6_ = _loc7_[_loc4_]) is Function)
            {
               if(_loc5_)
               {
                  _loc5_.add(_loc6_ as Function);
               }
               else
               {
                  this._activeScreen.addEventListener(_loc4_,_loc6_ as Function);
               }
            }
            else
            {
               if(!(_loc6_ is String))
               {
                  throw new TypeError("Unknown event action defined for screen:",_loc6_.toString());
               }
               if(_loc5_)
               {
                  _loc3_ = this.createShowScreenSignalListener(_loc6_ as String,_loc5_);
                  _loc5_.add(_loc3_);
               }
               else
               {
                  _loc3_ = this.createShowScreenEventListener(_loc6_ as String);
                  this._activeScreen.addEventListener(_loc4_,_loc3_);
               }
               _loc2_[_loc4_] = _loc3_;
            }
         }
         this._screenEvents[this._activeScreenID] = _loc2_;
      }
      
      override protected function cleanupActiveScreen() : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc1_:ScreenNavigatorItem = ScreenNavigatorItem(this._screens[this._activeScreenID]);
         var _loc7_:Object = _loc1_.events;
         var _loc2_:Object = this._screenEvents[this._activeScreenID];
         for(var _loc4_ in _loc7_)
         {
            _loc5_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc4_))
            {
               _loc5_ = this._activeScreen[_loc4_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if((_loc6_ = _loc7_[_loc4_]) is Function)
            {
               if(_loc5_)
               {
                  _loc5_.remove(_loc6_ as Function);
               }
               else
               {
                  this._activeScreen.removeEventListener(_loc4_,_loc6_ as Function);
               }
            }
            else if(_loc6_ is String)
            {
               _loc3_ = _loc2_[_loc4_] as Function;
               if(_loc5_)
               {
                  _loc5_.remove(_loc3_);
               }
               else
               {
                  this._activeScreen.removeEventListener(_loc4_,_loc3_);
               }
            }
         }
         this._screenEvents[this._activeScreenID] = null;
      }
      
      protected function createShowScreenEventListener(param1:String) : Function
      {
         var screenID:String = param1;
         var self:ScreenNavigator = this;
         var eventListener:Function = function(param1:Event):void
         {
            self.showScreen(screenID);
         };
         return eventListener;
      }
      
      protected function createShowScreenSignalListener(param1:String, param2:Object) : Function
      {
         var screenID:String = param1;
         var signal:Object = param2;
         var self:ScreenNavigator = this;
         if(signal.valueClasses.length == 1)
         {
            var signalListener:Function = function(param1:Object):void
            {
               self.showScreen(screenID);
            };
         }
         else
         {
            signalListener = function(... rest):void
            {
               self.showScreen(screenID);
            };
         }
         return signalListener;
      }
   }
}
