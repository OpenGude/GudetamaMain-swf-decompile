package gudetama.scene.friend
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.FriendInfo;
   import gudetama.data.compati.FriendPresentResult;
   import gudetama.data.compati.FriendlyDef;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.data.compati.UserProfileData;
   import gudetama.data.compati.UserWantedData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.CookingGuideDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.PresentLogListItemRenderer;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class FriendDetailDialog extends BaseScene
   {
       
      
      private var param:Object;
      
      private var profile:UserProfileData;
      
      private var state:int;
      
      private var nameText:ColorTextField;
      
      private var areaText:ColorTextField;
      
      private var iconImage:Image;
      
      private var imgSns:Image;
      
      private var levelText:ColorTextField;
      
      private var wantedOthers:Vector.<WantedOtherUI>;
      
      private var heartGaugeGroup:HeartGaugeGroup;
      
      private var friendlyText:ColorTextField;
      
      private var removeButton:ContainerButton;
      
      private var roomButton:ContainerButton;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var friendInfo:FriendInfo;
      
      private var collection:ListCollection;
      
      private var wantedGroup:Sprite;
      
      private var gaugeGroup:Sprite;
      
      private var loadCount:int;
      
      public function FriendDetailDialog(param1:Object, param2:int)
      {
         wantedOthers = new Vector.<WantedOtherUI>();
         collection = new ListCollection();
         super(2);
         this.param = param1;
         profile = param1.profile;
         this.state = param2;
      }
      
      public static function show(param1:Object, param2:int = 94) : void
      {
         Engine.pushScene(new FriendDetailDialog(param1,param2),0,false);
      }
      
      public static function sendPresentGude(param1:int, param2:int, param3:UserProfileData, param4:Boolean, param5:Function, param6:Function, param7:Function, param8:Function) : void
      {
         var event:int = param1;
         var gudeId:int = param2;
         var prof:UserProfileData = param3;
         var isDeliver:Boolean = param4;
         var successFunc:Function = param5;
         var noMutualFunc:Function = param6;
         var noWantFunc:Function = param7;
         var deliverEndFunc:Function = param8;
         Engine.showLoading(sendPresentGude);
         var _loc9_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(event,[prof.encodedUid,gudeId,isDeliver]),function(param1:Object):void
         {
            var response:Object = param1;
            Engine.hideLoading(sendPresentGude);
            if(!(response is FriendPresentResult))
            {
               if(response is Array)
               {
                  if(response[0] == -1)
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("friendDetail.warning.1"),function(param1:int):void
                     {
                        noMutualFunc();
                     },GameSetting.getUIText("friendDetail.present.title"));
                  }
                  else if(response[0] == -2)
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("friendDetail.warning.2"),function(param1:int):void
                     {
                        noWantFunc();
                     },GameSetting.getUIText("friendDetail.present.title"));
                  }
               }
               else if(response is int)
               {
                  if(response == -1)
                  {
                     if(deliverEndFunc != null)
                     {
                        deliverEndFunc();
                     }
                     LocalMessageDialog.show(1,GameSetting.getUIText("ranking.err.deliver.event.end").replace("%1",UserDataWrapper.eventPart.getRankingPointText()),function(param1:int):void
                     {
                        if(param1 != 0)
                        {
                           return;
                        }
                        sendPresentGude(event,gudeId,prof,false,successFunc,noMutualFunc,noWantFunc,deliverEndFunc);
                     },GameSetting.getUIText("friendDetail.present.title"));
                  }
               }
               return;
            }
            var result:FriendPresentResult = response as FriendPresentResult;
            if(event == 168)
            {
               ResidentMenuUI_Gudetama.consumeMetal(GameSetting.getRule().friendPresentCost);
            }
            else if(event == 241)
            {
               ResidentMenuUI_Gudetama.consumeMoney(GameSetting.getRule().friendPresentGp);
            }
            UserDataWrapper.gudetamaPart.addRecipe(result.consumedGudetama);
            UserDataWrapper.wrapper.updateFriendlyData(result.friendlyData);
            var friendPresentLogDiff:Array = result.friendPresentLogDiff;
            UserDataWrapper.wrapper.addFriendPresentLogs(prof.encodedUid,friendPresentLogDiff);
            UserDataWrapper.wrapper.increaseNumFriendPresentForGPWhileEvent(result.deliveredEventIds);
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            if(successFunc != null)
            {
               successFunc(result);
            }
            Engine.broadcastEventToSceneStackWith("update_scene");
            if(result.lastFriendly != UserDataWrapper.wrapper.getFriendly(prof.encodedUid))
            {
               FriendlyResultDialog.show(GameSetting.getUIText("friendlyResult.title"),GameSetting.getUIText("friendlyResult.present.desc"),result.addFriendly,function():void
               {
                  FriendlyRewardDialog.show([[UserDataWrapper.wrapper.getFriendlyData(prof.encodedUid),[result.lastFriendlyLevel],prof]]);
               });
            }
            else
            {
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("friendlyResult.full.present.desc"),prof.playerName),null,GameSetting.getUIText("friendlyResult.full.present.title"));
            }
         });
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FriendDetailDialog",function(param1:Object):void
         {
            var _loc4_:int = 0;
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            nameText = _loc2_.getChildByName("name") as ColorTextField;
            areaText = _loc2_.getChildByName("area") as ColorTextField;
            iconImage = _loc2_.getChildByName("icon") as Image;
            imgSns = _loc2_.getChildByName("imgSns") as Image;
            imgSns.visible = false;
            levelText = _loc2_.getChildByName("level") as ColorTextField;
            var _loc3_:Boolean = GudetamaUtil.isOpenRanking(5);
            wantedGroup = _loc2_.getChildByName("wantedGroup") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < wantedGroup.numChildren)
            {
               wantedOthers.push(new WantedOtherUI(wantedGroup.getChildByName("wanted" + _loc4_) as Sprite,profile,_loc4_,triggeredWantedOtherUICallback,_loc3_));
               _loc4_++;
            }
            heartGaugeGroup = new HeartGaugeGroup(_loc2_.getChildByName("heartGroup") as Sprite);
            friendlyText = _loc2_.getChildByName("friendly") as ColorTextField;
            removeButton = _loc2_.getChildByName("removeButton") as ContainerButton;
            removeButton.enableDrawCache();
            removeButton.addEventListener("triggered",triggeredRemoveButton);
            roomButton = _loc2_.getChildByName("roomButton") as ContainerButton;
            roomButton.enableDrawCache();
            roomButton.addEventListener("triggered",triggeredHomeButton);
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.enableDrawCache();
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_PresentLogItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(167,profile.encodedUid),function(param1:FriendInfo):void
            {
               friendInfo = param1;
               UserDataWrapper.wrapper.updateFriendlyData(friendInfo.friendlyData);
               UserDataWrapper.wrapper.addFriendPresentLogs(profile.encodedUid,param1.friendPresentLogDiff);
               taskDone();
            });
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
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 18;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new PresentLogListItemRenderer(extractor,false);
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
         setup();
      }
      
      private function setup() : void
      {
         nameText.text#2 = profile.playerName;
         if(Engine.getLocale() == "ja")
         {
            areaText.text#2 = StringUtil.format(GameSetting.getUIText("profile.area"),GameSetting.getUIText("profile.area." + profile.area));
         }
         else
         {
            areaText.text#2 = StringUtil.format(GameSetting.getUIText("profile.area"),GameSetting.getUIText("profile.area." + profile.area) + GameSetting.getUIText("profile.area.slash") + GameSetting.getUIText("profile.area.gudetama." + profile.area));
         }
         if(profile.snsProfileImage != null)
         {
            queue.addTask(function():void
            {
               GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
               {
                  iconImage.texture = param1;
                  queue.taskDone();
               });
            });
            TextureCollector.loadSnsImage(profile.snsType,queue,function(param1:Texture):void
            {
               if(param1 != null)
               {
                  imgSns.texture = param1;
                  imgSns.visible = true;
               }
            });
         }
         else
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(profile.avatar).rsrc,function(param1:Texture):void
               {
                  iconImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
         levelText.text#2 = profile.playerRank.toString();
         roomButton.visible = !param.disabledRoomButton;
         var friendlyDef:FriendlyDef = GameSetting.getFriendly();
         var heartBorders:Array = friendlyDef.heartBorders;
         heartGaugeGroup.setup(heartBorders);
         update(false);
      }
      
      private function update(param1:Boolean = true) : void
      {
         var _loc6_:int = 0;
         var _loc4_:int = UserDataWrapper.wrapper.getFriendly(profile.encodedUid);
         var _loc5_:int = UserDataWrapper.wrapper.getFriendlyLevel(profile.encodedUid);
         var _loc7_:FriendlyDef;
         var _loc2_:Array = (_loc7_ = GameSetting.getFriendly()).heartBorders;
         updateWantedOther();
         friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("friendDetail.friendly"),_loc4_,_loc7_.heartBorders[_loc2_.length - 1]);
         collection.removeAll();
         var _loc3_:Array = UserDataWrapper.wrapper.getFriendPresentLogs(profile.encodedUid);
         _loc6_ = _loc3_.length - 1;
         while(_loc6_ >= 0)
         {
            collection.addItem({
               "encodedUid":profile.encodedUid,
               "name":profile.playerName,
               "presentLog":_loc3_[_loc6_]
            });
            _loc6_--;
         }
         if(param1)
         {
            updateWithAnimation();
         }
      }
      
      private function updateWantedOther() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         _loc1_ = 0;
         while(_loc1_ < wantedOthers.length)
         {
            _loc2_ = wantedOthers[_loc1_];
            _loc2_.setup(friendInfo.wantedGudetamas[_loc1_]);
            _loc1_++;
         }
      }
      
      private function updateWithAnimation() : void
      {
         var _loc1_:int = UserDataWrapper.wrapper.getFriendly(profile.encodedUid);
         heartGaugeGroup.value = _loc1_;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(FriendDetailDialog);
         setVisibleState(state);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            processNoticeTutorial(11,null,getGuideArrowPos);
            Engine.unlockTouchInput(FriendDetailDialog);
            updateWithAnimation();
            FriendlyRewardDialog.show([[UserDataWrapper.wrapper.getFriendlyData(profile.encodedUid),[friendInfo.lastFriendlyLevel],profile]]);
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         heartGaugeGroup.advanceTime();
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(FriendDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendDetailDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1))
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(wantedGroup);
            case 1:
               return GudetamaUtil.getCenterPosAndWHOnEngine(friendlyText);
            case 2:
               return GudetamaUtil.getCenterPosAndWHOnEngine(roomButton);
            default:
               return _loc2_;
         }
      }
      
      private function triggeredHomeButton(param1:Event) : void
      {
         var event:Event = param1;
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
         {
            Engine.switchScene(new FriendRoomScene(profile,param.backFromRoomFunc));
         });
      }
      
      private function triggeredRemoveButton(param1:Event) : void
      {
         var event:Event = param1;
         LocalMessageDialog.show(1,StringUtil.format(GameSetting.getUIText("friendDetail.confirm.removeFriend.desc"),profile.playerName),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            back(function():void
            {
               param.removeFunc();
            });
         },GameSetting.getUIText("friendDetail.confirm.removeFriend.title"));
      }
      
      private function triggeredWantedOtherUICallback(param1:int) : void
      {
         var index:int = param1;
         var userWantedData:UserWantedData = friendInfo.wantedGudetamas[index];
         if(UserDataWrapper.gudetamaPart.getNumGudetama(userWantedData.id#2) <= 0)
         {
            showCookingGuideDialog(userWantedData);
            return;
         }
         var deliverPoint:int = GudetamaUtil.getDeliverPoint(profile,userWantedData.id#2);
         FriendPresentConfirmDialog.show(userWantedData.id#2,profile.encodedUid,deliverPoint,function(param1:int):void
         {
            if(param1 == 0)
            {
               return;
            }
            sendPresentGude(param1,userWantedData.id#2,profile,deliverPoint > 0,presentGudeSuccessCallback,presentGudeNoMutualCallback,presentGudeNoWantCallback,presentGudeDeliverEndCallback);
         });
      }
      
      private function showCookingGuideDialog(param1:UserWantedData) : void
      {
         var userWantedData:UserWantedData = param1;
         var showMessageDialog:Function = function():void
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.present.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
         };
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(userWantedData.id#2);
         if(!UserDataWrapper.gudetamaPart.isAvailable(gudetamaDef.id#2))
         {
            showMessageDialog();
            return;
         }
         if(!UserDataWrapper.recipeNotePart.isPurchased(gudetamaDef.recipeNoteId))
         {
            showMessageDialog();
            return;
         }
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         if(!recipeNoteDef)
         {
            showMessageDialog();
            return;
         }
         var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(recipeNoteDef.kitchenwareId);
         if(!kitchenwareDef)
         {
            showMessageDialog();
            return;
         }
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2,
            "recipeNoteId":recipeNoteDef.id#2,
            "gudetamaId":gudetamaDef.id#2
         };
         CookingGuideDialog.show(function():void
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
            {
               Engine.switchScene(new HomeScene(param.kitchenwareType,param));
            });
         });
      }
      
      private function presentGudeSuccessCallback(param1:FriendPresentResult) : void
      {
         friendInfo.lastFriendlyLevel = param1.lastFriendlyLevel;
         update();
      }
      
      private function presentGudeNoMutualCallback() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
         {
            Engine.switchScene(new FriendScene_Gudetama());
         });
      }
      
      private function presentGudeNoWantCallback() : void
      {
         Engine.lockTouchInput(FriendDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendDetailDialog);
            Engine.popScene(scene);
            FriendDetailDialog.show(param,state);
         });
      }
      
      private function presentGudeDeliverEndCallback() : void
      {
         updateWantedOther();
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         nameText = null;
         areaText = null;
         iconImage = null;
         imgSns = null;
         levelText = null;
         if(heartGaugeGroup)
         {
            heartGaugeGroup.dispose();
            heartGaugeGroup = null;
         }
         friendlyText = null;
         if(roomButton)
         {
            roomButton.removeEventListener("triggered",triggeredHomeButton);
            roomButton = null;
         }
         for each(var _loc1_ in wantedOthers)
         {
            _loc1_.dispose();
         }
         wantedOthers.length = 0;
         wantedOthers = null;
         list = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         extractor = null;
         friendInfo = null;
         wantedGroup = null;
         gaugeGroup = null;
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.RankingDef;
import gudetama.data.compati.UserProfileData;
import gudetama.data.compati.UserWantedData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class WantedOtherUI extends UIBase
{
    
   
   private var profile:UserProfileData;
   
   private var index:int;
   
   private var callback:Function;
   
   private var needDeliver:Boolean;
   
   private var button:ContainerButton;
   
   private var noneImage:Image;
   
   private var iconGroup:Sprite;
   
   private var iconImage:Image;
   
   private var numberText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var spDeliver:Sprite;
   
   private var balloon:Image;
   
   private var lblDeliver:ColorTextField;
   
   function WantedOtherUI(param1:Sprite, param2:UserProfileData, param3:int, param4:Function, param5:Boolean)
   {
      var _loc6_:* = null;
      super(param1);
      this.profile = param2;
      this.index = param3;
      this.callback = param4;
      this.needDeliver = param5;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      noneImage = button.getChildByName("none") as Image;
      iconGroup = button.getChildByName("iconGroup") as Sprite;
      iconImage = iconGroup.getChildByName("icon") as Image;
      numberText = iconGroup.getChildByName("number") as ColorTextField;
      nameText = iconGroup.getChildByName("name") as ColorTextField;
      spDeliver = param1.getChildByName("spDeliver") as Sprite;
      balloon = spDeliver.getChildByName("balloon") as Image;
      lblDeliver = spDeliver.getChildByName("lblDeliver") as ColorTextField;
      var _loc7_:Array;
      if((_loc7_ = UserDataWrapper.eventPart.getRankingIds(true)) && _loc7_.length > 0)
      {
         _loc6_ = GameSetting.getRanking(_loc7_[0]);
         lblDeliver.color = _loc6_.pointTextColor;
      }
   }
   
   public function setup(param1:UserWantedData) : void
   {
      var userWantedData:UserWantedData = param1;
      if(userWantedData.id#2 > 0)
      {
         noneImage.visible = false;
         iconGroup.visible = true;
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(userWantedData.id#2);
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
            button.enableDrawCache();
            button.enabled = true;
         });
         if(gudetamaDef.type != 1)
         {
            numberText.visible = false;
         }
         numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
         nameText.text#2 = gudetamaDef.name#2;
         var deliverPts:int = !!needDeliver ? GudetamaUtil.getDeliverPoint(profile,gudetamaDef.id#2) : 0;
         if(deliverPts > 0)
         {
            var rankingIds:Array = UserDataWrapper.eventPart.getRankingIds(true);
            if(rankingIds)
            {
               TextureCollector.loadTexture("event" + (rankingIds[0] - 1) + "@friend_item",function(param1:Texture):void
               {
                  balloon.texture = param1;
               });
            }
            lblDeliver.text#2 = GameSetting.getUIText("friendlyResult.value").replace("%1",deliverPts);
            spDeliver.visible = true;
         }
         else
         {
            spDeliver.visible = false;
         }
         button.enableDrawCache();
         button.enabled = true;
      }
      else
      {
         noneImage.visible = true;
         iconGroup.visible = false;
         spDeliver.visible = false;
         button.enableDrawCache();
         button.enabled = false;
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(index);
   }
   
   public function dispose() : void
   {
      profile = null;
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      noneImage = null;
      iconGroup = null;
      numberText = null;
      nameText = null;
      lblDeliver = null;
   }
}
