package gudetama.scene.home.ui
{
   import feathers.controls.renderers.LayoutGroupListItemRenderer;
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class HomeFrameItemRenderer extends LayoutGroupListItemRenderer
   {
       
      
      private var sprite:Sprite;
      
      private var item:HomeFrameItemUI;
      
      private var extractor:SpriteExtractor;
      
      public function HomeFrameItemRenderer(param1:SpriteExtractor)
      {
         super();
         this.extractor = param1;
      }
      
      override protected function initialize() : void
      {
         if(item == null)
         {
            sprite = extractor.duplicateAll() as Sprite;
            item = new HomeFrameItemUI(sprite,processTriggerEvent);
            addChild(sprite);
         }
      }
      
      override protected function commitData() : void
      {
         item.updateData(data#2);
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      private function processTriggerEvent(param1:Texture) : void
      {
         if(!data#2 || data#2.received)
         {
            return;
         }
         dispatchEventWith("triggered",false,param1);
      }
   }
}

import gudetama.engine.TextureCollector;
import muku.display.SimpleImageButton;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class HomeFrameItemUI
{
    
   
   private var displaySprite:Sprite;
   
   private var iconBtn:SimpleImageButton;
   
   function HomeFrameItemUI(param1:Sprite, param2:Function)
   {
      var sprite:Sprite = param1;
      var callback:Function = param2;
      super();
      displaySprite = sprite;
      iconBtn = displaySprite.getChildByName("iconBtn") as SimpleImageButton;
      iconBtn.setTweenDiable(true);
      iconBtn.addEventListener("triggered",function(param1:Event):void
      {
         param1.stopImmediatePropagation();
         callback(iconBtn.texture);
      });
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      if(data.id == -1)
      {
         iconBtn.texture = Texture.empty(70,120);
      }
      else
      {
         TextureCollector.loadTextureRsrc("bg-fream_" + data.id,function(param1:Texture):void
         {
            iconBtn.texture = param1;
         });
      }
   }
}
