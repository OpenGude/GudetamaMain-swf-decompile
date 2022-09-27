package gudetama.util
{
   import feathers.controls.ScrollContainer;
   import flash.utils.Dictionary;
   import gudetama.engine.AssetMediator;
   import gudetama.engine.Engine;
   import muku.display.ContainerButton;
   import muku.display.ImageButton;
   import muku.display.Particle;
   import muku.text.ColorTextField;
   import starling.display.Button;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.text.TextField;
   
   public class SpriteExtractor
   {
      
      private static const TYPE_GROSS:int = 0;
      
      private static const TYPE_PART:int = 1;
      
      private static const TYPE_SCROLL_CONTAINER:int = 2;
      
      private static const typeText:Array = ["TYPE_GROSS","TYPE_PART","TYPE_SCROLL_CONTAINER"];
       
      
      private var extractorType:int = -1;
      
      private var builderData:Object;
      
      private var paramsDict:Dictionary;
      
      private var textureCache:Object;
      
      private var container:DisplayObjectContainer;
      
      private var containerItems:Vector.<DisplayObject>;
      
      private var scrollContainer:ScrollContainer;
      
      private var scrollContainerItems:Vector.<DisplayObject>;
      
      public function SpriteExtractor()
      {
         super();
      }
      
      public static function forGross(param1:DisplayObjectContainer, param2:Object) : SpriteExtractor
      {
         var _loc3_:SpriteExtractor = new SpriteExtractor();
         _loc3_.extractorType = 0;
         _loc3_.setupForGross(param1,param2);
         return _loc3_;
      }
      
      public static function forPart(param1:DisplayObjectContainer, param2:Object, param3:Boolean = false) : SpriteExtractor
      {
         var _loc4_:SpriteExtractor;
         (_loc4_ = new SpriteExtractor()).extractorType = 1;
         _loc4_.setupForPart(param1,param2,param3);
         return _loc4_;
      }
      
      public static function forScrollContainer(param1:ScrollContainer, param2:Object, param3:Boolean = true) : SpriteExtractor
      {
         var _loc4_:SpriteExtractor;
         (_loc4_ = new SpriteExtractor()).extractorType = 2;
         _loc4_.setupForScrollContainer(param1,param2,param3);
         return _loc4_;
      }
      
      public static function getChildByNameRecursively(param1:DisplayObjectContainer, param2:String) : DisplayObject
      {
         var _loc6_:int = 0;
         var _loc9_:* = null;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc7_:* = undefined;
         var _loc8_:* = undefined;
         var _loc3_:* = new Vector.<DisplayObjectContainer>();
         _loc3_.push(param1);
         do
         {
            _loc7_ = !!_loc8_ ? _loc8_ : new Vector.<DisplayObjectContainer>();
            for each(_loc9_ in _loc3_)
            {
               _loc5_ = _loc9_.numChildren;
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  if((_loc4_ = _loc9_.getChildAt(_loc6_)).name#2 == param2)
                  {
                     return _loc4_;
                  }
                  if(!(_loc4_ is Button || _loc4_ is TextField || _loc4_ is Particle))
                  {
                     if(_loc4_ is DisplayObjectContainer)
                     {
                        _loc7_.push(_loc4_ as DisplayObjectContainer);
                     }
                  }
                  _loc6_++;
               }
            }
            (_loc8_ = _loc3_).length = 0;
            _loc3_ = _loc7_;
         }
         while(_loc3_.length > 0);
         
         return null;
      }
      
      public static function copyValues(param1:DisplayObject, param2:DisplayObject) : Boolean
      {
         if(param1 is ColorTextField && param2 is ColorTextField)
         {
            (param2 as ColorTextField).updateValuesFrom(param1 as ColorTextField);
         }
         else if(param1 is TextField && param2 is TextField)
         {
            if((param2 as TextField).text#2 != (param1 as TextField).text#2)
            {
               (param2 as TextField).text#2 = (param1 as TextField).text#2;
            }
         }
         else if(param1 is ContainerButton && param2 is ContainerButton)
         {
            _copyValuesOfContainerButton(param1 as ContainerButton,param2 as ContainerButton);
         }
         else if(!((param1 as Image).scale9Grid != null && (param2 as Image).scale9Grid != null))
         {
            if(param1 is Image && param2 is Image)
            {
               if((param2 as Image).texture != (param1 as Image).texture)
               {
                  (param2 as Image).texture = (param1 as Image).texture;
                  (param2 as Image).readjustSize();
               }
            }
            else if(!(param1 is ImageButton && param2 is ImageButton))
            {
               return false;
            }
         }
         return true;
      }
      
      private static function _copyValuesOfContainerButton(param1:ContainerButton, param2:ContainerButton) : void
      {
         var _loc5_:* = null;
         var _loc8_:* = null;
         var _loc6_:int = 0;
         var _loc3_:int = param1.numChildren;
         var _loc4_:int;
         var _loc7_:int = (_loc4_ = param2.numChildren) < _loc3_ ? _loc4_ : int(_loc3_);
         _loc6_ = 0;
         while(_loc6_ < _loc7_)
         {
            _loc8_ = param2.getChildAt(_loc6_);
            _loc5_ = param1.getChildAt(_loc6_);
            if(_loc8_.name#2 == _loc5_.name#2)
            {
               SpriteExtractor.copyValues(_loc5_,_loc8_);
            }
            _loc6_++;
         }
      }
      
      private static function getTypeText(param1:int) : String
      {
         if(param1 >= 0 && param1 < typeText.length)
         {
            return typeText[param1];
         }
         return "type_unknown";
      }
      
      public function get numContents() : int
      {
         switch(int(extractorType))
         {
            case 0:
               return container.numChildren;
            case 1:
               return containerItems.length;
            case 2:
               return scrollContainerItems.length;
            default:
               return 0;
         }
      }
      
      public function getBuilderData() : Object
      {
         return builderData;
      }
      
      public function duplicateAll() : DisplayObject
      {
         return _duplicateContainer(container);
      }
      
      public function duplicateContainerAt(param1:int = 0) : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         if(extractorType == 1)
         {
            _loc2_ = containerItems[param1];
         }
         else
         {
            if(extractorType != 0)
            {
               throw new Error("invalid call for " + getTypeText(extractorType));
            }
            _loc2_ = container.getChildAt(param1);
         }
         return _duplicateContainer(_loc2_);
      }
      
      public function duplicateContainer(param1:String) : DisplayObject
      {
         var _loc3_:* = null;
         if(extractorType == 1)
         {
            for each(var _loc2_ in containerItems)
            {
               if(_loc2_.name#2 == param1)
               {
                  _loc3_ = _loc2_;
                  break;
               }
            }
         }
         else
         {
            if(extractorType != 0)
            {
               throw new Error("invalid call for " + getTypeText(extractorType));
            }
            _loc3_ = getChildByNameRecursively(container,param1);
         }
         return _duplicateContainer(_loc3_);
      }
      
      public function duplicateScrollContainerItemAt(param1:int = 0) : DisplayObject
      {
         if(extractorType != 2)
         {
            throw new Error("invalid call for " + getTypeText(extractorType));
         }
         var _loc2_:DisplayObject = scrollContainerItems[param1];
         return _duplicateContainer(_loc2_);
      }
      
      public function duplicateScrollContainerItem(param1:String) : DisplayObject
      {
         if(extractorType != 2)
         {
            throw new Error("invalid call for " + getTypeText(extractorType));
         }
         var _loc3_:* = null;
         for each(var _loc2_ in scrollContainerItems)
         {
            if(_loc2_.name#2 == param1)
            {
               _loc3_ = _loc2_;
               break;
            }
         }
         return _duplicateContainer(_loc3_);
      }
      
      private function setupForGross(param1:DisplayObjectContainer, param2:Object) : void
      {
         this.container = param1;
         this.builderData = param2;
         this.textureCache = !!param2.hasOwnProperty("textureCache") ? param2.textureCache : null;
         paramsDict = param2.params;
      }
      
      private function setupForPart(param1:DisplayObjectContainer, param2:Object, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.container = param1;
         this.builderData = param2;
         this.textureCache = !!param2.hasOwnProperty("textureCache") ? param2.textureCache : null;
         paramsDict = param2.params;
         containerItems = new Vector.<DisplayObject>();
         if(param3)
         {
            while(param1.numChildren > 0)
            {
               containerItems.push(param1.removeChildAt(0));
            }
         }
         else
         {
            _loc4_ = param1.numChildren;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               containerItems.push(param1.getChildAt(_loc5_));
               _loc5_++;
            }
         }
      }
      
      private function setupForScrollContainer(param1:ScrollContainer, param2:Object, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.scrollContainer = param1;
         this.builderData = param2;
         this.textureCache = !!param2.hasOwnProperty("textureCache") ? param2.textureCache : null;
         paramsDict = param2.params;
         scrollContainerItems = new Vector.<DisplayObject>();
         if(param3)
         {
            while(param1.numChildren > 0)
            {
               scrollContainerItems.push(param1.removeChildAt(0));
            }
         }
         else
         {
            _loc4_ = param1.numChildren;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               scrollContainerItems.push(param1.getChildAt(_loc5_));
               _loc5_++;
            }
         }
      }
      
      private function _duplicateContainer(param1:DisplayObject) : DisplayObject
      {
         if(param1 == null)
         {
            throw new Error("item not available.");
         }
         var _loc2_:Object = paramsDict[param1];
         if(_loc2_ == null)
         {
            throw new Error("layout data was not found for item");
         }
         AssetMediator.setTextureCache(textureCache);
         var _loc3_:DisplayObject = Engine.uiBuilder.create({"layout":_loc2_},false) as DisplayObject;
         AssetMediator.clearTextureCache();
         return _loc3_;
      }
   }
}
