package gudetama.ui
{
   import feathers.controls.List;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.HorizontalLayout;
   import gudetama.data.GameSetting;
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
   
   public class HelperComicDialog extends BaseScene
   {
       
      
      private var comicDef:ComicDef;
      
      private var callback:Function;
      
      private var page:int = -1;
      
      private var maxPage:int;
      
      private var dialogSprite:Sprite;
      
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
      
      private var comicSpineSprite:Sprite;
      
      private var helperSpineModels:Object;
      
      private var spinePageMap:Object;
      
      public function HelperComicDialog(param1:Function)
      {
         collection = new ListCollection();
         super(2);
         this.comicDef = GameSetting.def.helperComicDef;
         this.callback = param1;
      }
      
      public static function show(param1:Function = null) : void
      {
         Engine.showLoading(ComicDialog);
         Engine.pushScene(new HelperComicDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HelperComicDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc4_:Image = dialogSprite.getChildByName("frame") as Image;
            var _loc2_:Sprite = dialogSprite.getChildByName("comicSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            comicSpineSprite = _loc2_.getChildByName("spineSprite") as Sprite;
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
            var _loc3_:Sprite = dialogSprite.getChildByName("pageGroup") as Sprite;
            pageText = _loc3_.getChildByName("page") as ColorTextField;
            maxText = _loc3_.getChildByName("max") as ColorTextField;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_ComicItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         preloadComic(comicDef);
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
         if(def.comicSpine)
         {
            var l:int = 0;
            while(l < def.comicSpine.length)
            {
               var id:int = def.comicSpine[l].id;
               var spineMap:Object = def.comicSpine[l].spainMap;
               var spineAnimeMap:Object = def.comicSpine[l].spainAnimeMap;
               var spineScaleMap:Object = def.comicSpine[l].spainScaleMap;
               var spainDelayMap:Object = def.comicSpine[l].spainDelayMap;
               var index:int = 0;
               for(spineName in spineMap)
               {
                  loadSpainModel(id,index,spineName,spineMap[spineName],spineAnimeMap[spineName],spineScaleMap[spineName],spainDelayMap[spineName]);
                  index++;
               }
               l++;
            }
         }
      }
      
      private function loadSpainModel(param1:int, param2:int, param3:String, param4:Array, param5:String, param6:Number, param7:Number) : void
      {
         var id:int = param1;
         var _index:int = param2;
         var helperSpineName:String = param3;
         var pos:Array = param4;
         var animeName:String = param5;
         var spineScale:Number = param6;
         var spainDelay:Number = param7;
         queue.addTask(function():void
         {
            var comicSpineModel:SpineModel = createComicSpineModel(id,_index,pos,animeName,spineScale,spainDelay);
            comicSpineModel.load(helperSpineName,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      private function createComicSpineModel(param1:int, param2:int, param3:Array, param4:String, param5:Number, param6:Number) : SpineModel
      {
         var _loc7_:* = null;
         var _loc8_:SpineModel = new SpineModel();
         if(!spinePageMap)
         {
            spinePageMap = {};
         }
         if(spinePageMap[param1])
         {
            _loc7_ = spinePageMap[param1];
         }
         else
         {
            _loc7_ = [];
         }
         _loc7_.push({
            "model":_loc8_,
            "pos":param3,
            "animeName":param4,
            "spineScale":param5,
            "spainDelay":param6
         });
         spinePageMap[param1] = _loc7_;
         return _loc8_;
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
         createlist();
         arrowSpineModel.hide();
      }
      
      private function createlist() : void
      {
         var _loc2_:* = null;
         var _loc1_:int = 0;
         page = -1;
         _loc2_ = comicDef;
         maxPage = _loc2_.rsrcs.length;
         collection.removeAll();
         _loc1_ = 0;
         while(_loc1_ < maxPage)
         {
            collection.addItem(_loc2_.rsrcs[_loc1_]);
            _loc1_++;
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
         var add:int = param1;
         juggler.removeDelayedCalls(removeDelayCallCallback);
         comicSpineSprite.removeChildren();
         if(add > 0)
         {
            if(page + add >= maxPage)
            {
               return;
            }
         }
         else if(page + add < 0)
         {
            return;
         }
         page += add;
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
         var spineList:Array = spinePageMap[page + 1];
         if(spineList)
         {
            var i:int = 0;
            while(i < spineList.length)
            {
               var data:Object = spineList[i];
               var spinemode:SpineModel = data.model;
               var pos:Array = data.pos;
               var animeName:String = data.animeName;
               spinemode.x = pos[0];
               spinemode.y = pos[1];
               spinemode.scale = data.spineScale;
               var delay:Number = data.spainDelay;
               try
               {
                  spinemode.changeAnimation(animeName);
               }
               catch(error:Error)
               {
               }
               spinemode.show();
               juggler.delayCall(function():void
               {
                  comicSpineSprite.addChild(spinemode);
               },delay);
               i++;
            }
         }
      }
      
      private function removeDelayCallCallback() : void
      {
      }
      
      override public function dispose() : void
      {
         list = null;
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
