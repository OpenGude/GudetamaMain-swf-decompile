package feathers.controls
{
   import feathers.controls.supportClasses.BaseScreenNavigator;
   import feathers.skins.IStyleProvider;
   import starling.display.DisplayObject;
   import starling.events.Event;
   
   public class StackScreenNavigator extends BaseScreenNavigator
   {
      
      public static const AUTO_SIZE_MODE_STAGE:String = "stage";
      
      public static const AUTO_SIZE_MODE_CONTENT:String = "content";
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var _pushTransition:Function;
      
      protected var _popTransition:Function;
      
      protected var _popToRootTransition:Function = null;
      
      protected var _stack:Vector.<StackItem>;
      
      protected var _pushScreenEvents:Object;
      
      protected var _replaceScreenEvents:Object;
      
      protected var _popScreenEvents:Vector.<String>;
      
      protected var _popToRootScreenEvents:Vector.<String>;
      
      protected var _tempRootScreenID:String;
      
      public function StackScreenNavigator()
      {
         _stack = new Vector.<StackItem>(0);
         _pushScreenEvents = {};
         super();
         this.addEventListener("initialize",stackScreenNavigator_initializeHandler);
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return StackScreenNavigator.globalStyleProvider;
      }
      
      public function get pushTransition() : Function
      {
         return this._pushTransition;
      }
      
      public function set pushTransition(param1:Function) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._pushTransition = param1;
      }
      
      public function get popTransition() : Function
      {
         return this._popTransition;
      }
      
      public function set popTransition(param1:Function) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._popTransition = param1;
      }
      
      public function get popToRootTransition() : Function
      {
         return this._popToRootTransition;
      }
      
      public function set popToRootTransition(param1:Function) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._popToRootTransition = param1;
      }
      
      public function get stackCount() : int
      {
         var _loc1_:int = this._stack.length;
         if(_loc1_ > 0)
         {
            return this._stack.length + 1;
         }
         if(this._activeScreen)
         {
            return 1;
         }
         return 0;
      }
      
      public function get rootScreenID() : String
      {
         if(this._tempRootScreenID !== null)
         {
            return this._tempRootScreenID;
         }
         if(this._stack.length == 0)
         {
            return this._activeScreenID;
         }
         return this._stack[0].id#2;
      }
      
      public function set rootScreenID(param1:String) : void
      {
         if(this._isInitialized)
         {
            this._tempRootScreenID = null;
            this._stack.length = 0;
            if(param1 !== null)
            {
               this.showScreenInternal(param1,null);
            }
            else
            {
               this.clearScreenInternal(null);
            }
         }
         else
         {
            this._tempRootScreenID = param1;
         }
      }
      
      public function addScreen(param1:String, param2:StackScreenNavigatorItem) : void
      {
         this.addScreenInternal(param1,param2);
      }
      
      public function removeScreen(param1:String) : StackScreenNavigatorItem
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc2_:int = this._stack.length;
         _loc4_ = _loc2_ - 1;
         while(_loc4_ >= 0)
         {
            _loc3_ = this._stack[_loc4_];
            if(_loc3_.id#2 === param1)
            {
               this._stack.removeAt(_loc4_);
            }
            _loc4_--;
         }
         return StackScreenNavigatorItem(this.removeScreenInternal(param1));
      }
      
      override public function removeAllScreens() : void
      {
         this._stack.length = 0;
         super.removeAllScreens();
      }
      
      public function getScreen(param1:String) : StackScreenNavigatorItem
      {
         if(this._screens.hasOwnProperty(param1))
         {
            return StackScreenNavigatorItem(this._screens[param1]);
         }
         return null;
      }
      
      public function pushScreen(param1:String, param2:Object = null, param3:Function = null) : DisplayObject
      {
         var _loc4_:* = null;
         if(param3 === null)
         {
            if((_loc4_ = this.getScreen(param1)) && _loc4_.pushTransition !== null)
            {
               param3 = _loc4_.pushTransition;
            }
            else
            {
               param3 = this.pushTransition;
            }
         }
         if(this._activeScreenID)
         {
            this._stack[this._stack.length] = new StackItem(this._activeScreenID,param2);
         }
         else if(param2)
         {
            throw new ArgumentError("Cannot save properties for the previous screen because there is no previous screen.");
         }
         return this.showScreenInternal(param1,param3);
      }
      
      public function popScreen(param1:Function = null) : DisplayObject
      {
         var _loc3_:* = null;
         if(this._stack.length === 0)
         {
            return this._activeScreen;
         }
         if(param1 === null)
         {
            _loc3_ = this.getScreen(this._activeScreenID);
            if(_loc3_ && _loc3_.popTransition !== null)
            {
               param1 = _loc3_.popTransition;
            }
            else
            {
               param1 = this.popTransition;
            }
         }
         var _loc2_:StackItem = this._stack.pop();
         return this.showScreenInternal(_loc2_.id#2,param1,_loc2_.properties);
      }
      
      public function popToRootScreen(param1:Function = null) : DisplayObject
      {
         if(this._stack.length == 0)
         {
            return this._activeScreen;
         }
         if(param1 == null)
         {
            param1 = this.popToRootTransition;
            if(param1 == null)
            {
               param1 = this.popTransition;
            }
         }
         var _loc2_:StackItem = this._stack[0];
         this._stack.length = 0;
         return this.showScreenInternal(_loc2_.id#2,param1,_loc2_.properties);
      }
      
      public function popAll(param1:Function = null) : void
      {
         if(!this._activeScreen)
         {
            return;
         }
         if(param1 == null)
         {
            param1 = this.popTransition;
         }
         this._stack.length = 0;
         this.clearScreenInternal(param1);
      }
      
      public function popToRootScreenAndReplace(param1:String, param2:Function = null) : DisplayObject
      {
         if(param2 == null)
         {
            param2 = this.popToRootTransition;
            if(param2 == null)
            {
               param2 = this.popTransition;
            }
         }
         this._stack.length = 0;
         return this.showScreenInternal(param1,param2);
      }
      
      public function replaceScreen(param1:String, param2:Function = null) : DisplayObject
      {
         var _loc3_:* = null;
         if(param2 === null)
         {
            _loc3_ = this.getScreen(param1);
            if(_loc3_ && _loc3_.pushTransition !== null)
            {
               param2 = _loc3_.pushTransition;
            }
            else
            {
               param2 = this.pushTransition;
            }
         }
         return this.showScreenInternal(param1,param2);
      }
      
      override protected function prepareActiveScreen() : void
      {
         var _loc1_:StackScreenNavigatorItem = StackScreenNavigatorItem(this._screens[this._activeScreenID]);
         this.addPushEventsToActiveScreen(_loc1_);
         this.addReplaceEventsToActiveScreen(_loc1_);
         this.addPopEventsToActiveScreen(_loc1_);
         this.addPopToRootEventsToActiveScreen(_loc1_);
      }
      
      override protected function cleanupActiveScreen() : void
      {
         var _loc1_:StackScreenNavigatorItem = StackScreenNavigatorItem(this._screens[this._activeScreenID]);
         this.removePushEventsFromActiveScreen(_loc1_);
         this.removeReplaceEventsFromActiveScreen(_loc1_);
         this.removePopEventsFromActiveScreen(_loc1_);
         this.removePopToRootEventsFromActiveScreen(_loc1_);
      }
      
      protected function addPushEventsToActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc7_:Object = param1.pushEvents;
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
                  throw new TypeError("Unknown push event action defined for screen:",_loc6_.toString());
               }
               if(_loc5_)
               {
                  _loc3_ = this.createPushScreenSignalListener(_loc6_ as String,_loc5_);
                  _loc5_.add(_loc3_);
               }
               else
               {
                  _loc3_ = this.createPushScreenEventListener(_loc6_ as String);
                  this._activeScreen.addEventListener(_loc4_,_loc3_);
               }
               _loc2_[_loc4_] = _loc3_;
            }
         }
         this._pushScreenEvents[this._activeScreenID] = _loc2_;
      }
      
      protected function removePushEventsFromActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc6_:* = null;
         var _loc7_:* = null;
         var _loc4_:* = null;
         var _loc2_:Object = param1.pushEvents;
         var _loc3_:Object = this._pushScreenEvents[this._activeScreenID];
         for(var _loc5_ in _loc2_)
         {
            _loc6_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc5_))
            {
               _loc6_ = this._activeScreen[_loc5_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if((_loc7_ = _loc2_[_loc5_]) is Function)
            {
               if(_loc6_)
               {
                  _loc6_.remove(_loc7_ as Function);
               }
               else
               {
                  this._activeScreen.removeEventListener(_loc5_,_loc7_ as Function);
               }
            }
            else if(_loc7_ is String)
            {
               _loc4_ = _loc3_[_loc5_] as Function;
               if(_loc6_)
               {
                  _loc6_.remove(_loc4_);
               }
               else
               {
                  this._activeScreen.removeEventListener(_loc5_,_loc4_);
               }
            }
         }
         this._pushScreenEvents[this._activeScreenID] = null;
      }
      
      protected function addReplaceEventsToActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc7_:Object;
         if(!(_loc7_ = param1.replaceEvents))
         {
            return;
         }
         var _loc2_:Object = {};
         for(var _loc4_ in _loc7_)
         {
            _loc5_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc4_))
            {
               _loc5_ = this._activeScreen[_loc4_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if(!((_loc6_ = _loc7_[_loc4_]) is String))
            {
               throw new TypeError("Unknown replace event action defined for screen:",_loc6_.toString());
            }
            if(_loc5_)
            {
               _loc3_ = this.createReplaceScreenSignalListener(_loc6_ as String,_loc5_);
               _loc5_.add(_loc3_);
            }
            else
            {
               _loc3_ = this.createReplaceScreenEventListener(_loc6_ as String);
               this._activeScreen.addEventListener(_loc4_,_loc3_);
            }
            _loc2_[_loc4_] = _loc3_;
         }
         if(!this._replaceScreenEvents)
         {
            this._replaceScreenEvents = {};
         }
         this._replaceScreenEvents[this._activeScreenID] = _loc2_;
      }
      
      protected function removeReplaceEventsFromActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc6_:* = null;
         var _loc7_:* = null;
         var _loc4_:* = null;
         var _loc2_:Object = param1.replaceEvents;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:Object = this._replaceScreenEvents[this._activeScreenID];
         for(var _loc5_ in _loc2_)
         {
            _loc6_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc5_))
            {
               _loc6_ = this._activeScreen[_loc5_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if((_loc7_ = _loc2_[_loc5_]) is String)
            {
               _loc4_ = _loc3_[_loc5_] as Function;
               if(_loc6_)
               {
                  _loc6_.remove(_loc4_);
               }
               else
               {
                  this._activeScreen.removeEventListener(_loc5_,_loc4_);
               }
            }
         }
         this._replaceScreenEvents[this._activeScreenID] = null;
      }
      
      protected function addPopEventsToActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc6_:* = null;
         if(!param1.popEvents)
         {
            return;
         }
         var _loc2_:Vector.<String> = param1.popEvents.slice();
         var _loc5_:int = _loc2_.length;
         _loc3_ = 0;
         while(_loc3_ < _loc5_)
         {
            _loc4_ = _loc2_[_loc3_];
            _loc6_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc4_))
            {
               _loc6_ = this._activeScreen[_loc4_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if(_loc6_)
            {
               _loc6_.add(popSignalListener);
            }
            else
            {
               this._activeScreen.addEventListener(_loc4_,popEventListener);
            }
            _loc3_++;
         }
         this._popScreenEvents = _loc2_;
      }
      
      protected function removePopEventsFromActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         var _loc5_:* = null;
         if(!this._popScreenEvents)
         {
            return;
         }
         var _loc4_:int = this._popScreenEvents.length;
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc3_ = this._popScreenEvents[_loc2_];
            _loc5_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc3_))
            {
               _loc5_ = this._activeScreen[_loc3_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if(_loc5_)
            {
               _loc5_.remove(popSignalListener);
            }
            else
            {
               this._activeScreen.removeEventListener(_loc3_,popEventListener);
            }
            _loc2_++;
         }
         this._popScreenEvents = null;
      }
      
      protected function removePopToRootEventsFromActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         var _loc5_:* = null;
         if(!this._popToRootScreenEvents)
         {
            return;
         }
         var _loc4_:int = this._popToRootScreenEvents.length;
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc3_ = this._popToRootScreenEvents[_loc2_];
            _loc5_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc3_))
            {
               _loc5_ = this._activeScreen[_loc3_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if(_loc5_)
            {
               _loc5_.remove(popToRootSignalListener);
            }
            else
            {
               this._activeScreen.removeEventListener(_loc3_,popToRootEventListener);
            }
            _loc2_++;
         }
         this._popToRootScreenEvents = null;
      }
      
      protected function addPopToRootEventsToActiveScreen(param1:StackScreenNavigatorItem) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc6_:* = null;
         if(!param1.popToRootEvents)
         {
            return;
         }
         var _loc2_:Vector.<String> = param1.popToRootEvents.slice();
         var _loc5_:int = _loc2_.length;
         _loc3_ = 0;
         while(_loc3_ < _loc5_)
         {
            _loc4_ = _loc2_[_loc3_];
            _loc6_ = null;
            if(BaseScreenNavigator.SIGNAL_TYPE !== null && this._activeScreen.hasOwnProperty(_loc4_))
            {
               _loc6_ = this._activeScreen[_loc4_] as BaseScreenNavigator.SIGNAL_TYPE;
            }
            if(_loc6_)
            {
               _loc6_.add(popToRootSignalListener);
            }
            else
            {
               this._activeScreen.addEventListener(_loc4_,popToRootEventListener);
            }
            _loc3_++;
         }
         this._popToRootScreenEvents = _loc2_;
      }
      
      protected function createPushScreenEventListener(param1:String) : Function
      {
         var screenID:String = param1;
         var self:StackScreenNavigator = this;
         var eventListener:Function = function(param1:Event, param2:Object):void
         {
            self.pushScreen(screenID,param2);
         };
         return eventListener;
      }
      
      protected function createPushScreenSignalListener(param1:String, param2:Object) : Function
      {
         var screenID:String = param1;
         var signal:Object = param2;
         var self:StackScreenNavigator = this;
         if(signal.valueClasses.length == 1)
         {
            var signalListener:Function = function(param1:Object):void
            {
               self.pushScreen(screenID,param1);
            };
         }
         else
         {
            signalListener = function(... rest):void
            {
               var _loc2_:* = null;
               if(rest.length > 0)
               {
                  _loc2_ = rest[0];
               }
               self.pushScreen(screenID,_loc2_);
            };
         }
         return signalListener;
      }
      
      protected function createReplaceScreenEventListener(param1:String) : Function
      {
         var screenID:String = param1;
         var self:StackScreenNavigator = this;
         var eventListener:Function = function(param1:Event):void
         {
            self.replaceScreen(screenID);
         };
         return eventListener;
      }
      
      protected function createReplaceScreenSignalListener(param1:String, param2:Object) : Function
      {
         var screenID:String = param1;
         var signal:Object = param2;
         var self:StackScreenNavigator = this;
         if(signal.valueClasses.length == 0)
         {
            var signalListener:Function = function():void
            {
               self.replaceScreen(screenID);
            };
         }
         else
         {
            signalListener = function(... rest):void
            {
               self.replaceScreen(screenID);
            };
         }
         return signalListener;
      }
      
      protected function popEventListener(param1:Event) : void
      {
         this.popScreen();
      }
      
      protected function popSignalListener(... rest) : void
      {
         this.popScreen();
      }
      
      protected function popToRootEventListener(param1:Event) : void
      {
         this.popToRootScreen();
      }
      
      protected function popToRootSignalListener(... rest) : void
      {
         this.popToRootScreen();
      }
      
      protected function stackScreenNavigator_initializeHandler(param1:Event) : void
      {
         var _loc2_:* = null;
         if(this._tempRootScreenID !== null)
         {
            _loc2_ = this._tempRootScreenID;
            this._tempRootScreenID = null;
            this.showScreenInternal(_loc2_,null);
         }
      }
   }
}

final class StackItem
{
    
   
   public var id#2:String;
   
   public var properties:Object;
   
   function StackItem(param1:String, param2:Object)
   {
      super();
      this.id#2 = param1;
      this.properties = param2;
   }
}
