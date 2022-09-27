package feathers.controls
{
   import feathers.controls.supportClasses.IScreenNavigatorItem;
   import starling.display.DisplayObject;
   
   public class StackScreenNavigatorItem implements IScreenNavigatorItem
   {
       
      
      protected var _screen:Object;
      
      protected var _pushEvents:Object;
      
      protected var _replaceEvents:Object;
      
      protected var _popEvents:Vector.<String>;
      
      protected var _popToRootEvents:Vector.<String>;
      
      protected var _properties:Object;
      
      protected var _pushTransition:Function;
      
      protected var _popTransition:Function;
      
      public function StackScreenNavigatorItem(param1:Object = null, param2:Object = null, param3:String = null, param4:Object = null)
      {
         super();
         this._screen = param1;
         this._pushEvents = !!param2 ? param2 : {};
         if(param3)
         {
            this.addPopEvent(param3);
         }
         this._properties = !!param4 ? param4 : {};
      }
      
      public function get screen() : Object
      {
         return this._screen;
      }
      
      public function set screen(param1:Object) : void
      {
         this._screen = param1;
      }
      
      public function get pushEvents() : Object
      {
         return this._pushEvents;
      }
      
      public function set pushEvents(param1:Object) : void
      {
         if(!param1)
         {
            param1 = {};
         }
         this._pushEvents = param1;
      }
      
      public function get replaceEvents() : Object
      {
         return this._replaceEvents;
      }
      
      public function set replaceEvents(param1:Object) : void
      {
         if(!param1)
         {
            param1 = {};
         }
         this._replaceEvents = param1;
      }
      
      public function get popEvents() : Vector.<String>
      {
         return this._popEvents;
      }
      
      public function set popEvents(param1:Vector.<String>) : void
      {
         if(!param1)
         {
            param1 = new Vector.<String>(0);
         }
         this._popEvents = param1;
      }
      
      public function get popToRootEvents() : Vector.<String>
      {
         return this._popToRootEvents;
      }
      
      public function set popToRootEvents(param1:Vector.<String>) : void
      {
         this._popToRootEvents = param1;
      }
      
      public function get properties() : Object
      {
         return this._properties;
      }
      
      public function set properties(param1:Object) : void
      {
         if(!param1)
         {
            param1 = {};
         }
         this._properties = param1;
      }
      
      public function get pushTransition() : Function
      {
         return this._pushTransition;
      }
      
      public function set pushTransition(param1:Function) : void
      {
         this._pushTransition = param1;
      }
      
      public function get popTransition() : Function
      {
         return this._popTransition;
      }
      
      public function set popTransition(param1:Function) : void
      {
         this._popTransition = param1;
      }
      
      public function get canDispose() : Boolean
      {
         return !(this._screen is DisplayObject);
      }
      
      public function setFunctionForPushEvent(param1:String, param2:Function) : void
      {
         this._pushEvents[param1] = param2;
      }
      
      public function setScreenIDForPushEvent(param1:String, param2:String) : void
      {
         this._pushEvents[param1] = param2;
      }
      
      public function clearPushEvent(param1:String) : void
      {
         delete this._pushEvents[param1];
      }
      
      public function setScreenIDForReplaceEvent(param1:String, param2:String) : void
      {
         if(!this._replaceEvents)
         {
            this._replaceEvents = {};
         }
         this._replaceEvents[param1] = param2;
      }
      
      public function clearReplaceEvent(param1:String) : void
      {
         if(!this._replaceEvents)
         {
            return;
         }
         delete this._replaceEvents[param1];
      }
      
      public function addPopEvent(param1:String) : void
      {
         if(!this._popEvents)
         {
            this._popEvents = new Vector.<String>(0);
         }
         var _loc2_:int = this._popEvents.indexOf(param1);
         if(_loc2_ >= 0)
         {
            return;
         }
         this._popEvents[this._popEvents.length] = param1;
      }
      
      public function removePopEvent(param1:String) : void
      {
         if(!this._popEvents)
         {
            return;
         }
         var _loc2_:int = this._popEvents.indexOf(param1);
         if(_loc2_ >= 0)
         {
            return;
         }
         this._popEvents.removeAt(_loc2_);
      }
      
      public function addPopToRootEvent(param1:String) : void
      {
         if(!this._popToRootEvents)
         {
            this._popToRootEvents = new Vector.<String>(0);
         }
         var _loc2_:int = this._popToRootEvents.indexOf(param1);
         if(_loc2_ >= 0)
         {
            return;
         }
         this._popToRootEvents[this._popToRootEvents.length] = param1;
      }
      
      public function removePopToRootEvent(param1:String) : void
      {
         if(!this._popToRootEvents)
         {
            return;
         }
         var _loc2_:int = this._popToRootEvents.indexOf(param1);
         if(_loc2_ >= 0)
         {
            return;
         }
         this._popToRootEvents.removeAt(_loc2_);
      }
      
      public function getScreen() : DisplayObject
      {
         var _loc1_:* = null;
         var _loc3_:* = null;
         if(this._screen is Class)
         {
            _loc3_ = Class(this._screen);
            _loc1_ = new _loc3_();
         }
         else if(this._screen is Function)
         {
            _loc1_ = DisplayObject((this._screen as Function)());
         }
         else
         {
            _loc1_ = DisplayObject(this._screen);
         }
         if(!(_loc1_ is DisplayObject))
         {
            throw new ArgumentError("StackScreenNavigatorItem \"getScreen()\" must return a Starling display object.");
         }
         if(this._properties)
         {
            for(var _loc2_ in this._properties)
            {
               _loc1_[_loc2_] = this._properties[_loc2_];
            }
         }
         return _loc1_;
      }
   }
}
