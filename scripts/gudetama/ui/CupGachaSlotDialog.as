package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.CupGachaData;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.CupGachaResult;
   import gudetama.data.compati.RuleDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.util.TimeZoneUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class CupGachaSlotDialog extends BaseScene
   {
       
      
      private var homeScene:HomeScene;
      
      private var beforeCloseFunc:Function;
      
      private var placeGudeId:int;
      
      private var selectIdx:int = -1;
      
      private var consumeEgg:int = 0;
      
      private var nextCheckSec:int = -1;
      
      private var opened:Boolean;
      
      private var isGuide:Boolean = false;
      
      private var restCookCompleteTextBase:String;
      
      private var lblName:ColorTextField;
      
      private var btnPrizeList:ContainerButton;
      
      private var rarityUI:RarityUI;
      
      private var imgCup:Image;
      
      private var spCookInfo:Sprite;
      
      private var lblCookInfo:ColorTextField;
      
      private var spNoCook:Sprite;
      
      private var btnCook:ContainerButton;
      
      private var lblCook:ColorTextField;
      
      private var spCooking:Sprite;
      
      private var btnAd:ContainerButton;
      
      private var btnEgg:ContainerButton;
      
      private var lblEggNum:ColorTextField;
      
      private var spOpen:Sprite;
      
      private var btnOpen:ContainerButton;
      
      private var spOther:Sprite;
      
      private var slots:Array;
      
      public function CupGachaSlotDialog(param1:HomeScene, param2:Function)
      {
         slots = [];
         super(2);
         this.homeScene = param1;
         this.beforeCloseFunc = param2;
         placeGudeId = UserDataWrapper.wrapper.getPlacedGudetamaId();
         restCookCompleteTextBase = GameSetting.getUIText("cupgacha.cook.rest");
      }
      
      public static function show(param1:HomeScene, param2:Function) : void
      {
         Engine.showLoading(CupGachaSlotDialog);
         Engine.pushScene(new CupGachaSlotDialog(param1,param2),0,false);
      }
      
      private function setGuideUI(param1:Boolean) : void
      {
         btnPrizeList.setEnableWithDrawCache(true,false,!param1);
         btnAd.setEnableWithDrawCache(true,false,!param1);
         btnEgg.setEnableWithDrawCache(true,false,!param1);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CupGachaSlotDialog",function(param1:Object):void
         {
            var _loc7_:int = 0;
            var _loc9_:* = null;
            displaySprite = param1.object;
            var _loc4_:Sprite;
            var _loc5_:Sprite;
            lblName = (_loc4_ = (_loc5_ = displaySprite.getChildByName("dialog") as Sprite).getChildByName("spName") as Sprite).getChildByName("lblName") as ColorTextField;
            var _loc2_:Sprite = _loc5_.getChildByName("spRarity") as Sprite;
            rarityUI = new RarityUI(_loc2_);
            imgCup = _loc5_.getChildByName("imgCup") as Image;
            btnPrizeList = _loc5_.getChildByName("btnPrizeList") as ContainerButton;
            btnPrizeList.addEventListener("triggered",triggeredPrizeList);
            spCookInfo = _loc5_.getChildByName("spCookInfo") as Sprite;
            lblCookInfo = spCookInfo.getChildByName("lblCookInfo") as ColorTextField;
            spNoCook = _loc5_.getChildByName("spNoCook") as Sprite;
            btnCook = spNoCook.getChildByName("btnCook") as ContainerButton;
            btnCook.addEventListener("triggered",triggeredCook);
            lblCook = btnCook.getChildByName("lblCook") as ColorTextField;
            spCooking = _loc5_.getChildByName("spCooking") as Sprite;
            btnEgg = spCooking.getChildByName("btnEgg") as ContainerButton;
            btnEgg.addEventListener("triggered",triggeredOpen);
            lblEggNum = btnEgg.getChildByName("lblEggNum") as ColorTextField;
            btnAd = spCooking.getChildByName("btnAd") as ContainerButton;
            btnAd.addEventListener("triggered",triggeredAd);
            var _loc6_:ColorTextField = btnAd.getChildByName("text") as ColorTextField;
            var _loc3_:int = GameSetting.getRule().cupGachaShortMinByAd;
            _loc6_.text#2 = GameSetting.getUIText("cupgacha.btn.short.video").replace("%1",GudetamaUtil.getHourAndMinuteStringByMinute(_loc3_));
            spOpen = _loc5_.getChildByName("spOpen") as Sprite;
            btnOpen = spOpen.getChildByName("btnOpen") as ContainerButton;
            btnOpen.addEventListener("triggered",triggeredOpen);
            spOther = _loc5_.getChildByName("spOther") as Sprite;
            var _loc8_:UserDataWrapper = UserDataWrapper.wrapper;
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               _loc9_ = new CupGachaSlotUI(_loc5_.getChildByName("spSlot" + _loc7_) as Sprite,_loc7_,_loc8_.getCupGachaIdAt(_loc7_),selectSlot);
               slots.push(_loc9_);
               _loc7_++;
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
            setup();
         });
         queue.startTask(onProgress);
      }
      
      private function setup() : void
      {
         for each(var _loc1_ in slots)
         {
            _loc1_.setup();
         }
         var _loc2_:UserDataWrapper = UserDataWrapper.wrapper;
         var _loc3_:int = _loc2_.getCookIndex4CupGacha();
         if(_loc3_ < 0)
         {
            _loc3_ = _loc2_.getCupGachaIndexNoEmpty();
         }
         selectSlot(_loc3_);
      }
      
      private function selectSlot(param1:int, param2:Boolean = false) : void
      {
         var idx:int = param1;
         var force:Boolean = param2;
         if(idx == selectIdx && !force)
         {
            return;
         }
         if(selectIdx >= 0 && selectIdx != idx)
         {
            CupGachaSlotUI(slots[selectIdx]).setSelect(false);
         }
         selectIdx = idx;
         var newSlot:CupGachaSlotUI = slots[idx];
         newSlot.setSelect(true);
         var def:CupGachaDef = GameSetting.getCupGacha(newSlot.id#2);
         lblName.text#2 = def.name#2;
         TextureCollector.loadTexture(GudetamaUtil.getItemImageName(19,def.id#2),function(param1:Texture):void
         {
            if(imgCup)
            {
               imgCup.texture = param1;
            }
         });
         rarityUI.updateRarity(def.rarity);
         nextCheckSec = -1;
         var udWrapper:UserDataWrapper = UserDataWrapper.wrapper;
         var cookIdx:int = udWrapper.getCookIndex4CupGacha();
         if(cookIdx == -1)
         {
            lblCook.text#2 = GameSetting.getUIText("%cooking.button.cooking") + "\n" + GudetamaUtil.getHourAndMinuteStringByMinute(def.cookMin);
            spNoCook.visible = true;
            spCookInfo.visible = false;
            spCooking.visible = false;
            spOpen.visible = false;
            spOther.visible = false;
         }
         else if(cookIdx != idx)
         {
            lblCookInfo.text#2 = GameSetting.getUIText("cupgacha.cook.time").replace("%1",GudetamaUtil.getCupGachaCookTimeString(def));
            spOther.visible = true;
            spCookInfo.visible = true;
            spNoCook.visible = false;
            spCooking.visible = false;
            spOpen.visible = false;
         }
         else
         {
            var restSec:int = udWrapper.getRestSec4CupGacha();
            if(restSec > 0)
            {
               calcConsumeEgg(0,restSec);
               lblEggNum.text#2 = consumeEgg.toString();
               btnAd.setEnableWithDrawCache(udWrapper.getShowAdNum4CupGacha() < GameSetting.getRule().cupGachaShortNumByAd);
               var hourSec:int = 3600;
               var minSec:int = 60;
               var hour:int = restSec / hourSec;
               var minute:int = (restSec - hour * hourSec) / minSec;
               var second:int = restSec - hour * hourSec - minute * minSec;
               lblCookInfo.text#2 = restCookCompleteTextBase.replace("%1",GudetamaUtil.getRestTimeString(hour,minute,second));
               spCooking.visible = true;
               spCookInfo.visible = true;
               spNoCook.visible = false;
               spOther.visible = false;
               spOpen.visible = false;
            }
            else
            {
               lblCookInfo.text#2 = GameSetting.getUIText("cupgacha.cook.complete");
               consumeEgg = 0;
               spOpen.visible = true;
               spCookInfo.visible = true;
               spNoCook.visible = false;
               spCooking.visible = false;
               spOther.visible = false;
            }
         }
      }
      
      private function calcConsumeEgg(param1:int, param2:int = 0) : void
      {
         var _loc3_:* = param1 == 0;
         var _loc4_:int = 0;
         var _loc5_:RuleDef = GameSetting.getRule();
         if(_loc3_)
         {
            if(param2 > 0)
            {
               _loc4_ = Math.ceil(param2 / 60);
               nextCheckSec = TimeZoneUtil.epochMillisToOffsetSecs() + param2 % (_loc5_.cupGachaOpenMinPerTier * 60);
            }
         }
         else
         {
            _loc4_ = GameSetting.getCupGacha(param1).cookMin;
         }
         consumeEgg = 0;
         if(_loc4_ > 0)
         {
            consumeEgg = Math.ceil(_loc4_ / _loc5_.cupGachaOpenMinPerTier) * _loc5_.cupGachaOpenMetalPerTier;
         }
      }
      
      private function triggeredCook() : void
      {
         Engine.showLoading(triggeredCook);
         var _loc1_:* = UserDataWrapper;
         var cupData:CupGachaData = gudetama.data.UserDataWrapper.wrapper._data.cupGachaData;
         var cupGudeID:int = cupData.cupGachaIds[selectIdx];
         var cupGudeRsrcID:int = GameSetting.getCupGacha(cupGudeID).rsrc;
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(16777217,selectIdx),function(param1:int):void
         {
            var res:int = param1;
            Engine.hideLoading(triggeredCook);
            CupGachaAnimePanel.show(false,cupGudeRsrcID,null,function():void
            {
               var _loc1_:int = res;
               UserDataWrapper.wrapper.cookCupGacha(selectIdx,_loc1_);
               selectSlot(selectIdx,true);
               var _loc2_:CupGachaSlotUI = slots[selectIdx];
               _loc2_.setup(_loc1_);
               if(isGuide)
               {
                  resumeNoticeTutorial(27);
               }
            });
         });
      }
      
      private function triggeredAd() : void
      {
         VideoAdConfirmDialog.show("start2",GameSetting.getUIText("videoAdConfirm.title"),GameSetting.getUIText("videoAdConfirm.cupgacha.desc"),GameSetting.getUIText("videoAdConfirm.cupgacha.caution"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            Engine.showLoading(triggeredAd);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(16777218),function(param1:int):void
            {
               Engine.hideLoading(triggeredAd);
               var _loc2_:* = param1;
               var _loc3_:UserDataWrapper = UserDataWrapper.wrapper;
               _loc3_.setCupGachaRestSec(_loc2_);
               _loc3_.incrementShowAdNum4CupGacha();
               selectSlot(selectIdx,true);
               var _loc4_:CupGachaSlotUI;
               (_loc4_ = slots[selectIdx]).setup(_loc2_);
               LocalMessageDialog.show(0,GameSetting.getUIText("cupgacha.shorten.video"));
            });
         });
      }
      
      private function triggeredOpen() : void
      {
         if(consumeEgg > 0)
         {
            var udWrapper:UserDataWrapper = UserDataWrapper.wrapper;
            var less:int = consumeEgg - udWrapper.getMetal();
            if(less > 0)
            {
               LessMetalDialog.show(less);
               return;
            }
            var restSec:int = udWrapper.getRestSec4CupGacha();
            var ruleDef:RuleDef = GameSetting.def.rule;
            var restMin:int = consumeEgg / ruleDef.cupGachaOpenMetalPerTier * ruleDef.cupGachaOpenMinPerTier;
            LocalMessageDialog.show(1,GameSetting.getUIText("cupgacha.confirm.use.egg").replace("%1",consumeEgg).replace("%2",GudetamaUtil.getHourAndMinuteStringByMinute(restMin)),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               sendOpen();
            });
            return;
         }
         sendOpen();
      }
      
      private function sendOpen() : void
      {
         Engine.showLoading(sendOpen);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(16777219,selectIdx),function(param1:Array):void
         {
            var res:Array = param1;
            Engine.hideLoading(sendOpen);
            opened = true;
            var result:CupGachaResult = res[0];
            var cosumeEgg:int = res[1];
            var udWrapper:UserDataWrapper = UserDataWrapper.wrapper;
            if(consumeEgg > 0)
            {
               ResidentMenuUI_Gudetama.consumeMetal(consumeEgg);
            }
            udWrapper.setCupGachaAt(selectIdx,0);
            udWrapper.addCupGachaResult(result);
            udWrapper.showCupGachaResults(0,function():void
            {
               if(isGuide)
               {
                  setVisibleState(94);
               }
               var _loc1_:int = udWrapper.getCupGachaIndexNoEmpty();
               if(_loc1_ == -1)
               {
                  backButtonCallback();
                  return;
               }
               CupGachaSlotUI(slots[selectIdx]).toEmpty();
               selectSlot(_loc1_);
            });
         });
      }
      
      private function triggeredPrizeList() : void
      {
         var _loc2_:int = UserDataWrapper.wrapper.getCupGachaIdAt(selectIdx);
         var _loc1_:CupGachaDef = GameSetting.getCupGacha(_loc2_);
         ItemsShowDialog.show4cupGacha(_loc1_.prizes,_loc1_.oddses,null,GameSetting.getUIText("cupgacha.desc.prizelist"),GameSetting.getUIText("cupgacha.title.prizelist"));
      }
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         super.advanceTime(param1);
         _loc3_ = 0;
         while(_loc3_ < slots.length)
         {
            _loc2_ = slots[_loc3_];
            if(_loc2_.advanceTime() && _loc3_ == selectIdx)
            {
               lblCookInfo.text#2 = restCookCompleteTextBase.replace("%1",_loc2_.getRestTimeString());
            }
            _loc3_++;
         }
         if(nextCheckSec >= 0 && nextCheckSec <= TimeZoneUtil.epochMillisToOffsetSecs())
         {
            selectSlot(selectIdx,true);
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CupGachaSlotDialog);
         setBackButtonCallback(backButtonCallback);
         if(Engine.getGuideTalkPanel() != null)
         {
            setVisibleState(4);
         }
         else
         {
            setVisibleState(94);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CupGachaSlotDialog);
            Engine.hideLoading(CupGachaSlotDialog);
            isGuide = processNoticeTutorial(27,noticeTutorialAction,getGuideArrowPos);
            if(isGuide)
            {
               setGuideUI(true);
            }
         });
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         var _loc2_:* = null;
         switch(int(param1))
         {
            case 0:
               _loc2_ = UserDataWrapper.wrapper;
               _loc2_.setCupGachaRestSec(0);
               selectSlot(selectIdx,true);
               break;
            case 1:
               setGuideUI(false);
               homeScene.noticeTutorialAction(0);
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         switch(int(param1))
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(btnCook);
            case 1:
               return GudetamaUtil.getCenterPosAndWHOnEngine(btnOpen);
            default:
               return null;
         }
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         var _loc1_:int = UserDataWrapper.wrapper.getPlacedGudetamaId();
         if(placeGudeId == _loc1_)
         {
            _backButtonCallback();
            return;
         }
         homeScene.waitChangeGudetama(_loc1_,_backButtonCallback);
      }
      
      private function _backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(CupGachaSlotDialog);
         setBackButtonCallback(null);
         if(beforeCloseFunc != null)
         {
            beforeCloseFunc();
         }
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CupGachaSlotDialog);
            Engine.popScene(scene);
            if(opened)
            {
               ResidentMenuUI_Gudetama.getInstance().checkClearedMission();
            }
         });
      }
      
      override public function dispose() : void
      {
         btnPrizeList.removeEventListener("triggered",triggeredPrizeList);
         btnPrizeList = null;
         btnCook.removeEventListener("triggered",triggeredCook);
         btnCook = null;
         btnEgg.removeEventListener("triggered",triggeredOpen);
         btnEgg = null;
         btnAd.removeEventListener("triggered",triggeredAd);
         btnAd = null;
         btnOpen.removeEventListener("triggered",triggeredOpen);
         btnOpen = null;
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.CupGachaDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class CupGachaSlotUI extends UIBase
{
    
   
   private var idx:int;
   
   public var id#2:int;
   
   private var callback:Function;
   
   private var button:SimpleImageButton;
   
   private var imgShadow:Image;
   
   private var imgEmpty:Image;
   
   private var imgSelect:Image;
   
   private var imgCooking:Image;
   
   private var matTime:Image;
   
   private var lblTime:ColorTextField;
   
   private var lastHour:int = -1;
   
   private var lastMin:int = -1;
   
   private var lastSec:int = -1;
   
   private var state:int = -1;
   
   function CupGachaSlotUI(param1:Sprite, param2:int, param3:int, param4:Function)
   {
      var sp:Sprite = param1;
      var idx:int = param2;
      var id:int = param3;
      var callback:Function = param4;
      super(sp);
      this.idx = idx;
      this.id#2 = id;
      this.callback = callback;
      button = sp.getChildByName("button") as SimpleImageButton;
      button.addEventListener("triggered",triggered);
      if(id > 0)
      {
         TextureCollector.loadTexture(GudetamaUtil.getItemIconName(19,id),function(param1:Texture):void
         {
            if(button)
            {
               button.texture = param1;
            }
         });
      }
      imgShadow = sp.getChildByName("imgShadow") as Image;
      imgEmpty = sp.getChildByName("imgEmpty") as Image;
      imgSelect = sp.getChildByName("imgSelect") as Image;
      imgCooking = sp.getChildByName("imgCooking") as Image;
      setSelect(false);
      matTime = sp.getChildByName("matTime") as Image;
      lblTime = sp.getChildByName("lblTime") as ColorTextField;
   }
   
   public function setup(param1:int = -1) : void
   {
      var _loc2_:* = null;
      if(id#2 == 0)
      {
         toEmpty();
         return;
      }
      imgEmpty.visible = false;
      var _loc3_:UserDataWrapper = UserDataWrapper.wrapper;
      if(idx != _loc3_.getCookIndex4CupGacha())
      {
         state = -1;
         imgCooking.visible = false;
         _loc2_ = GameSetting.getCupGacha(id#2);
         lblTime.text#2 = "";
         matTime.visible = false;
         return;
      }
      imgCooking.visible = true;
      matTime.visible = true;
      setTouchable(true);
      if(param1 == -1)
      {
         param1 = _loc3_.getRestSec4CupGacha();
      }
      if(param1 <= 0)
      {
         state = 2;
         lblTime.text#2 = GameSetting.getUIText("cupgacha.cook.complete");
      }
      else
      {
         state = 1;
      }
      advanceTime();
   }
   
   public function setSelect(param1:Boolean) : void
   {
      imgShadow.visible = param1;
      if(state == 1 || state == 2)
      {
         imgSelect.visible = false;
      }
      else
      {
         imgSelect.visible = param1;
      }
   }
   
   public function advanceTime() : Boolean
   {
      if(state != 1)
      {
         return false;
      }
      var _loc3_:int = Math.max(0,UserDataWrapper.wrapper.getRestSec4CupGacha());
      var _loc5_:int = 3600;
      var _loc1_:int = 60;
      var _loc2_:int = _loc3_ / _loc5_;
      var _loc6_:int = (_loc3_ - _loc2_ * _loc5_) / _loc1_;
      var _loc7_:int = _loc3_ - _loc2_ * _loc5_ - _loc6_ * _loc1_;
      var _loc4_:Boolean = false;
      if(_loc7_ != lastSec || _loc6_ != lastMin || _loc2_ != lastHour)
      {
         lblTime.text#2 = GudetamaUtil.getRestTimeString(_loc2_,_loc6_,_loc7_);
         lastHour = _loc2_;
         lastMin = _loc6_;
         lastSec = _loc7_;
         _loc4_ = true;
      }
      if(_loc3_ == 0)
      {
         setup(0);
         return false;
      }
      return _loc4_;
   }
   
   public function triggered() : void
   {
      callback(idx);
   }
   
   public function toEmpty() : void
   {
      id#2 = 0;
      setTouchable(false);
      imgEmpty.visible = true;
      imgSelect.visible = false;
      imgCooking.visible = false;
      matTime.visible = false;
      lblTime.text#2 = "";
      state = -1;
   }
   
   public function getRestTimeString() : String
   {
      return lblTime.text#2;
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggered);
      button = null;
   }
}

import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;

class RarityUI extends UIBase
{
    
   
   private const STAR_MAX:int = 5;
   
   private var stars:Array;
   
   private var starW:Number = 0;
   
   function RarityUI(param1:Sprite)
   {
      var _loc3_:int = 0;
      var _loc2_:* = null;
      stars = [];
      super(param1);
      _loc3_ = 0;
      while(_loc3_ < 5)
      {
         _loc2_ = param1.getChildByName("star" + _loc3_) as Image;
         if(starW == 0)
         {
            starW = _loc2_.texture.width;
         }
         stars.push(_loc2_);
         _loc3_++;
      }
   }
   
   public function updateRarity(param1:int) : void
   {
      var _loc5_:int = 0;
      var _loc3_:* = null;
      var _loc4_:int = param1 + 1;
      var _loc6_:int = 3;
      var _loc2_:Number = (displaySprite.width - starW * _loc4_ - _loc6_ * (_loc4_ - 1)) / 2;
      _loc5_ = 0;
      while(_loc5_ < stars.length)
      {
         _loc3_ = stars[_loc5_];
         if(_loc5_ > param1)
         {
            _loc3_.visible = false;
         }
         else
         {
            _loc3_.x = _loc2_;
            _loc3_.visible = true;
            _loc2_ += _loc6_ + starW;
         }
         _loc5_++;
      }
   }
}
