package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.UsefulData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class UsefulDetailDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var numText:ColorTextField;
      
      private var shopButton:ContainerButton;
      
      private var useButton:ContainerButton;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var rootClass:Class = null;
      
      public function UsefulDetailDialog(param1:int, param2:Class, param3:Function)
      {
         super(2);
         this.id = param1;
         this.callback = param3;
         rootClass = param2;
      }
      
      public static function show(param1:int, param2:Class, param3:Function = null) : void
      {
         Engine.pushScene(new UsefulDetailDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"UsefulDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            iconImage = _loc2_.getChildByName("icon") as Image;
            numText = _loc2_.getChildByName("num") as ColorTextField;
            shopButton = _loc2_.getChildByName("shopButton") as ContainerButton;
            shopButton.enableDrawCache();
            shopButton.addEventListener("triggered",triggeredShopButton);
            useButton = _loc2_.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUseButton);
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.enableDrawCache();
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         var usefulDef:UsefulDef = GameSetting.getUseful(id);
         var usefulData:UsefulData = UserDataWrapper.usefulPart.getUseful(id);
         var num:int = !!usefulData ? usefulData.num : 0;
         titleText.text#2 = usefulDef.name#2;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         numText.text#2 = StringUtil.getNumStringCommas(num);
         descText.text#2 = usefulDef.desc;
         var numButton:int = 0;
         if(usefulDef.price)
         {
            shopButton.visible = true;
            numButton++;
         }
         else
         {
            shopButton.visible = false;
         }
         if(usefulDef.isUsable(1))
         {
            useButton.visible = true;
            useButton.setEnableWithDrawCache(num > 0);
            numButton++;
         }
         else
         {
            useButton.visible = false;
         }
         switch(int(numButton))
         {
            case 0:
               TweenAnimator.startItself(displaySprite,"pos0");
               break;
            case 1:
               TweenAnimator.startItself(displaySprite,"pos1");
               TweenAnimator.startItself(shopButton,"num0");
               TweenAnimator.startItself(useButton,"num0");
               break;
            case 2:
               TweenAnimator.startItself(displaySprite,"pos1");
               TweenAnimator.startItself(shopButton,"num1");
               TweenAnimator.startItself(useButton,"num1");
         }
      }
      
      private function start() : void
      {
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(UsefulDetailDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(UsefulDetailDialog);
         });
      }
      
      private function triggeredShopButton(param1:Event) : void
      {
         var event:Event = param1;
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
         {
            var _loc1_:Object = {};
            _loc1_ = {
               "subScene":"useful_detail",
               "id":id,
               "callback":callback
            };
            Engine.switchScene(new ShopScene_Gudetama(7,id).addBackClass(rootClass,_loc1_));
         });
      }
      
      private function triggeredUseButton(param1:Event) : void
      {
         var event:Event = param1;
         var usefulDef:UsefulDef = GameSetting.getUseful(id);
         var usefulData:UsefulData = UserDataWrapper.usefulPart.getUseful(id);
         var useState:int = checkCanUseItem(usefulDef);
         if(useState >= 0)
         {
            MessageDialog.show(0,StringUtil.format(GameSetting.getUIText("useful.confirm.err." + useState),usefulDef.name#2),function(param1:int):void
            {
            });
            return;
         }
         if(usefulDef.existsAbilityKind(8) && UserDataWrapper.eventPart.getRankingIds(true) == null)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("ranking.use.useful.error"));
            return;
         }
         var msg:String = GameSetting.getUIText("inventory.useful.confirm.desc");
         var overwriteTypes:Array = usefulDef.getTypesAtFlags(1024);
         if(overwriteTypes != null)
         {
            var i:int = 0;
            while(i < overwriteTypes.length)
            {
               if(UserDataWrapper.abilityPart.getAliveAtType(overwriteTypes[i]))
               {
                  var msg:String = msg + ("\n" + GameSetting.getUIText("inventory.useful.confirm.overwrite"));
                  break;
               }
               i++;
            }
         }
         LocalMessageDialog.show(1,StringUtil.format(msg,usefulDef.name#2),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            Engine.showLoading(UsefulDetailDialog);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(189,id),function(param1:*):void
            {
               var _loc2_:int = 0;
               Engine.hideLoading(UsefulDetailDialog);
               if(param1 is int)
               {
                  _loc2_ = param1;
                  if(_loc2_ == -1)
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("ranking.use.useful.error"));
                  }
                  return;
               }
               UserDataWrapper.usefulPart.consumeUseful(id,1);
               Engine.broadcastEventToSceneStackWith("update_scene");
               back();
            });
         },GameSetting.getUIText("inventory.useful.confirm.title"));
      }
      
      private function checkCanUseItem(param1:UsefulDef) : int
      {
         if(param1.existsAbilityKind(9))
         {
            if(!UserDataWrapper.wrapper.isDoneNoticeFlag(29))
            {
               return 1;
            }
            if(UserDataWrapper.wrapper.canUseHelperState())
            {
               return 0;
            }
            return !UserDataWrapper.abilityPart.existsKind(9) ? -1 : 0;
         }
         return -1;
      }
      
      private function refresh() : void
      {
         var _loc2_:UsefulData = UserDataWrapper.usefulPart.getUseful(id);
         var _loc1_:int = !!_loc2_ ? _loc2_.num : 0;
         numText.text#2 = StringUtil.getNumStringCommas(_loc1_);
         useButton.setEnableWithDrawCache(_loc1_ > 0);
      }
      
      override public function backButtonCallback() : void
      {
         back(callback);
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         back(callback);
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(UsefulDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UsefulDetailDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         titleText = null;
         iconImage = null;
         numText = null;
         shopButton.removeEventListener("triggered",triggeredShopButton);
         shopButton = null;
         useButton.removeEventListener("triggered",triggeredUseButton);
         useButton = null;
         descText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
