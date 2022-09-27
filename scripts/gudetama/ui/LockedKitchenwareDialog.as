package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.MissionData;
   import gudetama.data.compati.MissionDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.mission.MissionScene;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LockedKitchenwareDialog extends BaseScene
   {
       
      
      private var shopButton:ContainerButton;
      
      private var missionButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var itemId:int;
      
      private var isMission:Boolean = false;
      
      private var missionType:int;
      
      private var missionDef:MissionDef;
      
      private var desc:ColorTextField;
      
      private var kitchenwareType:int;
      
      private var grade:int;
      
      public function LockedKitchenwareDialog(param1:int, param2:int)
      {
         var _loc3_:int = 0;
         super(2);
         grade = param2;
         kitchenwareType = param1;
         itemId = GameSetting.getKitchenwareByType(param1,param2).id#2;
         var _loc4_:Array;
         isMission = _loc4_ = GameSetting.def.kitchenwareConditionMap[itemId];
         if(isMission)
         {
            _loc3_ = _loc4_[1];
            missionDef = GameSetting.getMission(_loc3_);
            if(missionDef.number == -1)
            {
               missionType = 0;
            }
            else if(missionDef.eventId > 0)
            {
               missionType = 2;
            }
            else
            {
               missionType = 1;
            }
         }
      }
      
      public static function show(param1:int, param2:int) : void
      {
         Engine.pushScene(new LockedKitchenwareDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LockedKitchenwareDialog",function(param1:Object):void
         {
            var _loc3_:* = null;
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            shopButton = _loc2_.getChildByName("shopButton") as ContainerButton;
            shopButton.addEventListener("triggered",triggeredShopButton);
            missionButton = _loc2_.getChildByName("missionButton") as ContainerButton;
            missionButton.addEventListener("triggered",triggeredShopButton);
            shopButton.visible = !isMission;
            missionButton.visible = isMission;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            desc = _loc2_.getChildByName("desc") as ColorTextField;
            if(isMission)
            {
               _loc3_ = UserDataWrapper.missionPart.getMissionDataById(missionDef.id#2);
               desc.text#2 = StringUtil.format(GameSetting.getUIText("lockedKitchenware.mission.desc"),_loc3_.title,GameSetting.getUIText("kitchenware.type.name." + kitchenwareType),grade + 1);
            }
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LockedKitchenwareDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LockedKitchenwareDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LockedKitchenwareDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LockedKitchenwareDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredShopButton(param1:Event) : void
      {
         var event:Event = param1;
         if(isMission)
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(144,function():void
            {
               Engine.switchScene(new MissionScene(missionType,missionDef.id#2));
            });
         }
         else
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
            {
               Engine.switchScene(new ShopScene_Gudetama());
            });
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         shopButton.removeEventListener("triggered",triggeredShopButton);
         shopButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
