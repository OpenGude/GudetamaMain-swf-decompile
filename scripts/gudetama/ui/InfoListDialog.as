package gudetama.ui
{
   import feathers.data.ListCollection;
   import gudetama.common.DialogSystemMailChecker;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.MailDataWrapper;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ConvertParam;
   import gudetama.data.compati.MailPresentResult;
   import gudetama.data.compati.SystemMailData;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import starling.display.Sprite;
   
   public class InfoListDialog extends BaseScene
   {
      
      public static const TYPE_INFORMATION:int = 0;
      
      public static const TYPE_PRESENT:int = 1;
       
      
      private var callback:Function;
      
      private var noticeIconId:int;
      
      private var infoLists:Vector.<InfoListBase>;
      
      private var extractor:SpriteExtractor;
      
      private var mailLists:Vector.<Vector.<SystemMailData>>;
      
      public var collection:ListCollection;
      
      private var loadCount:int;
      
      private var numUnreadInfo:int;
      
      private var numPresent:int;
      
      private var needCheckMission:Boolean = false;
      
      public function InfoListDialog(param1:Function, param2:int)
      {
         infoLists = new Vector.<InfoListBase>();
         mailLists = new Vector.<Vector.<SystemMailData>>();
         collection = new ListCollection();
         super(2);
         this.callback = param1;
         this.noticeIconId = param2;
         mailLists.push(new Vector.<SystemMailData>());
         mailLists.push(new Vector.<SystemMailData>());
      }
      
      public static function show(param1:Function, param2:int = 0) : void
      {
         Engine.pushScene(new InfoListDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"InfoListDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            infoLists.push(new InfoList(_loc2_,scene,0));
            infoLists.push(new PresentList(_loc2_,scene,1));
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_InfoItem",function(param1:Object):void
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
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(66),function(param1:Array):void
            {
               setupMails(param1);
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
         setup();
      }
      
      private function setup() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         _loc1_ = 0;
         while(_loc1_ < infoLists.length)
         {
            _loc2_ = infoLists[_loc1_];
            _loc2_.init(extractor,triggeredInfoItemUICallback);
            _loc2_.setup(mailLists[_loc1_]);
            _loc1_++;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(InfoListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         var navigatedMail:SystemMailData = getNavigatedMail();
         if(navigatedMail)
         {
            if(navigatedMail.type != 1)
            {
               showPresentList();
            }
            else
            {
               showInfoList();
            }
         }
         else if(numUnreadInfo <= 0 && numPresent > 0)
         {
            showPresentList();
         }
         else
         {
            showInfoList();
         }
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(InfoListDialog);
            var _loc1_:int = getIndexInList(navigatedMail);
            if(navigatedMail && _loc1_ >= 0)
            {
               if(navigatedMail.type != 1)
               {
                  processPresent(_loc1_,navigatedMail);
               }
               else
               {
                  processInformation(_loc1_,navigatedMail);
               }
            }
         });
      }
      
      private function getIndexInList(param1:SystemMailData) : int
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < collection.length)
         {
            if(collection.getItemAt(_loc2_).mail == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function getNavigatedMail() : SystemMailData
      {
         if(noticeIconId <= 0)
         {
            return null;
         }
         for each(var _loc1_ in mailLists[0])
         {
            if(_loc1_.noticeIconId == noticeIconId)
            {
               return _loc1_;
            }
         }
         for each(_loc1_ in mailLists[1])
         {
            if(_loc1_.noticeIconId == noticeIconId)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      private function setupMails(param1:Array) : void
      {
         var _loc5_:* = null;
         mailLists[0].length = 0;
         mailLists[1].length = 0;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         numUnreadInfo = 0;
         numPresent = 0;
         var _loc6_:Array = [];
         for each(var _loc4_ in param1)
         {
            if(_loc4_.type == 1)
            {
               mailLists[0].push(_loc4_);
               if(!_loc4_.alreadyRead)
               {
                  _loc3_++;
                  numUnreadInfo++;
               }
            }
            else
            {
               mailLists[1].push(_loc4_);
               _loc3_++;
               numPresent++;
               if(_loc4_.type == 2)
               {
                  _loc2_++;
               }
            }
            if(_loc4_.message && _loc4_.message.charAt(0) == "{")
            {
               _loc5_ = JSON.parse(_loc4_.message);
               _loc4_.title = _loc5_.title;
            }
            if(_loc4_.noticeIconId > 0 && _loc6_.indexOf(_loc4_.noticeIconId) < 0)
            {
               _loc6_.push(_loc4_.noticeIconId);
               _loc6_.sort(ascendingKeyComparator);
            }
         }
         UserDataWrapper.wrapper.setNumUnreadInfoAndPresents(_loc3_);
         UserDataWrapper.wrapper.setNumFriendPresents(_loc2_);
         UserDataWrapper.wrapper.updateMailNoticeIconIds(_loc6_);
         Engine.broadcastEventToSceneStackWith("update_scene");
      }
      
      private function ascendingKeyComparator(param1:int, param2:int) : Number
      {
         if(param1 > param2)
         {
            return 1;
         }
         if(param1 < param2)
         {
            return -1;
         }
         return 0;
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(InfoListDialog);
         setBackButtonCallback(null);
         Engine.broadcastEventToSceneStackWith("update_scene");
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(InfoListDialog);
            Engine.popScene(scene);
            if(needCheckMission)
            {
               ResidentMenuUI_Gudetama.getInstance().checkClearedMission(callback);
            }
            else if(callback)
            {
               callback();
            }
         });
      }
      
      public function showInfoList() : void
      {
         infoLists[1].setVisible(false);
         infoLists[0].setVisible(true);
         refreshList();
      }
      
      public function showPresentList() : void
      {
         infoLists[0].setVisible(false);
         infoLists[1].setVisible(true);
         refreshList();
      }
      
      private function triggeredInfoItemUICallback(param1:int, param2:int, param3:SystemMailData) : void
      {
         if(param1 == 0)
         {
            processInformation(param2,param3);
         }
         else
         {
            processPresent(param2,param3);
         }
      }
      
      private function processInformation(param1:int, param2:SystemMailData) : void
      {
         var index:int = param1;
         var mail:SystemMailData = param2;
         if(!mail.alreadyRead)
         {
            Engine.showLoading(InfoListDialog);
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(160,mail.uniqueKey),function(param1:MailPresentResult):void
            {
               var response:MailPresentResult = param1;
               Engine.hideLoading(InfoListDialog);
               UserDataWrapper.wrapper.addItems(response.items,response.params#2);
               showInfoDialog(mail,function():void
               {
                  mail.alreadyRead = true;
                  if(infoLists)
                  {
                     infoLists[0].update(index);
                  }
                  if(mail.item)
                  {
                     MailPresentDialog.show(mail,function():void
                     {
                        procGetDialogAfter();
                     });
                  }
                  UserDataWrapper.wrapper.addNumUnreadInfoAndPresents(-1);
                  Engine.broadcastEventToSceneStackWith("update_scene");
               });
            });
         }
         else
         {
            showInfoDialog(mail);
         }
      }
      
      private function procGetDialogAfter() : void
      {
         ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
         var _loc1_:UserDataWrapper = UserDataWrapper.wrapper;
         if(_loc1_.hasCupGachaResult())
         {
            needCheckMission = true;
            _loc1_.showCupGachaResults(_loc1_.getPlacedGudetamaId(),null);
         }
      }
      
      private function showInfoDialog(param1:SystemMailData, param2:Function = null) : void
      {
         var mail:SystemMailData = param1;
         var callback:Function = param2;
         DialogSystemMailChecker.processDialogMail(mail,function(param1:Function):void
         {
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function processPresent(param1:int, param2:SystemMailData) : void
      {
         var index:int = param1;
         var mail:SystemMailData = param2;
         var type:int = !!mail.manualDeletion ? 14 : 0;
         var message:String = !!mail.manualDeletion ? GameSetting.getUIText("warning.item.upperLimit.del") : GameSetting.getUIText("warning.item.upperLimit").replace("%1",GudetamaUtil.getItemParamName(mail.item));
         if(!UserDataWrapper.wrapper.isItemAddable(mail.item))
         {
            LocalMessageDialog.show(type,message,function(param1:int):void
            {
               var choose1:int = param1;
               if(mail.manualDeletion && choose1 == 0)
               {
                  LocalMessageDialog.show(1,GameSetting.getUIText("warning.item.upperLimit.del.check"),function(param1:int):void
                  {
                     var choose:int = param1;
                     if(choose == 0)
                     {
                        var _loc2_:* = HttpConnector;
                        if(gudetama.net.HttpConnector.mainConnector == null)
                        {
                           gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                        }
                        gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(16777465,mail.uniqueKey),function(param1:Array):void
                        {
                           var _loc2_:int = param1[0] as int;
                           if(_loc2_ == 1)
                           {
                              if(infoLists)
                              {
                                 infoLists[1].remove(index);
                              }
                              mailLists[1].removeAt(mailLists[1].indexOf(mail));
                           }
                        });
                     }
                  });
               }
            });
            return;
         }
         Engine.showLoading(InfoListDialog);
         var _loc4_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(72,mail.uniqueKey),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(InfoListDialog);
            var result:MailPresentResult = response[0];
            var profile:UserProfileData = response[1];
            UserDataWrapper.wrapper.addItems(result.items,result.params#2);
            if(infoLists)
            {
               infoLists[1].remove(index);
            }
            mailLists[1].removeAt(mailLists[1].indexOf(mail));
            if(mail.type == 2)
            {
               FriendPresentDialog.show(mail,profile,function():void
               {
                  ConvertDialog.show(result.items,result.params#2,function():void
                  {
                     procGetDialogAfter();
                  });
               });
            }
            else
            {
               MailPresentDialog.show(mail,function():void
               {
                  ConvertDialog.show(result.items,result.params#2,function():void
                  {
                     procGetDialogAfter();
                  });
               });
            }
            UserDataWrapper.wrapper.addNumUnreadInfoAndPresents(-1);
            if(mail.type == 2)
            {
               UserDataWrapper.wrapper.addNumFriendPresents(-1);
            }
            var mailNoticeIconIds:Array = [];
            for each(_mail in mailLists[0])
            {
               if(_mail.noticeIconId > 0 && mailNoticeIconIds.indexOf(_mail.noticeIconId) < 0)
               {
                  mailNoticeIconIds.push(_mail.noticeIconId);
                  mailNoticeIconIds.sort(ascendingKeyComparator);
               }
            }
            for each(_mail in mailLists[1])
            {
               if(_mail.noticeIconId > 0 && mailNoticeIconIds.indexOf(_mail.noticeIconId) < 0)
               {
                  mailNoticeIconIds.push(_mail.noticeIconId);
                  mailNoticeIconIds.sort(ascendingKeyComparator);
               }
            }
            UserDataWrapper.wrapper.updateMailNoticeIconIds(mailNoticeIconIds);
            Engine.broadcastEventToSceneStackWith("update_scene");
         });
      }
      
      private function existsAddablePresent() : Boolean
      {
         for each(var _loc1_ in mailLists[1])
         {
            if(UserDataWrapper.wrapper.isItemAddable(_loc1_.item))
            {
               return true;
            }
         }
         return false;
      }
      
      public function triggeredBulkButtonCallback() : void
      {
         if(!existsAddablePresent())
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("infoList.bulk.none.desc"),null,GameSetting.getUIText("infoList.bulk.title"));
            return;
         }
         Engine.showLoading(InfoListDialog);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(73),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(InfoListDialog);
            var availableMails:Array = response[0];
            var receivedMails:Array = response[1];
            var result:MailPresentResult = response[2];
            UserDataWrapper.wrapper.addItems(result.items,result.params#2);
            setupMails(availableMails);
            if(infoLists)
            {
               var i:int = 0;
               while(i < infoLists.length)
               {
                  var infoList:InfoListBase = infoLists[i];
                  infoList.setup(mailLists[i]);
                  i++;
               }
            }
            refreshList();
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            Engine.broadcastEventToSceneStackWith("update_scene");
            var mailDataList:MailDataWrapper = new MailDataWrapper();
            for(index in result.items)
            {
               if(result.params#2[index] is ConvertParam)
               {
                  mailDataList.addItemParam(result.params#2[index]);
               }
               else
               {
                  mailDataList.addItemParam(result.items[index]);
               }
            }
            var margedList:Array = mailDataList.getItemList();
            PresentAllResultDialog.show(margedList,function():void
            {
               ConvertDialog.show(result.items,margedList,function():void
               {
                  procGetDialogAfter();
               });
            });
         });
      }
      
      public function triggeredUpdateButtonCallback() : void
      {
         Engine.showLoading(InfoListDialog);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(66),function(param1:Array):void
         {
            var _loc2_:int = 0;
            var _loc3_:* = null;
            Engine.hideLoading(InfoListDialog);
            setupMails(param1);
            if(infoLists)
            {
               _loc2_ = 0;
               while(_loc2_ < infoLists.length)
               {
                  _loc3_ = infoLists[_loc2_];
                  _loc3_.setup(mailLists[_loc2_]);
                  _loc2_++;
               }
            }
            refreshList();
         });
      }
      
      private function refreshList() : void
      {
         var _loc1_:int = 0;
         if(infoLists)
         {
            _loc1_ = 0;
            while(_loc1_ < infoLists.length)
            {
               if(infoLists[_loc1_].isVisible())
               {
                  infoLists[_loc1_].refresh();
               }
               _loc1_++;
            }
         }
      }
      
      override public function dispose() : void
      {
         for each(var _loc1_ in infoLists)
         {
            _loc1_.dispose();
         }
         infoLists.length = 0;
         infoLists = null;
         extractor = null;
         for each(var _loc2_ in mailLists)
         {
            _loc2_.length = 0;
         }
         mailLists.length = 0;
         mailLists = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.FlowLayout;
import flash.geom.Point;
import gudetama.data.compati.SystemMailData;
import gudetama.engine.BaseScene;
import gudetama.ui.InfoListDialog;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class InfoListBase extends UIBase
{
    
   
   protected var scene:InfoListDialog;
   
   private var type:int;
   
   protected var tabGroup:Sprite;
   
   private var updateButton:ContainerButton;
   
   private var list:List;
   
   protected var listEmptyText:ColorTextField;
   
   private var closeButton:ContainerButton;
   
   protected var mailList:Vector.<SystemMailData>;
   
   protected var localPoint:Point;
   
   function InfoListBase(param1:Sprite, param2:BaseScene, param3:int)
   {
      localPoint = new Point();
      super(param1);
      this.scene = InfoListDialog(param2);
      this.type = param3;
      tabGroup = param1.getChildByName("tabGroup") as Sprite;
      updateButton = param1.getChildByName("updateButton") as ContainerButton;
      updateButton.addEventListener("triggered",triggeredUpdateButton);
      list = param1.getChildByName("list") as List;
      listEmptyText = param1.getChildByName("listEmptyText") as ColorTextField;
      closeButton = param1.getChildByName("btn_back") as ContainerButton;
      closeButton.addEventListener("triggered",triggeredCloseButton);
   }
   
   public function init(param1:SpriteExtractor, param2:Function) : void
   {
      var extractor:SpriteExtractor = param1;
      var callback:Function = param2;
      var layout:FlowLayout = new FlowLayout();
      layout.horizontalAlign = "left";
      layout.horizontalGap = 10;
      layout.verticalGap = 10;
      layout.paddingTop = 5;
      layout.paddingLeft = 4;
      list.layout = layout;
      list.itemRendererFactory = function():IListItemRenderer
      {
         return new InfoListItemRenderer(extractor,callback);
      };
      list.selectedIndex = -1;
      list.dataProvider = scene.collection;
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
   }
   
   public function setup(param1:Vector.<SystemMailData>) : void
   {
      this.mailList = param1;
   }
   
   public function refresh() : void
   {
      var _loc1_:int = 0;
      scene.collection.removeAll();
      list.stopScrolling();
      list.scrollToPosition(0,0,0);
      _loc1_ = mailList.length - 1;
      while(_loc1_ >= 0)
      {
         scene.collection.addItem({
            "type":type,
            "mail":mailList[_loc1_]
         });
         _loc1_--;
      }
      listEmptyText.visible = mailList.length <= 0;
   }
   
   public function update(param1:int) : void
   {
      scene.collection.updateItemAt(param1);
   }
   
   public function remove(param1:int) : void
   {
      scene.collection.removeItemAt(param1);
      scene.collection.updateAll();
   }
   
   private function triggeredUpdateButton(param1:Event) : void
   {
      if(!isVisible())
      {
         return;
      }
      scene.triggeredUpdateButtonCallback();
   }
   
   private function triggeredCloseButton(param1:Event) : void
   {
      if(!isVisible())
      {
         return;
      }
      scene.backButtonCallback();
   }
   
   public function dispose() : void
   {
      scene = null;
      tabGroup = null;
      updateButton.removeEventListener("triggered",triggeredUpdateButton);
      updateButton = null;
      list = null;
      closeButton.removeEventListener("triggered",triggeredCloseButton);
      closeButton = null;
      mailList = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.engine.BaseScene;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class InfoList extends InfoListBase
{
    
   
   private var infoGroup:Sprite;
   
   private var quad:Quad;
   
   function InfoList(param1:Sprite, param2:BaseScene, param3:int)
   {
      super(param1,param2,param3);
      infoGroup = tabGroup.getChildByName("infoGroup") as Sprite;
      quad = infoGroup.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouch);
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         localPoint.setTo(_loc2_.globalX,_loc2_.globalY);
         displaySprite.globalToLocal(localPoint,localPoint);
         if(displaySprite.hitTest(localPoint))
         {
            scene.showInfoList();
         }
      }
   }
   
   override public function refresh() : void
   {
      super.refresh();
      listEmptyText.text#2 = GameSetting.getUIText("infoList.listEmpty.info");
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      if(param1)
      {
         quad.visible = false;
      }
      else
      {
         tabGroup.setChildIndex(infoGroup,0);
         quad.visible = true;
      }
   }
   
   override public function isVisible() : Boolean
   {
      return !quad.visible;
   }
   
   override public function dispose() : void
   {
      infoGroup = null;
      quad.removeEventListener("touch",onTouch);
      quad = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.engine.BaseScene;
import muku.display.ContainerButton;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;

class PresentList extends InfoListBase
{
    
   
   private var presentGroup:Sprite;
   
   private var quad:Quad;
   
   private var bulkButton:ContainerButton;
   
   function PresentList(param1:Sprite, param2:BaseScene, param3:int)
   {
      super(param1,param2,param3);
      presentGroup = tabGroup.getChildByName("presentGroup") as Sprite;
      quad = presentGroup.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouch);
      bulkButton = param1.getChildByName("bulkButton") as ContainerButton;
      bulkButton.addEventListener("triggered",triggeredBulkButton);
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         localPoint.setTo(_loc2_.globalX,_loc2_.globalY);
         displaySprite.globalToLocal(localPoint,localPoint);
         if(displaySprite.hitTest(localPoint))
         {
            scene.showPresentList();
         }
      }
   }
   
   override public function refresh() : void
   {
      super.refresh();
      listEmptyText.text#2 = GameSetting.getUIText("infoList.listEmpty.present");
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      if(param1)
      {
         quad.visible = false;
         bulkButton.visible = true;
      }
      else
      {
         tabGroup.setChildIndex(presentGroup,0);
         quad.visible = true;
         bulkButton.visible = false;
      }
   }
   
   override public function isVisible() : Boolean
   {
      return !quad.visible;
   }
   
   private function triggeredBulkButton(param1:Event) : void
   {
      scene.triggeredBulkButtonCallback();
   }
   
   override public function dispose() : void
   {
      presentGroup = null;
      quad.removeEventListener("touch",onTouch);
      quad = null;
      bulkButton.removeEventListener("triggered",triggeredBulkButton);
      bulkButton = null;
      super.dispose();
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class InfoListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var infoItemUI:InfoItemUI;
   
   function InfoListItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      infoItemUI = new InfoItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      infoItemUI.updateData(index,data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      infoItemUI.dispose();
      infoItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.SystemMailData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class InfoItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var typeText:ColorTextField;
   
   private var dateText:ColorTextField;
   
   private var titleText:ColorTextField;
   
   private var titleWithPresentText:ColorTextField;
   
   private var rewardSprite:Sprite;
   
   private var icon:Image;
   
   private var acquiredSprite:Sprite;
   
   private var newImage:Image;
   
   private var index:int;
   
   private var type:int;
   
   private var mail:SystemMailData;
   
   function InfoItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      typeText = button.getChildByName("type") as ColorTextField;
      dateText = button.getChildByName("date") as ColorTextField;
      titleText = button.getChildByName("title") as ColorTextField;
      titleWithPresentText = button.getChildByName("titleWithPresent") as ColorTextField;
      rewardSprite = button.getChildByName("reward") as Sprite;
      icon = rewardSprite.getChildByName("icon") as Image;
      acquiredSprite = rewardSprite.getChildByName("acquired") as Sprite;
      var _loc3_:Image = acquiredSprite.getChildByName("present0@present") as Image;
      var _loc4_:Image;
      (_loc4_ = acquiredSprite.getChildByName("shop0@finish") as Image).x = (_loc3_.width - _loc4_.width) / 2;
      newImage = button.getChildByName("new") as Image;
   }
   
   public function updateData(param1:int, param2:Object) : void
   {
      if(!param2)
      {
         return;
      }
      this.index = param1;
      type = param2.type;
      mail = param2.mail;
      if(type == 0)
      {
         setupInfo();
      }
      else
      {
         setupPresent();
      }
   }
   
   private function setupInfo() : void
   {
      var _loc2_:int = mail.receivedSecs;
      var _loc1_:Date = new Date();
      _loc1_.setTime(TimeZoneUtil.offsetSecsToEpochMillis(_loc2_));
      typeText.text#2 = GameSetting.getUIText("mail.kind." + mail.kind);
      typeText.visible = true;
      dateText.text#2 = StringUtil.format(GameSetting.getUIText("infoList.info.date"),_loc1_.getFullYear(),_loc1_.getMonth() + 1,_loc1_.getDate());
      if(mail.item)
      {
         titleText.visible = false;
         titleWithPresentText.visible = true;
         titleWithPresentText.text#2 = StringUtil.branchTextOnCondition(mail.title && mail.title.length > 0,mail.title,GudetamaUtil.getSystemMailMessage(mail));
         rewardSprite.visible = true;
      }
      else
      {
         titleText.visible = true;
         titleText.text#2 = StringUtil.branchTextOnCondition(mail.title && mail.title.length > 0,mail.title,GudetamaUtil.getSystemMailMessage(mail));
         titleWithPresentText.visible = false;
         rewardSprite.visible = false;
      }
      acquiredSprite.visible = mail.alreadyRead;
      newImage.visible = !mail.alreadyRead;
   }
   
   private function setupPresent() : void
   {
      typeText.visible = false;
      titleText.visible = false;
      titleWithPresentText.visible = true;
      titleWithPresentText.text#2 = StringUtil.branchTextOnCondition(mail.title && mail.title.length > 0,mail.title,GudetamaUtil.getSystemMailMessage(mail));
      if(mail.item && GameSetting.hasScreeningFlag(8) && !mail.item.hasNumber())
      {
         dateText.text#2 = GameSetting.getUIText("infoList.present.date.none");
      }
      else if(mail.deleteSec == -1)
      {
         dateText.text#2 = GameSetting.getUIText("infoList.present.date.none");
      }
      else if(mail.deleteSec != 0)
      {
         var restSec:int = Math.max(0,mail.deleteSec - TimeZoneUtil.epochMillisToOffsetSecs());
         dateText.text#2 = StringUtil.format(GameSetting.getUIText("infoList.present.limit"),TimeZoneUtil.getRestTimeText(restSec));
      }
      else
      {
         var date:Date = new Date();
         var limitSecs:int = mail.receivedSecs + 2592000;
         date.setTime(TimeZoneUtil.offsetSecsToEpochMillis(limitSecs));
         dateText.text#2 = StringUtil.format(GameSetting.getUIText("infoList.present.date"),date.getFullYear(),date.getMonth() + 1,date.getDate());
      }
      var iconName:String = GudetamaUtil.getItemIconName(mail.item.kind,mail.item.id#2);
      TextureCollector.loadTexture(iconName,function(param1:Texture):void
      {
         if(icon != null)
         {
            icon.texture = param1;
         }
      });
      rewardSprite.visible = true;
      acquiredSprite.visible = false;
      newImage.visible = false;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(type,index,mail);
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      typeText = null;
      dateText = null;
      titleText = null;
      titleWithPresentText = null;
      rewardSprite = null;
      acquiredSprite = null;
      newImage = null;
      mail = null;
   }
}
