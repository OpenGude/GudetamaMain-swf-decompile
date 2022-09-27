package gudetama.scene.ar.ui
{
   import feathers.controls.renderers.LayoutGroupListItemRenderer;
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   
   public class ARGudetamaStampItemRenderer extends LayoutGroupListItemRenderer
   {
       
      
      private var sprite:Sprite;
      
      private var item:GudetamaStampItemUI;
      
      private var extractor:SpriteExtractor;
      
      public function ARGudetamaStampItemRenderer(param1:SpriteExtractor)
      {
         super();
         this.extractor = param1;
      }
      
      override protected function initialize() : void
      {
         if(item == null)
         {
            sprite = extractor.duplicateAll() as Sprite;
            item = new GudetamaStampItemUI(sprite,processTriggerEvent);
            addChild(sprite);
         }
      }
      
      override protected function commitData() : void
      {
         item.updateData(data#2);
      }
      
      override public function dispose() : void
      {
         item.dispose();
         super.dispose();
      }
      
      private function processTriggerEvent() : void
      {
         if(!data#2 || data#2.received)
         {
            return;
         }
         dispatchEventWith("triggered",false,data#2);
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.engine.TextureCollector;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class GudetamaStampItemUI
{
    
   
   private var displaySprite:Sprite;
   
   private var iconBtn:SimpleImageButton;
   
   private var newImage:Image;
   
   private var numText:ColorTextField;
   
   function GudetamaStampItemUI(param1:Sprite, param2:Function)
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
         callback();
      });
      newImage = displaySprite.getChildByName("newImage") as Image;
      newImage.visible = false;
      numText = displaySprite.getChildByName("numText") as ColorTextField;
   }
   
   public function dispose() : void
   {
      numText.dispose();
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      if(data.hasOwnProperty("gudetamaId"))
      {
         numText.text#2 = data.countMap[data.gudetamaId];
         TextureCollector.loadTextureRsrc(GudetamaUtil.getARGudetamaIconName(data.gudetamaId),function(param1:Texture):void
         {
            iconBtn.texture = param1;
         });
      }
      else if(data.hasOwnProperty("stampId"))
      {
         numText.text#2 = data.countMap[data.stampId];
         TextureCollector.loadTextureRsrc(GudetamaUtil.getARStampIconName(data.stampId),function(param1:Texture):void
         {
            iconBtn.texture = param1;
         });
      }
   }
}
