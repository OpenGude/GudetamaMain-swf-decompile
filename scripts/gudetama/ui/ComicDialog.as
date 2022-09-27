package gudetama.ui
{
   import feathers.controls.Button;
   import feathers.controls.List;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.HorizontalLayout;
   import gudetama.data.compati.ComicDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class ComicDialog extends BaseScene
   {
      
      public static const TAB_STORY:int = 0;
      
      public static const TAB_HOWTO:int = 1;
       
      
      private var rankingId:int;
      
      private var storyDef:ComicDef;
      
      private var howtoDef:ComicDef;
      
      private var callback:Function;
      
      private var tab:int = -1;
      
      private var page:int = -1;
      
      private var maxPage:int;
      
      private var dialogSprite:Sprite;
      
      private var imgStory:Image;
      
      private var btnStory:Button;
      
      private var imgHowto:Image;
      
      private var btnHowto:Button;
      
      private var btnPrev:ContainerButton;
      
      private var btnNext:ContainerButton;
      
      private var btnClose:ContainerButton;
      
      private var arrowSpineModel:SpineModel;
      
      private var pageText:ColorTextField;
      
      private var maxText:ColorTextField;
      
      private var list:List;
      
      private var collection:ListCollection;
      
      private var extractor:SpriteExtractor;
      
      private var isLastPage:Boolean;
      
      private var loadCount:int;
      
      public function ComicDialog(param1:int, param2:ComicDef, param3:ComicDef, param4:Function)
      {
         collection = new ListCollection();
         super(2);
         this.rankingId = param1;
         this.storyDef = param2;
         this.howtoDef = param3;
         this.callback = param4;
      }
      
      public static function show(param1:int, param2:ComicDef, param3:ComicDef, param4:Function) : void
      {
         Engine.showLoading(ComicDialog);
         Engine.pushScene(new ComicDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"ComicDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc3_:Image = dialogSprite.getChildByName("frame") as Image;
            imgStory = dialogSprite.getChildByName("imgStory") as Image;
            btnStory = dialogSprite.getChildByName("btnStory") as Button;
            btnStory.addEventListener("triggered",triggeredStory);
            imgHowto = dialogSprite.getChildByName("imgHowto") as Image;
            btnHowto = dialogSprite.getChildByName("btnHowto") as Button;
            btnHowto.addEventListener("triggered",triggeredHowto);
            _loc3_.width = imgStory.width;
            list = dialogSprite.getChildByName("list") as List;
            btnPrev = dialogSprite.getChildByName("btnPrev") as ContainerButton;
            btnPrev.addEventListener("triggered",triggeredPrev);
            btnPrev.enableDrawCache(true);
            btnPrev.setDisableColor(8421504);
            btnNext = dialogSprite.getChildByName("btnNext") as ContainerButton;
            btnNext.addEventListener("triggered",triggeredNext);
            btnNext.enableDrawCache(true,true);
            btnNext.setDisableColor(8421504);
            btnClose = dialogSprite.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",backButtonCallback);
            arrowSpineModel = dialogSprite.getChildByName("arrowSpineModel") as SpineModel;
            var _loc2_:Sprite = dialogSprite.getChildByName("pageGroup") as Sprite;
            pageText = _loc2_.getChildByName("page") as ColorTextField;
            maxText = _loc2_.getChildByName("max") as ColorTextField;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_ComicItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         if(storyDef != null)
         {
            preloadComic(storyDef);
         }
         if(howtoDef != null)
         {
            preloadComic(howtoDef);
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup();
         });
         queue.startTask(onProgress);
      }
      
      private function preloadComic(param1:ComicDef) : void
      {
         var def:ComicDef = param1;
         var i:int = 0;
         while(i < def.rsrcs.length)
         {
            var imgName:String = "comic-" + def.rsrcs[i];
            loadTextureForTask(queue,imgName,function(param1:Texture):void
            {
            });
            i++;
         }
      }
      
      private function loadTextureForTask(param1:TaskQueue, param2:String, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var name:String = param2;
         var callback:Function = param3;
         loadCount++;
         TextureCollector.loadTextureForTask(queue,name,function(param1:Texture):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         loadCount++;
         Engine.setupLayoutForTask(queue,layoutData,function(param1:Object):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function addTask(param1:Function) : void
      {
         loadCount++;
         queue.addTask(param1);
      }
      
      private function taskDone() : void
      {
         loadCount--;
         checkInit();
         queue.taskDone();
      }
      
      private function checkInit() : void
      {
         if(loadCount > 0)
         {
            return;
         }
         init();
      }
      
      private function init() : void
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@frame01",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("frame") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@tab01",function(param1:Texture):void
            {
               imgStory.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@tab02",function(param1:Texture):void
            {
               imgHowto.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_prev",function(param1:Texture):void
            {
               btnPrev.background = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_next",function(param1:Texture):void
            {
               btnNext.background = param1;
               queue.taskDone();
            });
         });
      }
      
      private function setup() : void
      {
         var layout:HorizontalLayout = new HorizontalLayout();
         layout.verticalAlign = "top";
         layout.horizontalAlign = "left";
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new ComicListItemRenderer(extractor);
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.touchable = false;
         if(howtoDef != null)
         {
            changeTab(1);
         }
         else
         {
            imgHowto.color = 8421504;
            btnHowto.visible = false;
            changeTab(0);
         }
         if(storyDef == null)
         {
            imgStory.color = 8421504;
            btnStory.visible = false;
         }
         if(!howtoDef || !storyDef)
         {
            arrowSpineModel.show();
            arrowSpineModel.changeAnimation("start_loop");
            TweenAnimator.startItself(arrowSpineModel,"pos0");
         }
         else
         {
            arrowSpineModel.hide();
         }
      }
      
      private function changeTab(param1:int) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         if(tab == param1)
         {
            return;
         }
         tab = param1;
         page = -1;
         if(param1 == 0)
         {
            _loc3_ = storyDef;
            dialogSprite.removeChild(imgStory);
            dialogSprite.addChildAt(imgStory,dialogSprite.getChildIndex(imgHowto) + 1);
         }
         else
         {
            _loc3_ = howtoDef;
            dialogSprite.removeChild(imgHowto);
            dialogSprite.addChildAt(imgHowto,dialogSprite.getChildIndex(imgStory) + 1);
         }
         maxPage = _loc3_.rsrcs.length;
         collection.removeAll();
         _loc2_ = 0;
         while(_loc2_ < maxPage)
         {
            collection.addItem(_loc3_.rsrcs[_loc2_]);
            _loc2_++;
         }
         maxText.text#2 = String(maxPage);
         triggeredNext();
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(ComicDialog);
         setBackButtonCallback(backButtonCallback);
         if(Engine.getGuideTalkPanel() != null)
         {
            setVisibleState(4);
         }
         else
         {
            setVisibleState(28);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(ComicDialog);
            Engine.hideLoading(ComicDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(ComicDialog);
         setBackButtonCallback(null);
         arrowSpineModel.finish();
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ComicDialog);
            Engine.popScene(scene);
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      private function triggeredStory() : void
      {
         changeTab(0);
      }
      
      private function triggeredHowto() : void
      {
         changeTab(1);
      }
      
      private function triggeredPrev() : void
      {
         changePage(-1);
      }
      
      private function triggeredNext() : void
      {
         changePage(1);
      }
      
      private function changePage(param1:int) : void
      {
         if(param1 > 0)
         {
            if(page + param1 >= maxPage)
            {
               return;
            }
         }
         else if(page + param1 < 0)
         {
            return;
         }
         page += param1;
         list.scrollToDisplayIndex(page,0.2);
         btnPrev.enabled = page > 0;
         btnNext.enabled = page < maxPage - 1 && maxPage > 1;
         if(isLastPage && page < maxPage - 1)
         {
            TweenAnimator.startItself(arrowSpineModel,"pos0");
            isLastPage = false;
         }
         else if(!isLastPage && page >= maxPage - 1)
         {
            TweenAnimator.startItself(arrowSpineModel,"pos1");
            isLastPage = true;
         }
         pageText.text#2 = String(page + 1);
      }
      
      override public function dispose() : void
      {
         list = null;
         btnStory.removeEventListener("triggered",triggeredStory);
         btnStory = null;
         btnHowto.removeEventListener("triggered",triggeredHowto);
         btnHowto = null;
         btnPrev.removeEventListener("triggered",triggeredPrev);
         btnPrev = null;
         btnNext.removeEventListener("triggered",triggeredNext);
         btnNext = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class ComicListItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:ComicUI;
   
   function ComicListItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new ComicUI(displaySprite);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
}

import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class ComicUI extends UIBase
{
    
   
   private var img:Image;
   
   function ComicUI(param1:Sprite)
   {
      super(param1);
      img = param1.getChildByName("img") as Image;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      TextureCollector.loadTexture("comic-" + data,function(param1:Texture):void
      {
         if(img != null)
         {
            img.texture = param1;
         }
      });
   }
   
   public function dispose() : void
   {
      img = null;
   }
}
