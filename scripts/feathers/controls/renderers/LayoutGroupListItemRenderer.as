package feathers.controls.renderers
{
   import feathers.controls.LayoutGroup;
   import feathers.controls.List;
   import feathers.skins.IStyleProvider;
   import starling.display.DisplayObject;
   
   public class LayoutGroupListItemRenderer extends LayoutGroup implements IListItemRenderer
   {
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var _index:int = -1;
      
      protected var _owner:List;
      
      protected var _data:Object;
      
      protected var _isSelected:Boolean;
      
      protected var _factoryID:String;
      
      protected var _backgroundSelectedSkin:DisplayObject;
      
      public function LayoutGroupListItemRenderer()
      {
         super();
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return LayoutGroupListItemRenderer.globalStyleProvider;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function set index(param1:int) : void
      {
         this._index = param1;
      }
      
      public function get owner() : List
      {
         return this._owner;
      }
      
      public function set owner(param1:List) : void
      {
         if(this._owner == param1)
         {
            return;
         }
         this._owner = param1;
         this.invalidate("data");
      }
      
      public function get data#2() : Object
      {
         return this._data;
      }
      
      public function set data#2(param1:Object) : void
      {
         if(this._data == param1)
         {
            return;
         }
         this._data = param1;
         this.invalidate("data");
         this.invalidate("size");
      }
      
      public function get isSelected() : Boolean
      {
         return this._isSelected;
      }
      
      public function set isSelected(param1:Boolean) : void
      {
         if(this._isSelected == param1)
         {
            return;
         }
         this._isSelected = param1;
         this.invalidate("selected");
         this.invalidate("state");
         this.dispatchEventWith("change");
      }
      
      public function get factoryID() : String
      {
         return this._factoryID;
      }
      
      public function set factoryID(param1:String) : void
      {
         this._factoryID = param1;
      }
      
      public function get backgroundSelectedSkin() : DisplayObject
      {
         return this._backgroundSelectedSkin;
      }
      
      public function set backgroundSelectedSkin(param1:DisplayObject) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            if(param1 !== null)
            {
               param1.dispose();
            }
            return;
         }
         if(this._backgroundSelectedSkin === param1)
         {
            return;
         }
         if(this._backgroundSelectedSkin !== null && this.currentBackgroundSkin === this._backgroundSelectedSkin)
         {
            this.removeCurrentBackgroundSkin(this._backgroundSelectedSkin);
            this.currentBackgroundSkin = null;
         }
         this._backgroundSelectedSkin = param1;
         this.invalidate("skin");
      }
      
      override public function dispose() : void
      {
         this.owner = null;
         super.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc3_:Boolean = this.isInvalid("data");
         var _loc4_:Boolean = this.isInvalid("scroll");
         var _loc1_:Boolean = this.isInvalid("size");
         var _loc2_:Boolean = this.isInvalid("layout");
         if(_loc3_)
         {
            this.commitData();
         }
         if(_loc4_ || _loc1_ || _loc2_)
         {
            this._ignoreChildChanges = true;
            this.preLayout();
            this._ignoreChildChanges = false;
         }
         super.draw();
         if(_loc4_ || _loc1_ || _loc2_)
         {
            this._ignoreChildChanges = true;
            this.postLayout();
            this._ignoreChildChanges = false;
         }
      }
      
      protected function preLayout() : void
      {
      }
      
      protected function postLayout() : void
      {
      }
      
      protected function commitData() : void
      {
      }
      
      override protected function getCurrentBackgroundSkin() : DisplayObject
      {
         if(!this._isEnabled && this._backgroundDisabledSkin !== null)
         {
            return this._backgroundDisabledSkin;
         }
         if(this._isSelected && this._backgroundSelectedSkin !== null)
         {
            return this._backgroundSelectedSkin;
         }
         return this._backgroundSkin;
      }
   }
}
