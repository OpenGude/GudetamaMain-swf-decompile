package gudetama.scene.shop
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GachaDef;
   import gudetama.data.compati.GachaPriceDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.ScreeningGachaItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class GachaConfirmDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var index:int;
      
      private var callback:Function;
      
      private var dialogSprite:Sprite;
      
      private var titleText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var playButtonGroup:Sprite;
      
      private var playButtonUIs:Vector.<GachaPlayButtonUI>;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function GachaConfirmDialog(param1:int, param2:int, param3:Function)
      {
         playButtonUIs = new Vector.<GachaPlayButtonUI>();
         super(2);
         this.id = param1;
         this.index = param2;
         this.callback = param3;
      }
      
      public static function show(param1:int, param2:int, param3:Function) : void
      {
         Engine.pushScene(new GachaConfirmDialog(param1,param2,param3),0,false);
      }
      
      private function checkCompleted() : int
      {
         var _loc5_:GachaDef = GameSetting.getGacha(id);
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         for each(var _loc7_ in _loc5_.screeningItems)
         {
            if(_loc7_.item.kind == 7)
            {
               _loc2_++;
               if(UserDataWrapper.gudetamaPart.hasRecipe(_loc7_.item.id#2))
               {
                  _loc3_++;
               }
            }
            else if(_loc7_.item.kind == 6)
            {
               _loc6_++;
               if(UserDataWrapper.gudetamaPart.hasRecipe(_loc7_.item.id#2))
               {
                  _loc4_++;
               }
            }
         }
         if(_loc2_ > 0 && _loc6_ > 0)
         {
            if(_loc2_ == _loc3_ && _loc6_ == _loc4_)
            {
               _loc1_ = 1;
            }
         }
         else if(_loc6_ > 0)
         {
            if(_loc6_ == _loc4_)
            {
               _loc1_ = 2;
            }
         }
         else if(_loc2_ > 0)
         {
            if(_loc2_ == _loc3_)
            {
               _loc1_ = 3;
            }
         }
         return _loc1_;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var type:int = checkCompleted();
         setupLayoutForTask(queue,type > 0 ? "GachaCompletedConfirmDialog" : "GachaConfirmDialog",function(param1:Object):void
         {
            var _loc3_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = dialogSprite.getChildByName("title") as ColorTextField;
            messageText = dialogSprite.getChildByName("message") as ColorTextField;
            playButtonGroup = dialogSprite.getChildByName("playButtonGroup") as Sprite;
            _loc3_ = 0;
            while(_loc3_ < playButtonGroup.numChildren)
            {
               _loc2_ = new GachaPlayButtonUI(playButtonGroup.getChildByName("playButton" + _loc3_) as Sprite,triggeredConfirmCallback);
               _loc2_.disabledBalloon = true;
               playButtonUIs.push(_loc2_);
               _loc3_++;
            }
            closeButton = dialogSprite.getChildByName("btn_back") as ContainerButton;
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
         var gachaDef:GachaDef = GameSetting.getGacha(id);
         if(UserDataWrapper.gachaPart.playableAtFree(gachaDef.id#2))
         {
            setupFree(gachaDef);
         }
         else
         {
            setupMoneyOrMetal(gachaDef);
         }
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,!!existsBalloon() ? "pos1" : "pos0",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      private function existsBalloon() : Boolean
      {
         for each(var _loc1_ in playButtonUIs)
         {
            if(_loc1_.existsBalloon())
            {
               return true;
            }
         }
         return false;
      }
      
      private function setupFree(param1:GachaDef) : void
      {
         var _loc5_:int = 0;
         var _loc2_:* = null;
         playButtonUIs[0].setupFree(param1);
         playButtonUIs[1].setVisible(false);
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         _loc5_ = 0;
         while(_loc5_ < playButtonUIs.length)
         {
            _loc2_ = playButtonUIs[_loc5_];
            if(_loc2_.isVisible())
            {
               _loc2_.getDisplaySprite().x = _loc3_;
               _loc3_ += _loc2_.width + 10;
               _loc4_ = Number(_loc3_ - 10);
            }
            _loc5_++;
         }
         playButtonGroup.x = 0.5 * (dialogSprite.width - _loc4_);
      }
      
      private function setupMoneyOrMetal(param1:GachaDef) : void
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:int = 0;
         var _loc7_:* = null;
         var _loc8_:ItemParam = GachaScene_Gudetama.getPrice(param1,index);
         var _loc13_:ItemParam = GachaScene_Gudetama.getLastPrice(param1,index);
         var _loc5_:GachaPriceDef = param1.prices[index];
         var _loc6_:int = UserDataWrapper.wrapper.getMoney();
         var _loc3_:int = UserDataWrapper.gachaPart.getRestCountAtDaily(param1.id#2,index);
         var _loc4_:int;
         if((_loc4_ = checkCompleted()) > 0)
         {
            titleText.text#2 = GameSetting.getUIText("gachaCompletedConfirm.title." + _loc4_);
            if(messageText)
            {
               messageText.text#2 = GameSetting.getUIText("gachaCompletedConfirm.msg." + _loc4_);
            }
         }
         else
         {
            titleText.text#2 = GameSetting.getUIText("gachaConfirm.title." + _loc8_.kind);
         }
         playButtonUIs[0].setup(param1,index,true);
         if(_loc5_.enabledCollect && _loc5_.num == 1)
         {
            _loc11_ = Math.min(_loc3_,_loc6_ / _loc8_.num);
            _loc12_ = UserDataWrapper.wrapper.getNumItem(_loc8_.kind,_loc8_.id#2);
            if(_loc5_.numDaily > 0 && _loc11_ > 1 && _loc8_.kind == 0)
            {
               playButtonUIs[1].setupMoneyAll(param1,index);
            }
            else if(_loc12_ > 1 && _loc8_.kind == 8)
            {
               if(_loc13_.kind == 0)
               {
                  playButtonUIs[1].setupMoneyTicketAll(param1,index);
               }
               else
               {
                  playButtonUIs[1].setupMetalTicketAll(param1,index);
               }
            }
            else
            {
               playButtonUIs[1].setVisible(false);
            }
         }
         else
         {
            playButtonUIs[1].setVisible(false);
         }
         var _loc9_:* = 0;
         var _loc10_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < playButtonUIs.length)
         {
            if((_loc7_ = playButtonUIs[_loc2_]).isVisible())
            {
               _loc7_.getDisplaySprite().x = _loc9_;
               _loc10_ = Number((_loc9_ += _loc7_.width + 10) - 10);
            }
            _loc2_++;
         }
         playButtonGroup.x = 0.5 * (dialogSprite.width - _loc10_);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GachaConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(GachaConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(GachaConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GachaConfirmDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredConfirmCallback(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         if(callback)
         {
            callback(param3);
         }
         backButtonCallback();
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         callback = null;
         titleText = null;
         if(playButtonUIs)
         {
            for each(var _loc1_ in playButtonUIs)
            {
               _loc1_.dispose();
            }
            playButtonUIs.length = 0;
            playButtonUIs = null;
         }
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
