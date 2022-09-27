package gudetama.scene.gacha
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.collection.GudetamaDetailDialog;
   import gudetama.ui.GudetamaShareDialog;
   import gudetama.ui.LevelUpDialog;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class GachaResultDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
       
      
      private var item:ItemParam;
      
      private var convertedItem:ItemParam;
      
      private var worthFlag:Boolean;
      
      private var callback:Function;
      
      private var skipFunc:Function;
      
      private var bgImage:Image;
      
      private var rotateImage:Image;
      
      private var iconImage:Image;
      
      private var normalImage:Image;
      
      private var rareImage:Image;
      
      private var duplicateGroup:Sprite;
      
      private var duplicateImage:Image;
      
      private var convertImage:Image;
      
      private var detailButton:SimpleImageButton;
      
      private var shareButton:SimpleImageButton;
      
      private var nameText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var smokeSpine:SpineModel;
      
      private var okButton:ContainerButton;
      
      private var skipButton:ContainerButton;
      
      private var loadCount:int;
      
      private var passedTime:Number = 0;
      
      private var rank:int = -1;
      
      private var cookedSprite:Sprite;
      
      public function GachaResultDialog(param1:ItemParam, param2:ItemParam, param3:Boolean, param4:int, param5:Function, param6:Function)
      {
         super(2);
         this.item = param1;
         this.convertedItem = param2;
         this.worthFlag = param3;
         this.callback = param5;
         this.skipFunc = param6;
         this.rank = param4;
      }
      
      public static function show(param1:ItemParam, param2:ItemParam, param3:Boolean, param4:int, param5:Function, param6:Function = null) : void
      {
         Engine.pushScene(new GachaResultDialog(param1,param2,param3,param4,param5,param6),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GachaResultDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            bgImage = _loc2_.getChildByName("bg") as Image;
            rotateImage = _loc2_.getChildByName("rotate") as Image;
            iconImage = _loc2_.getChildByName("icon") as Image;
            normalImage = _loc2_.getChildByName("normal") as Image;
            rareImage = _loc2_.getChildByName("rare") as Image;
            duplicateGroup = _loc2_.getChildByName("duplicateGroup") as Sprite;
            duplicateImage = duplicateGroup.getChildByName("icon0") as Image;
            convertImage = duplicateGroup.getChildByName("icon1") as Image;
            detailButton = _loc2_.getChildByName("detailButton") as SimpleImageButton;
            detailButton.addEventListener("triggered",triggeredDetailButton);
            shareButton = _loc2_.getChildByName("btn_share") as SimpleImageButton;
            shareButton.addEventListener("triggered",triggeredShareButton);
            nameText = _loc2_.getChildByName("name") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            smokeSpine = _loc2_.getChildByName("smoke") as SpineModel;
            smokeSpine.visible = false;
            okButton = _loc2_.getChildByName("okButton") as ContainerButton;
            okButton.addEventListener("triggered",triggeredOkButton);
            skipButton = displaySprite.getChildByName("skipButton") as ContainerButton;
            skipButton.addEventListener("triggered",triggeredSkipButton);
            cookedSprite = _loc2_.getChildByName("cookedSprite") as Sprite;
            cookedSprite.visible = false;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
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
         setup();
      }
      
      private function setup() : void
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("bg-background_gacha" + (!!worthFlag ? "2" : "4"),function(param1:Texture):void
            {
               bgImage.texture = param1;
               queue.taskDone();
            });
         });
         var drawItem:ItemParam = !!convertedItem ? convertedItem : item;
         var imageName:String = GudetamaUtil.getItemImageName(drawItem.kind,drawItem.id#2);
         if(drawItem.kind == 6 || drawItem.kind == 7)
         {
            shareButton.visible = true;
         }
         else
         {
            shareButton.visible = false;
         }
         if(imageName.length > 0)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(imageName,function(param1:Texture):void
               {
                  iconImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
         normalImage.visible = !worthFlag;
         rareImage.visible = worthFlag;
         nameText.text#2 = GudetamaUtil.getItemParamName(item);
         descText.text#2 = GudetamaUtil.getItemDesc(item.kind,item.id#2);
         skipButton.visible = skipFunc;
         detailButton.visible = item.kind == 6;
         if(convertedItem)
         {
            descText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.convert.desc"),GudetamaUtil.getItemName(convertedItem.kind,convertedItem.id#2),GudetamaUtil.getItemName(item.kind,item.id#2));
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(GudetamaUtil.getItemImageName(convertedItem.kind,convertedItem.id#2),function(param1:Texture):void
               {
                  duplicateImage.texture = param1;
                  queue.taskDone();
               });
            });
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(GudetamaUtil.getItemImageName(item.kind,item.id#2),function(param1:Texture):void
               {
                  convertImage.texture = param1;
                  queue.taskDone();
               });
            });
            TweenAnimator.startItself(displaySprite,"convert");
            TweenAnimator.finishItself(displaySprite);
         }
         else
         {
            descText.text#2 = GudetamaUtil.getItemDesc(item.kind,item.id#2);
         }
         if(drawItem.kind == 7)
         {
            cookedSprite.visible = true;
         }
         duplicateGroup.visible = false;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GachaResultDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(4);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("succeed");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            okButton.enabled = false;
            if(!processConvert())
            {
               processCheckLvUp();
            }
         });
      }
      
      private function processConvert() : Boolean
      {
         if(!convertedItem)
         {
            return false;
         }
         TweenAnimator.startItself(iconImage,"convert_show",false,function():void
         {
            smokeSpine.show();
            smokeSpine.changeAnimation("start");
            getSceneJuggler().delayCall(function():void
            {
               iconImage.visible = false;
               duplicateGroup.visible = true;
               processCheckLvUp();
            },0.3);
         });
         return true;
      }
      
      private function processCheckLvUp() : void
      {
         var drawItem:ItemParam = !!convertedItem ? convertedItem : item;
         if(rank != -1 && rank < UserDataWrapper.wrapper.getRank() && drawItem.kind == 7)
         {
            LevelUpDialog.show(rank,function():void
            {
               finish();
            });
         }
         else
         {
            finish();
         }
      }
      
      private function finish() : void
      {
         okButton.enabled = true;
         Engine.unlockTouchInput(GachaResultDialog);
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
      }
      
      private function triggeredDetailButton(param1:Event) : void
      {
         var _loc2_:Vector.<GudetamaDef> = new Vector.<GudetamaDef>();
         _loc2_.push(GameSetting.getGudetama(item.id#2));
         GudetamaDetailDialog.show(_loc2_,0,false);
      }
      
      private function triggeredShareButton(param1:Event) : void
      {
         var _loc2_:ItemParam = !!convertedItem ? convertedItem : item;
         GudetamaShareDialog.showFromGacha([_loc2_.id#2,_loc2_.kind]);
      }
      
      private function triggeredOkButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredSkipButton(param1:Event) : void
      {
         back(skipFunc);
      }
      
      override public function backButtonCallback() : void
      {
         back(callback);
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         if(callback)
         {
            callback();
         }
         super.backButtonCallback();
         Engine.lockTouchInput(GachaResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GachaResultDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         bgImage = null;
         rotateImage = null;
         iconImage = null;
         normalImage = null;
         rareImage = null;
         if(detailButton)
         {
            detailButton.removeEventListener("triggered",triggeredDetailButton);
            detailButton = null;
         }
         if(shareButton)
         {
            shareButton.removeEventListener("triggered",triggeredShareButton);
            shareButton = null;
         }
         nameText = null;
         descText = null;
         smokeSpine = null;
         if(okButton)
         {
            okButton.removeEventListener("triggered",triggeredOkButton);
            okButton = null;
         }
         if(skipButton)
         {
            skipButton.removeEventListener("triggered",triggeredSkipButton);
            skipButton = null;
         }
         super.dispose();
      }
   }
}
