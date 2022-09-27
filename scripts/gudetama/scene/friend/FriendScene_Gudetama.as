package gudetama.scene.friend
{
   import feathers.data.ListCollection;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalUserBlockData;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.FriendlyData;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.FriendSortUtil;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class FriendScene_Gudetama extends BaseScene
   {
      
      public static const LIST_FRIEND:int = 0;
      
      public static const LIST_FOLLOW:int = 1;
      
      public static const LIST_RECOMMENDED:int = 2;
      
      public static const LIST_SEARCH:int = 3;
       
      
      private var friendLists:Vector.<FriendListBase>;
      
      private var toggleUIGroup:ToggleUIGroup;
      
      private var extensionButtonUI:ExtensionButtonUI;
      
      private var itemExtractor:SpriteExtractor;
      
      private var snsExtractor:SpriteExtractor;
      
      private var friendlyList:Array;
      
      private var collection:ListCollection;
      
      private var recommendedProfiles:Array;
      
      private var followerAssistableMap:Object;
      
      private var loadCount:int;
      
      private var numNewFriend:int;
      
      private var blockData:LocalUserBlockData;
      
      public function FriendScene_Gudetama()
      {
         friendLists = new Vector.<FriendListBase>();
         collection = new ListCollection();
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         addEventListener("update_scene",updateScene);
         blockData = DataStorage.loadUserBlockData();
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FriendLayout_Gudetama",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc4_:Sprite;
            var _loc3_:Sprite = (_loc4_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("listGroup") as Sprite;
            friendLists.push(new FriendListUI(_loc3_,0));
            var _loc2_:Sprite = _loc4_.getChildByName("applyGroup") as Sprite;
            friendLists.push(new FollowListUI(_loc2_,1,blockData));
            friendLists.push(new RecommendedListUI(_loc3_,2));
            var _loc5_:Sprite = _loc4_.getChildByName("searchGroup") as Sprite;
            friendLists.push(new SearchUI(_loc5_,3));
            toggleUIGroup = new ToggleUIGroup(_loc4_.getChildByName("tabGroup") as Sprite,triggeredToggleButtonCallback);
            extensionButtonUI = new ExtensionButtonUI(_loc4_.getChildByName("numFriendButton") as ContainerButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_FriendListItem_Gudetama",function(param1:Object):void
         {
            itemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_FriendSNSItem",function(param1:Object):void
         {
            snsExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(67109025,[!!UserDataWrapper.friendPart.isRequestedUpdateFollower() ? 1 : 0,!!UserDataWrapper.friendPart.isRequestedUpdateFollow() ? 1 : 0]),function(param1:Array):void
            {
               var response:Array = param1;
               recommendedProfiles = response[0];
               if(recommendedProfiles)
               {
                  if(recommendedProfiles.length > 0)
                  {
                     var i:int = 0;
                     while(i < blockData.profiles.length)
                     {
                        removeFromRecommendedProfiles(blockData.profiles[i]);
                        i++;
                     }
                  }
               }
               else
               {
                  recommendedProfiles = [];
               }
               if(response[1])
               {
                  UserDataWrapper.friendPart.setFollowerList(response[1]);
               }
               if(response[2])
               {
                  UserDataWrapper.friendPart.setFollowList(response[2]);
               }
               friendlyList = response[3];
               i = 0;
               while(i < friendlyList.length)
               {
                  var friendlyData:FriendlyData = friendlyList[i][0];
                  UserDataWrapper.wrapper.updateFriendlyData(friendlyData);
                  friendlyList[i].push(UserDataWrapper.friendPart.getFriendProfile(friendlyData.encodedUid));
                  i++;
               }
               followerAssistableMap = response[4];
               UserDataWrapper.wrapper.updateAllFriendPresentMoneyParam(response[5]);
               numNewFriend = UserDataWrapper.friendPart.getNumNewFriend();
               checkBlockUserReFollow(function():void
               {
                  taskDone();
               });
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
         for each(var _loc1_ in friendLists)
         {
            _loc1_.init(itemExtractor,snsExtractor,collection,scene);
         }
         extensionButtonUI.refresh();
         updateScene();
         Engine.lockTouchInput(FriendScene_Gudetama);
      }
      
      private function checkBlockUserReFollow(param1:Function) : void
      {
         var callback:Function = param1;
         var followers:Array = UserDataWrapper.friendPart.getFollowerList();
         if(followers.length == 0)
         {
            callback();
            return;
         }
         var blockUids:Array = [];
         var i:int = 0;
         while(i < followers.length)
         {
            var encodeUid:int = UserProfileData(followers[i]).encodedUid;
            if(blockData.containsBlock(encodeUid))
            {
               blockUids.push(encodeUid);
            }
            i++;
         }
         if(blockUids.length == 0)
         {
            callback();
            return;
         }
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(67109037,blockUids),function(param1:*):void
         {
            var _loc2_:int = 0;
            _loc2_ = 0;
            while(_loc2_ < blockUids.length)
            {
               UserDataWrapper.friendPart.removeFollowerByEncodeUid(blockUids[_loc2_]);
               _loc2_++;
            }
            callback();
         });
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         triggeredToggleButtonCallback(0);
         displaySprite.visible = true;
      }
      
      override protected function transitionOpenFinished() : void
      {
         Engine.unlockTouchInput(FriendScene_Gudetama);
         FriendlyRewardDialog.show(friendlyList,function():void
         {
            processNoticeTutorial(5,noticeTutorialAction,getGuideArrowPos);
         });
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               triggeredToggleButtonCallback(1);
               break;
            case 1:
               triggeredToggleButtonCallback(2);
               break;
            case 2:
               triggeredToggleButtonCallback(3);
               break;
            case 3:
               triggeredToggleButtonCallback(0);
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1) - 1)
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(toggleUIGroup.getButton(0));
            case 1:
               return GudetamaUtil.getCenterPosAndWHOnEngine(toggleUIGroup.getButton(1));
            case 2:
               return GudetamaUtil.getCenterPosAndWHOnEngine(toggleUIGroup.getButton(2));
            case 3:
               return GudetamaUtil.getCenterPosAndWHOnEngine(toggleUIGroup.getButton(3));
            case 4:
               return GudetamaUtil.getCenterPosAndWHOnEngine((friendLists[3] as SearchUI).getSnsButton());
            default:
               return _loc2_;
         }
      }
      
      private function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      private function triggeredToggleButtonCallback(param1:int, param2:int = -1) : void
      {
         SoundManager.playEffect("btn_normal");
         for each(var _loc3_ in friendLists)
         {
            _loc3_.setVisible(false);
         }
         friendLists[param1].setVisible(true);
         if(param1 == 2)
         {
            friendLists[param1].setup(recommendedProfiles,param2);
         }
         else
         {
            friendLists[param1].setup(null,param2,followerAssistableMap);
         }
      }
      
      public function processFriend(param1:int, param2:int) : void
      {
         var type:int = param1;
         var encodedUid:int = param2;
         if(!UserDataWrapper.friendPart.existsInFriend(encodedUid))
         {
            return;
         }
         var profile:UserProfileData = UserDataWrapper.friendPart.getFriendProfile(encodedUid);
         FriendDetailDialog.show({
            "profile":profile,
            "removeFunc":function():void
            {
               removeFollow(type,profile);
            }
         });
      }
      
      public function processFollow(param1:int, param2:UserProfileData) : void
      {
         var type:int = param1;
         var profile:UserProfileData = param2;
         if(!UserDataWrapper.friendPart.existsInFollow(profile.encodedUid))
         {
            return;
         }
         removeFollow(type,profile,function():void
         {
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("friend.message.follow.cancel.desc"),profile.playerName),null,GameSetting.getUIText("friend.message.follow.cancel.title"));
         },FollowListUI.SUB_TYPE_APPLY);
      }
      
      public function processApproveFollower(param1:int, param2:UserProfileData) : void
      {
         if(!UserDataWrapper.friendPart.existsInFollower(param2.encodedUid))
         {
            return;
         }
         requestFollow(param1,param2,true,null,1);
      }
      
      public function processRefuseFollower(param1:int, param2:UserProfileData) : void
      {
         var type:int = param1;
         var profile:UserProfileData = param2;
         if(!UserDataWrapper.friendPart.existsInFollower(profile.encodedUid))
         {
            return;
         }
         LocalMessageDialog.show(1,StringUtil.format(GameSetting.getUIText("friend.confirm.follower.refuse.desc"),profile.playerName),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            removeFollow(type,profile,null,1);
            blockUser(type,profile);
         },GameSetting.getUIText("friend.confirm.follower.refuse.title"));
      }
      
      public function processRecommended(param1:int, param2:UserProfileData, param3:Function = null) : void
      {
         requestFollow(param1,param2,false,param3);
      }
      
      private function requestFollow(param1:int, param2:UserProfileData, param3:Boolean = false, param4:Function = null, param5:int = -1) : void
      {
         var type:int = param1;
         var profile:UserProfileData = param2;
         var approve:Boolean = param3;
         var callback:Function = param4;
         var subType:int = param5;
         Engine.showLoading(FriendScene_Gudetama);
         var _loc6_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(162,profile.encodedUid),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(FriendScene_Gudetama);
            var result:int = response[0];
            if(result >= 0)
            {
               if(result == 0)
               {
                  profile.followRequestSecs = TimeZoneUtil.epochMillisToOffsetSecs();
                  profile.followState = 1;
                  UserDataWrapper.friendPart.addFollow(profile);
               }
               else
               {
                  profile.followState = 3;
                  UserDataWrapper.friendPart.addFriend(profile);
               }
               removeFromRecommendedProfiles(profile);
               triggeredToggleButtonCallback(type,subType);
               extensionButtonUI.refresh();
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText(result == 0 ? "friend.message.follow.apply.desc" : "friend.message.follower.approve.desc"),profile.playerName),function():void
               {
                  if(callback != null)
                  {
                     callback(result);
                  }
               },GameSetting.getUIText(!approve ? "friend.message.follow.apply.title" : "friend.message.follower.approve.title"));
            }
            else if(result == -2)
            {
               removeFromRecommendedProfiles(profile);
               triggeredToggleButtonCallback(type);
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("friend.warning." + Math.abs(result)),profile.playerName),function():void
               {
                  if(callback != null)
                  {
                     callback(result);
                  }
               });
            }
            else
            {
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("friend.warning." + Math.abs(result)),profile.playerName),function():void
               {
                  if(callback != null)
                  {
                     callback(result);
                  }
               });
            }
            updateScene();
         });
      }
      
      private function removeFromRecommendedProfiles(param1:UserProfileData) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < recommendedProfiles.length)
         {
            if(recommendedProfiles[_loc2_].encodedUid == param1.encodedUid)
            {
               recommendedProfiles.splice(_loc2_,1);
               return;
            }
            _loc2_++;
         }
      }
      
      private function existsInRecommendedProfiles(param1:UserProfileData) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < recommendedProfiles.length)
         {
            if(recommendedProfiles[_loc2_].encodedUid == param1.encodedUid)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function removeFollow(param1:int, param2:UserProfileData, param3:Function = null, param4:int = -1) : void
      {
         var type:int = param1;
         var profile:UserProfileData = param2;
         var callback:Function = param3;
         var subType:int = param4;
         Engine.showLoading(FriendScene_Gudetama);
         var _loc5_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(163,profile.encodedUid),function(param1:Array):void
         {
            Engine.hideLoading(FriendScene_Gudetama);
            var _loc2_:int = profile.followState;
            profile.followState = 0;
            UserDataWrapper.friendPart.removeFollow(profile);
            UserDataWrapper.friendPart.removeFollower(profile);
            UserDataWrapper.friendPart.removeFriend(profile);
            triggeredToggleButtonCallback(type,subType);
            extensionButtonUI.refresh();
            updateScene();
            if(callback)
            {
               callback();
            }
         });
      }
      
      public function blockUser(param1:int, param2:UserProfileData) : void
      {
         blockData.addBlock(param2);
         removeFromRecommendedProfiles(param2);
         if(param1 == 2)
         {
            triggeredToggleButtonCallback(param1);
         }
      }
      
      private function updateScene() : void
      {
         toggleUIGroup.update([numNewFriend,UserDataWrapper.friendPart.getNumFollowers(),0,0]);
         for each(var _loc1_ in friendLists)
         {
            _loc1_.update();
         }
         collection.updateAll();
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         for each(var _loc1_ in friendLists)
         {
            _loc1_.dispose();
         }
         friendLists.length = 0;
         friendLists = null;
         toggleUIGroup.dispose();
         toggleUIGroup = null;
         extensionButtonUI.dispose();
         extensionButtonUI = null;
         itemExtractor = null;
         snsExtractor = null;
         collection = null;
         blockData = null;
         FriendSortUtil.dispose();
         super.dispose();
      }
   }
}

import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.FlowLayout;
import gudetama.engine.BaseScene;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import muku.text.ColorTextField;
import starling.display.Sprite;

class FriendListBase extends UIBase
{
    
   
   protected var type:int;
   
   protected var list:List;
   
   protected var listEmptyText:ColorTextField;
   
   protected var collection:ListCollection;
   
   function FriendListBase(param1:Sprite, param2:int)
   {
      super(param1);
      this.type = param2;
      list = param1.getChildByName("list") as List;
      listEmptyText = param1.getChildByName("listEmptyText") as ColorTextField;
   }
   
   public function init(param1:SpriteExtractor, param2:SpriteExtractor, param3:ListCollection, param4:BaseScene) : void
   {
      var itemExtractor:SpriteExtractor = param1;
      var snsExtractor:SpriteExtractor = param2;
      var collection:ListCollection = param3;
      var scene:BaseScene = param4;
      this.collection = collection;
      var layout:FlowLayout = new FlowLayout();
      layout.horizontalAlign = "left";
      layout.horizontalGap = 10;
      layout.verticalGap = 10;
      layout.paddingTop = 5;
      layout.paddingLeft = 12;
      list.layout = layout;
      list.setItemRendererFactoryWithID("item",function():IListItemRenderer
      {
         return new FriendListItemRenderer(itemExtractor,scene);
      });
      list.setItemRendererFactoryWithID("sns",function():IListItemRenderer
      {
         return new SNSItemRenderer(snsExtractor,scene);
      });
      list.factoryIDFunction = function(param1:Object):String
      {
         return param1.key;
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
   }
   
   public function setup(param1:Array = null, param2:int = -1, param3:Object = null) : void
   {
      collection.removeAll();
      list.stopScrolling();
      list.scrollToPosition(0,0,0);
   }
   
   public function update() : void
   {
   }
   
   public function dispose() : void
   {
      list = null;
      collection = null;
   }
}

import feathers.data.ListCollection;
import gudetama.data.DataStorage;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.BaseScene;
import gudetama.scene.friend.FriendSortDialog;
import gudetama.util.FriendSortUtil;
import gudetama.util.SpriteExtractor;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class FriendListUI extends FriendListBase
{
    
   
   private var sortBtn:ContainerButton;
   
   private var sortText:ColorTextField;
   
   private var sources:Vector.<Object>;
   
   private var currentSortType:int = -1;
   
   function FriendListUI(param1:Sprite, param2:int)
   {
      super(param1,param2);
      sortBtn = param1.getChildByName("sortBtn") as ContainerButton;
      sortBtn.addEventListener("triggered",triggeredSortBtn);
      sortText = param1.getChildByName("sortText") as ColorTextField;
      sources = new Vector.<Object>();
   }
   
   override public function init(param1:SpriteExtractor, param2:SpriteExtractor, param3:ListCollection, param4:BaseScene) : void
   {
      super.init(param1,param2,param3,param4);
      param3.data#2 = sources;
   }
   
   override public function setup(param1:Array = null, param2:int = -1, param3:Object = null) : void
   {
      var _loc7_:int = 0;
      var _loc5_:* = null;
      var _loc6_:Boolean = false;
      super.setup(param1);
      var _loc8_:Array = UserDataWrapper.friendPart.getFriendList();
      _loc7_ = 0;
      while(_loc7_ < _loc8_.length)
      {
         _loc5_ = _loc8_[_loc7_];
         _loc6_ = !!param3 ? (!!param3[_loc5_.encodedUid] ? param3[_loc5_.encodedUid][0] : false) : false;
         sources.push({
            "key":"item",
            "type":type,
            "subType":0,
            "profile":_loc5_,
            "assistable":_loc6_
         });
         _loc7_++;
      }
      listEmptyText.visible = _loc8_.length <= 0;
      listEmptyText.text#2 = GameSetting.getUIText("%friend.listEmpty");
      var _loc4_:int = DataStorage.getLocalData().getFriendSortType();
      FriendSortUtil.processSort(sources,true,_loc4_);
      currentSortType = _loc4_;
      sortText.text#2 = GameSetting.getUIText("%friend.sort.type" + _loc4_);
      collection.updateAll();
   }
   
   private function triggeredSortBtn(param1:Event) : void
   {
      var event:Event = param1;
      FriendSortDialog.show(sources,currentSortType,function(param1:int):void
      {
         if(param1 != currentSortType)
         {
            DataStorage.getLocalData().setFriendSortType(param1);
         }
         currentSortType = param1;
         collection.updateAll();
         sortText.text#2 = GameSetting.getUIText("%friend.sort.type" + currentSortType);
      });
   }
   
   override public function dispose() : void
   {
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.LocalUserBlockData;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserProfileData;
import starling.display.Sprite;

class FollowListUI extends FriendListBase
{
   
   public static const SUB_TYPE_APPLY:int = 0;
   
   public static const SUB_TYPE_APPROVE:int = 1;
    
   
   private var pageGroup:PageGroup;
   
   private var currentType:int = -1;
   
   private var blockData:LocalUserBlockData;
   
   function FollowListUI(param1:Sprite, param2:int, param3:LocalUserBlockData)
   {
      super(param1,param2);
      this.blockData = param3;
      var _loc7_:TouchFieldUI = new TouchFieldUI(param1.getChildByName("applyTouchField") as Sprite,0,triggeredTouchFieldUI);
      var _loc4_:TouchFieldUI = new TouchFieldUI(param1.getChildByName("approveTouchField") as Sprite,1,triggeredTouchFieldUI);
      var _loc5_:Sprite = param1.getChildByName("applyGroup") as Sprite;
      var _loc6_:Sprite = param1.getChildByName("approveGroup") as Sprite;
      pageGroup = new PageGroup(new PageUI(_loc7_,_loc5_),new PageUI(_loc4_,_loc6_));
   }
   
   override public function setup(param1:Array = null, param2:int = -1, param3:Object = null) : void
   {
      super.setup(param1);
      currentType = -1;
      triggeredTouchFieldUI(param2 < 0 ? 0 : int(param2));
   }
   
   private function triggeredTouchFieldUI(param1:int) : void
   {
      if(param1 == currentType)
      {
         return;
      }
      currentType = param1;
      pageGroup.select = param1;
      updateList(param1);
   }
   
   private function updateList(param1:int) : void
   {
      var _loc4_:int = 0;
      collection.removeAll();
      list.stopScrolling();
      list.scrollToPosition(0,0,0);
      var _loc2_:* = param1 == 0;
      var _loc3_:Array = !!_loc2_ ? UserDataWrapper.friendPart.getFollowList() : UserDataWrapper.friendPart.getFollowerList();
      _loc4_ = 0;
      while(_loc4_ < _loc3_.length)
      {
         if(!(!_loc2_ && blockData.containsBlock(UserProfileData(_loc3_[_loc4_]).encodedUid)))
         {
            collection.addItem({
               "key":"item",
               "type":type,
               "subType":param1,
               "profile":_loc3_[_loc4_]
            });
         }
         _loc4_++;
      }
      listEmptyText.visible = _loc3_.length <= 0;
      if(param1 == 0)
      {
         listEmptyText.text#2 = GameSetting.getUIText("%friend.listEmpty.apply");
      }
      else
      {
         listEmptyText.text#2 = GameSetting.getUIText("%friend.listEmpty.approve");
      }
   }
   
   override public function update() : void
   {
      pageGroup.update([0,UserDataWrapper.friendPart.getNumFollowers()]);
   }
   
   override public function dispose() : void
   {
      pageGroup.dispose();
      super.dispose();
   }
}

class PageGroup
{
    
   
   private var pageUIs:Vector.<PageUI>;
   
   function PageGroup(... rest)
   {
      pageUIs = new Vector.<PageUI>();
      super();
      for each(var _loc2_ in rest)
      {
         pageUIs.push(_loc2_);
      }
   }
   
   public function setVisible(param1:int) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < pageUIs.length)
      {
         pageUIs[_loc2_].setVisible(_loc2_ == param1);
         _loc2_++;
      }
   }
   
   public function set select(param1:int) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < pageUIs.length)
      {
         pageUIs[_loc2_].select = _loc2_ == param1;
         _loc2_++;
      }
   }
   
   public function update(param1:Array) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < param1.length && _loc2_ < pageUIs.length)
      {
         pageUIs[_loc2_].update(param1[_loc2_]);
         _loc2_++;
      }
      while(_loc2_ < pageUIs.length)
      {
         pageUIs[_loc2_].update();
         _loc2_++;
      }
   }
   
   public function dispose() : void
   {
      for each(var _loc1_ in pageUIs)
      {
         _loc1_.dispose();
      }
      pageUIs.length = 0;
      pageUIs = null;
   }
}

import starling.display.Sprite;

class PageUI
{
    
   
   private var touchFieldUI:TouchFieldUI;
   
   private var background:Sprite;
   
   function PageUI(param1:TouchFieldUI, param2:Sprite)
   {
      super();
      this.touchFieldUI = param1;
      this.background = param2;
   }
   
   public function setVisible(param1:Boolean) : void
   {
      touchFieldUI.setVisible(param1);
      background.visible = param1;
   }
   
   public function set select(param1:Boolean) : void
   {
      touchFieldUI.select = param1;
      background.visible = param1;
   }
   
   public function update(param1:int = 0) : void
   {
      touchFieldUI.update(param1);
   }
   
   public function dispose() : void
   {
      touchFieldUI.dispose();
      touchFieldUI = null;
      background = null;
   }
}

import flash.geom.Point;
import gudetama.engine.SoundManager;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class TouchFieldUI extends UIBase
{
    
   
   private var index:int;
   
   private var callback:Function;
   
   private var quad:Quad;
   
   private var text:ColorTextField;
   
   private var noticeGroup:Sprite;
   
   private var numText:ColorTextField;
   
   private var localPoint:Point;
   
   function TouchFieldUI(param1:Sprite, param2:int, param3:Function)
   {
      localPoint = new Point();
      super(param1);
      this.index = param2;
      this.callback = param3;
      quad = param1.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouch);
      text = param1.getChildByName("text") as ColorTextField;
      noticeGroup = param1.getChildByName("noticeGroup") as Sprite;
      numText = noticeGroup.getChildByName("num") as ColorTextField;
   }
   
   public function set select(param1:Boolean) : void
   {
      text.color = !!param1 ? 5521974 : 16777215;
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
         SoundManager.playEffect("btn_normal");
         localPoint.setTo(_loc2_.globalX,_loc2_.globalY);
         displaySprite.globalToLocal(localPoint,localPoint);
         if(displaySprite.hitTest(localPoint))
         {
            callback(index);
         }
      }
   }
   
   public function update(param1:int) : void
   {
      noticeGroup.visible = param1 > 0;
      numText.text#2 = param1.toString();
   }
   
   public function dispose() : void
   {
      callback = null;
      if(quad)
      {
         quad.removeEventListener("touch",onTouch);
         quad = null;
      }
      text = null;
      noticeGroup = null;
      numText = null;
      localPoint = null;
   }
}

import gudetama.data.GameSetting;
import starling.display.Sprite;

class RecommendedListUI extends FriendListBase
{
    
   
   function RecommendedListUI(param1:Sprite, param2:int)
   {
      super(param1,param2);
   }
   
   override public function setup(param1:Array = null, param2:int = -1, param3:Object = null) : void
   {
      var _loc4_:int = 0;
      super.setup(param1);
      _loc4_ = 0;
      while(_loc4_ < param1.length)
      {
         collection.addItem({
            "key":"item",
            "type":type,
            "subType":0,
            "profile":param1[_loc4_]
         });
         _loc4_++;
      }
      listEmptyText.visible = param1.length <= 0;
      listEmptyText.text#2 = GameSetting.getUIText("%friend.listEmpty.recommend");
   }
   
   override public function dispose() : void
   {
      super.dispose();
   }
}

import feathers.controls.TextInput;
import feathers.controls.supportClasses.ListDataViewPort;
import feathers.core.ITextEditor;
import flash.desktop.Clipboard;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.Engine;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.ui.LocalMessageDialog;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import muku.text.CustomTextEditor;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;

class SearchUI extends FriendListBase
{
    
   
   private var idText:ColorTextField;
   
   private var copyToClipboardQuad:Quad;
   
   private var textInput:TextInput;
   
   private var explainText:ColorTextField;
   
   private var searchButton:ContainerButton;
   
   function SearchUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var type:int = param2;
      super(displaySprite,type);
      idText = displaySprite.getChildByName("id") as ColorTextField;
      copyToClipboardQuad = displaySprite.getChildByName("copyToClipboard") as Quad;
      copyToClipboardQuad.addEventListener("touch",onTouchCopyToClipboardQuad);
      textInput = displaySprite.getChildByName("textInput") as TextInput;
      textInput.maxChars = 15;
      textInput.backgroundSkin = null;
      textInput.textEditorFactory = function():ITextEditor
      {
         var _loc1_:CustomTextEditor = new CustomTextEditor();
         _loc1_.restrict = "0-9";
         return _loc1_;
      };
      textInput.validate();
      textInput.addEventListener("focusIn",focusIn);
      textInput.addEventListener("focusOut",focusOut);
      explainText = displaySprite.getChildByName("explain") as ColorTextField;
      searchButton = displaySprite.getChildByName("searchButton") as ContainerButton;
      searchButton.addEventListener("triggered",triggeredSearchButton);
   }
   
   override public function setup(param1:Array = null, param2:int = -1, param3:Object = null) : void
   {
      super.setup(param1);
      idText.text#2 = UserDataWrapper.wrapper.getFriendKey();
      textInput.text#2 = "";
      explainText.visible = true;
      collection.addItem({"key":"sns"});
      listEmptyText.text#2 = GameSetting.getUIText("%friend.listEmpty.search");
      listEmptyText.visible = true;
   }
   
   private function focusIn(param1:Event) : void
   {
      explainText.visible = false;
   }
   
   private function focusOut(param1:Event) : void
   {
      explainText.visible = textInput.text#2.length <= 0;
   }
   
   private function triggeredSearchButton(param1:Event) : void
   {
      var event:Event = param1;
      if(textInput.text#2.length <= 0)
      {
         return;
      }
      collection.removeAll();
      list.stopScrolling();
      list.scrollToPosition(0,0,0);
      collection.addItem({"key":"sns"});
      Engine.showLoading(FriendScene_Gudetama);
      var _loc2_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(67109028,textInput.text#2),function(param1:UserProfileData):void
      {
         Engine.hideLoading(FriendScene_Gudetama);
         if(!param1)
         {
            textInput.text#2 = "";
            explainText.visible = true;
            listEmptyText.visible = true;
            return;
         }
         collection.addItem({
            "key":"item",
            "type":type,
            "subType":0,
            "profile":param1
         });
         textInput.text#2 = "";
         explainText.visible = true;
         listEmptyText.visible = false;
      });
   }
   
   private function onTouchCopyToClipboardQuad(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(copyToClipboardQuad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         Clipboard.generalClipboard.setData("air:text",UserDataWrapper.wrapper.getFriendKey());
         LocalMessageDialog.show(0,GameSetting.getUIText("profile.message.clipboard.desc"),null,GameSetting.getUIText("profile.message.clipboard.title"));
      }
   }
   
   public function getSnsButton() : DisplayObject
   {
      var _loc2_:* = null;
      var _loc3_:int = 0;
      var _loc1_:ListDataViewPort = list.getChildAt(0) as ListDataViewPort;
      while(_loc3_ < _loc1_.numChildren)
      {
         _loc2_ = _loc1_.getChildAt(_loc3_) as SNSItemRenderer;
         if(_loc2_ != null)
         {
            return _loc2_.getButton();
         }
         _loc3_++;
      }
      return null;
   }
   
   override public function dispose() : void
   {
      idText = null;
      if(textInput)
      {
         textInput.removeEventListener("focusIn",focusIn);
         textInput.removeEventListener("focusOut",focusOut);
         textInput = null;
      }
      explainText = null;
      if(searchButton)
      {
         searchButton.removeEventListener("triggered",triggeredSearchButton);
         searchButton = null;
      }
      if(copyToClipboardQuad)
      {
         copyToClipboardQuad.removeEventListener("touch",onTouchCopyToClipboardQuad);
         copyToClipboardQuad = null;
      }
      super.dispose();
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class FriendListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var displaySprite:Sprite;
   
   private var friendListItemUI:FriendListItemUI;
   
   function FriendListItemRenderer(param1:SpriteExtractor, param2:BaseScene)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      friendListItemUI = new FriendListItemUI(displaySprite,scene);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      friendListItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      scene = null;
      displaySprite = null;
      friendListItemUI.dispose();
      friendListItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.FriendlyDef;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.scene.friend.FriendRoomScene;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.scene.friend.HeartGaugeGroup;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class FriendListItemUI extends UIBase
{
    
   
   private var scene:FriendScene_Gudetama;
   
   private var nameText:ColorTextField;
   
   private var roomButton:ContainerButton;
   
   private var iconImage:Image;
   
   private var imgSns:Image;
   
   private var iconGroup:Sprite;
   
   private var assistableImage:Image;
   
   private var tapImage:Image;
   
   private var levelText:ColorTextField;
   
   private var areaText:ColorTextField;
   
   private var heartGaugeGroup:HeartGaugeGroup;
   
   private var friendlyText:ColorTextField;
   
   private var commentText:ColorTextField;
   
   private var lastActiveText:ColorTextField;
   
   private var detailButton:ContainerButton;
   
   private var cancelButton:ContainerButton;
   
   private var approveButton:ContainerButton;
   
   private var refuseButton:ContainerButton;
   
   private var applyButton:ContainerButton;
   
   private var blockButton:ContainerButton;
   
   private var type:int;
   
   private var subType:int;
   
   private var profile:UserProfileData;
   
   function FriendListItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = param2 as FriendScene_Gudetama;
      nameText = param1.getChildByName("name") as ColorTextField;
      roomButton = param1.getChildByName("roomButton") as ContainerButton;
      roomButton.addEventListener("triggered",triggeredRoomButton);
      iconImage = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      iconGroup = param1.getChildByName("iconGroup") as Sprite;
      iconGroup.visible = false;
      assistableImage = iconGroup.getChildByName("assistableIcon") as Image;
      tapImage = iconGroup.getChildByName("tapIcon") as Image;
      levelText = param1.getChildByName("level") as ColorTextField;
      areaText = param1.getChildByName("area") as ColorTextField;
      heartGaugeGroup = new HeartGaugeGroup(param1.getChildByName("heartGroup") as Sprite);
      var _loc4_:FriendlyDef;
      var _loc3_:Array = (_loc4_ = GameSetting.getFriendly()).heartBorders;
      heartGaugeGroup.setup(_loc3_);
      friendlyText = param1.getChildByName("friendly") as ColorTextField;
      commentText = param1.getChildByName("comment") as ColorTextField;
      lastActiveText = param1.getChildByName("lastActiveText") as ColorTextField;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
      cancelButton = param1.getChildByName("cancelButton") as ContainerButton;
      cancelButton.addEventListener("triggered",triggeredCancelButton);
      approveButton = param1.getChildByName("approveButton") as ContainerButton;
      approveButton.addEventListener("triggered",triggeredApproveButton);
      refuseButton = param1.getChildByName("refuseButton") as ContainerButton;
      refuseButton.addEventListener("triggered",triggeredRefuseButton);
      applyButton = param1.getChildByName("applyButton") as ContainerButton;
      applyButton.addEventListener("triggered",triggeredApplyButton);
      blockButton = param1.getChildByName("blockButton") as ContainerButton;
      blockButton.addEventListener("triggered",triggeredBlockButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      type = data.type;
      subType = data.subType;
      profile = data.profile;
      var assistable:Boolean = data.assistable;
      var max:int = profile.playerRank * GameSetting.getRule().maxFriendPresentMoneyPerRank;
      var presentable:Boolean = profile.followState == 3 && UserDataWrapper.wrapper.isEnabledPresentMoneyToFriend(profile.encodedUid,max);
      nameText.text#2 = profile.playerName;
      iconImage.visible = false;
      imgSns.visible = false;
      if(profile.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         TextureCollector.loadSnsImage(profile.snsType,null,function(param1:Texture):void
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
         if(profile.avatar == 0)
         {
            profile.avatar = 1;
         }
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(profile.avatar).rsrc,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
      }
      levelText.text#2 = profile.playerRank.toString();
      if(Engine.getLocale() == "ja")
      {
         areaText.text#2 = GameSetting.getUIText("profile.area." + profile.area);
      }
      else
      {
         areaText.text#2 = GameSetting.getUIText("profile.area." + profile.area) + "\n" + GameSetting.getUIText("profile.area.gudetama." + profile.area);
      }
      if(profile.followState == 3)
      {
         heartGaugeGroup.setVisible(true);
         friendlyText.visible = true;
         var friendly:int = UserDataWrapper.wrapper.getFriendly(profile.encodedUid);
         var friendlyLevel:int = UserDataWrapper.wrapper.getFriendlyLevel(profile.encodedUid);
         var friendlyDef:FriendlyDef = GameSetting.getFriendly();
         var heartBorders:Array = friendlyDef.heartBorders;
         var maxHeartBorder:int = heartBorders[heartBorders.length - 1];
         heartGaugeGroup.value = friendly;
         heartGaugeGroup.skip();
         friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("friendDetail.friendly"),friendly,maxHeartBorder);
      }
      else
      {
         heartGaugeGroup.setVisible(false);
         friendlyText.visible = false;
      }
      commentText.text#2 = GameSetting.getComment(profile.getComment());
      lastActiveText.text#2 = StringUtil.format(GameSetting.getUIText("friend.lastLogin"),TimeZoneUtil.getDateYYmmDD(profile.lastActiveSec),TimeZoneUtil.getDateHHmm(profile.lastActiveSec));
      if(type == 3)
      {
         roomButton.visible = profile.followState == 3;
         detailButton.visible = profile.followState == 3;
         cancelButton.visible = profile.followState == 1;
         approveButton.visible = profile.followState == 2;
         refuseButton.visible = profile.followState == 2;
         applyButton.visible = profile.followState == 0;
         blockButton.visible = false;
      }
      else
      {
         roomButton.visible = type == 0;
         detailButton.visible = type == 0;
         cancelButton.visible = type == 1 && subType == 0;
         approveButton.visible = type == 1 && subType == 1;
         refuseButton.visible = type == 1 && subType == 1;
         applyButton.visible = type == 2;
         blockButton.visible = type == 2;
      }
      if(assistable && presentable)
      {
         iconGroup.visible = true;
         TweenAnimator.startItself(iconGroup,"switch");
         assistableImage.visible = true;
         tapImage.visible = true;
      }
      else if(assistable)
      {
         iconGroup.visible = true;
         TweenAnimator.startItself(iconGroup,"assist");
         assistableImage.visible = true;
         tapImage.visible = false;
      }
      else if(presentable)
      {
         iconGroup.visible = true;
         TweenAnimator.startItself(iconGroup,"tap");
         assistableImage.visible = false;
         tapImage.visible = true;
      }
      else
      {
         iconGroup.visible = false;
      }
      TweenAnimator.startItself(iconGroup,"show",true);
   }
   
   private function triggeredRoomButton(param1:Event) : void
   {
      Engine.switchScene(new FriendRoomScene(profile));
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      scene.processFriend(type,profile.encodedUid);
   }
   
   private function triggeredCancelButton(param1:Event) : void
   {
      scene.processFollow(type,profile);
   }
   
   private function triggeredApproveButton(param1:Event) : void
   {
      scene.processApproveFollower(type,profile);
   }
   
   private function triggeredRefuseButton(param1:Event) : void
   {
      scene.processRefuseFollower(type,profile);
   }
   
   private function triggeredApplyButton(param1:Event) : void
   {
      scene.processRecommended(type,profile);
   }
   
   private function triggeredBlockButton(param1:Event) : void
   {
      var event:Event = param1;
      LocalMessageDialog.show(1,GameSetting.getUIText("friend.confirm.block"),function(param1:int):void
      {
         if(param1 == 1)
         {
            return;
         }
         scene.blockUser(2,profile);
      });
   }
   
   public function dispose() : void
   {
      scene = null;
      nameText = null;
      if(roomButton)
      {
         roomButton.removeEventListener("triggered",triggeredRoomButton);
         roomButton = null;
      }
      levelText = null;
      areaText = null;
      if(heartGaugeGroup)
      {
         heartGaugeGroup.dispose();
         heartGaugeGroup = null;
      }
      friendlyText = null;
      commentText = null;
      if(detailButton)
      {
         detailButton.removeEventListener("triggered",triggeredDetailButton);
         detailButton = null;
      }
      if(cancelButton)
      {
         cancelButton.removeEventListener("triggered",triggeredCancelButton);
         cancelButton = null;
      }
      if(approveButton)
      {
         approveButton.removeEventListener("triggered",triggeredApproveButton);
         approveButton = null;
      }
      if(refuseButton)
      {
         refuseButton.removeEventListener("triggered",triggeredRefuseButton);
         refuseButton = null;
      }
      if(applyButton)
      {
         applyButton.removeEventListener("triggered",triggeredApplyButton);
         applyButton = null;
      }
      if(blockButton)
      {
         blockButton.removeEventListener("triggered",triggeredBlockButton);
         blockButton = null;
      }
      profile = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.DisplayObject;
import starling.display.Sprite;

class SNSItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var displaySprite:Sprite;
   
   private var snsItemUI:SNSItemUI;
   
   function SNSItemRenderer(param1:SpriteExtractor, param2:BaseScene)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      snsItemUI = new SNSItemUI(displaySprite,scene);
      addChild(displaySprite);
   }
   
   public function getButton() : DisplayObject
   {
      return displaySprite;
   }
   
   override public function dispose() : void
   {
      extractor = null;
      scene = null;
      displaySprite = null;
      snsItemUI.dispose();
      snsItemUI = null;
      super.dispose();
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.engine.BaseScene;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.scene.friend.SnsFriendListDialog;
import gudetama.scene.friend.SnsLinkBonusGuideDialog;
import gudetama.ui.UIBase;
import muku.display.SimpleImageButton;
import starling.display.Sprite;
import starling.events.Event;

class SNSItemUI extends UIBase
{
    
   
   private var button:SimpleImageButton;
   
   private var scene:FriendScene_Gudetama;
   
   function SNSItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = param2 as FriendScene_Gudetama;
      button = param1.getChildByName("button") as SimpleImageButton;
      button.addEventListener("triggered",triggered);
      if(UserDataWrapper.useSnsLinkBanner())
      {
         button.visible = true;
      }
      else
      {
         button.visible = false;
      }
   }
   
   private function triggered(param1:Event) : void
   {
      var event:Event = param1;
      if(UserDataWrapper.wrapper.isBitFlag(1))
      {
         SnsFriendListDialog.show(scene);
      }
      else
      {
         SnsLinkBonusGuideDialog.show(function():void
         {
            SnsFriendListDialog.show(scene);
         });
      }
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggered);
      button = null;
   }
}

import feathers.core.ToggleGroup;
import starling.display.DisplayObject;
import starling.display.Sprite;

class ToggleUIGroup
{
    
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleUI>;
   
   function ToggleUIGroup(param1:Sprite, param2:Function)
   {
      var _loc3_:int = 0;
      toggleUIList = new Vector.<ToggleUI>();
      super();
      this.callback = param2;
      toggleGroup = new ToggleGroup();
      _loc3_ = 0;
      while(_loc3_ < param1.numChildren)
      {
         toggleUIList.push(new ToggleUI(param1.getChildByName("btn_tab" + _loc3_) as Sprite,triggeredButtonCallback,_loc3_,toggleGroup));
         _loc3_++;
      }
   }
   
   private function triggeredButtonCallback(param1:int) : void
   {
      var _loc2_:int = 0;
      if(toggleGroup.selectedIndex == param1)
      {
         return;
      }
      toggleGroup.selectedIndex = param1;
      _loc2_ = 0;
      while(_loc2_ < toggleUIList.length)
      {
         toggleUIList[_loc2_].setSelect(_loc2_ == param1);
         _loc2_++;
      }
      if(callback)
      {
         callback(param1);
      }
   }
   
   public function getButton(param1:int) : DisplayObject
   {
      if(toggleUIList[param1] == null)
      {
         return null;
      }
      return toggleUIList[param1].getDisplaySprite();
   }
   
   public function update(param1:Array) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < param1.length && _loc2_ < toggleUIList.length)
      {
         toggleUIList[_loc2_].update(param1[_loc2_]);
         _loc2_++;
      }
      while(_loc2_ < toggleUIList.length)
      {
         toggleUIList[_loc2_].update();
         _loc2_++;
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      toggleGroup.removeAllItems();
      toggleGroup = null;
      for each(var _loc1_ in toggleUIList)
      {
         _loc1_.dispose();
      }
      toggleUIList.length = 0;
      toggleUIList = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.ui.UIBase;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class ToggleUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var index:int;
   
   private var button:ToggleButton;
   
   private var text:ColorTextField;
   
   private var noticeGroup:Sprite;
   
   private var numText:ColorTextField;
   
   function ToggleUI(param1:Sprite, param2:Function, param3:int, param4:ToggleGroup)
   {
      super(param1);
      this.callback = param2;
      this.index = param3;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      button.toggleGroup = param4;
      button.addEventListener("triggered",triggered);
      text = param1.getChildByName("text") as ColorTextField;
      noticeGroup = param1.getChildByName("noticeGroup") as Sprite;
      numText = noticeGroup.getChildByName("num") as ColorTextField;
   }
   
   public function setSelect(param1:Boolean) : void
   {
      text.color = !!param1 ? 5521974 : 16777215;
   }
   
   private function triggered(param1:Event) : void
   {
      if(callback)
      {
         callback(index);
      }
   }
   
   public function update(param1:int = 0) : void
   {
      noticeGroup.visible = param1 > 0;
      numText.text#2 = param1.toString();
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      text = null;
      noticeGroup = null;
      numText = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.scene.friend.MaxFriendsExtensionDialog;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class ExtensionButtonUI extends UIBase
{
    
   
   private var numText:ColorTextField;
   
   private var maxText:ColorTextField;
   
   function ExtensionButtonUI(param1:Sprite)
   {
      super(param1);
      param1.addEventListener("triggered",triggered);
      numText = param1.getChildByName("num") as ColorTextField;
      maxText = param1.getChildByName("max") as ColorTextField;
   }
   
   public function refresh() : void
   {
      numText.text#2 = UserDataWrapper.friendPart.getNumFriends().toString();
      maxText.text#2 = UserDataWrapper.friendPart.getMaxFriends().toString();
      (displaySprite as ContainerButton).enableDrawCache();
   }
   
   private function triggered(param1:Event) : void
   {
      if(UserDataWrapper.friendPart.isMaxFriendsExtensible())
      {
         MaxFriendsExtensionDialog.show(refresh);
      }
      else
      {
         LocalMessageDialog.show(0,GameSetting.getUIText("friend.isMaxExtension.desc"),null,GameSetting.getUIText("friend.isMaxExtension.title"));
      }
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggered);
   }
}
