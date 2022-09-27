package feathers.controls
{
   import feathers.controls.supportClasses.IScreenNavigatorItem;
   import starling.display.DisplayObject;
   
   public class ScreenNavigatorItem implements IScreenNavigatorItem
   {
       
      
      protected var _screen:Object;
      
      protected var _events:Object;
      
      protected var _properties:Object;
      
      public function ScreenNavigatorItem(param1:Object = null, param2:Object = null, param3:Object = null)
      {
         super();
         this._screen = param1;
         this._events = !!param2 ? param2 : {};
         this._properties = !!param3 ? param3 : {};
      }
      
      public function get screen() : Object
      {
         return this._screen;
      }
      
      public function set screen(param1:Object) : void
      {
         this._screen = param1;
      }
      
      public function get events() : Object
      {
         return this._events;
      }
      
      public function set events(param1:Object) : void
      {
         if(!param1)
         {
            param1 = {};
         }
         this._events = param1;
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
      
      public function get canDispose() : Boolean
      {
         return !(this._screen is DisplayObject);
      }
      
      public function setFunctionForEvent(param1:String, param2:Function) : void
      {
         this._events[param1] = param2;
      }
      
      public function setScreenIDForEvent(param1:String, param2:String) : void
      {
         this._events[param1] = param2;
      }
      
      public function clearEvent(param1:String) : void
      {
         delete this._events[param1];
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
            throw new ArgumentError("ScreenNavigatorItem \"getScreen()\" must return a Starling display object.");
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
