package gudetama.scene.collection
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.VoiceManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.MissionData;
   import gudetama.data.compati.VoiceDef;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.PageManager;
   import gudetama.ui.PageManagerListener;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class PicturebookCollectionPanel extends Sprite implements PageManagerListener
   {
      
      public static const TYPE_PANEL_GUDETAMA:int = 0;
      
      public static const TYPE_PANEL_VOICE:int = 1;
      
      private static const TUTORIAL_GUDETAMA_ID:int = 6;
      
      private static const FILTER_TYPE1_ALL:int = 0;
      
      private static const FILTER_TYPE1_NORMAL:int = 1;
      
      private static const FILTER_TYPE1_EVENT:int = 2;
      
      public static const FILTER_TYPE2_VOICE_COMP_NONE:int = 0;
      
      public static const FILTER_TYPE2_VOICE_COMP_FIRST:int = 1;
      
      public static const FILTER_TYPE2_VOICE_COMP_SECOND:int = 2;
      
      public static const FILTER_TYPE2_VOICE_COMP_ALL:int = 3;
      
      public static const SORT_GUDETAMA_TYPE_NO:int = 0;
      
      public static const SORT_GUDETAMA_TYPE_CATEGORY:int = 1;
      
      public static const SORT_GUDETAMA_TYPE_COST:int = 2;
      
      public static const SORT_VOICE_TYPE_NO:int = 0;
      
      public static const SORT_VOICE_TYPE_COST:int = 1;
       
      
      private var queue:TaskQueue;
      
      private var paneltype:int;
      
      private var picturebookSprite:Sprite;
      
      private var list:List;
      
      private var achieveGroup:Sprite;
      
      private var achieveText:ColorTextField;
      
      private var maxAchieveText:ColorTextField;
      
      private var gudetamaIconExtractor:SpriteExtractor;
      
      private var gudetamaLabelExtractor:SpriteExtractor;
      
      private var pageButtonExtractor:SpriteExtractor;
      
      private var collections:Array;
      
      private var gudetamas:Vector.<GudetamaDef>;
      
      private var eventGudetamas:Vector.<GudetamaDef>;
      
      private var showableGudetamas:Vector.<GudetamaDef>;
      
      private var sortIndex:int = -1;
      
      private var triggerCount:int = -1;
      
      private var loadCount:int;
      
      private var pageManger:PageManager;
      
      private const numPerPage:int = 100;
      
      private var voiceManager:VoiceManager;
      
      private var filterBtn:ContainerButton;
      
      private var nextRewardButton:ContainerButton;
      
      private var nextRewardIcon:Image;
      
      private var finishSprite:Sprite;
      
      private var toggleUIGroup:ToggleUIGroup;
      
      private var currentFilter1Index:int = 1;
      
      private var currentFilter2Index:int = 0;
      
      private var sortAscending:Boolean = false;
      
      private var currentSortIndex:int = 0;
      
      private var homeGudetamaToTop:Boolean = true;
      
      private var comparator:Function;
      
      private var homeGudetamaDef:GudetamaDef;
      
      private var showableIndex:int = 0;
      
      private var topItem:Object;
      
      private var labelTitleText:ColorTextField;
      
      private var missionType:int = 1;
      
      private var comparatorGudetamaPairs:Array;
      
      private var comparatorVoicePairs:Array;
      
      private var currentCategory:int = -1;
      
      public function PicturebookCollectionPanel(param1:int)
      {
         collections = [];
         gudetamas = new Vector.<GudetamaDef>();
         eventGudetamas = new Vector.<GudetamaDef>();
         showableGudetamas = new Vector.<GudetamaDef>();
         voiceManager = new VoiceManager();
         homeGudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         comparatorGudetamaPairs = [[ascendingNumberComparator,descendingNumberComparator],[ascendingCategoryComparator,descendingCategoryComparator],[ascendingCostComparator,descendingCostComparator]];
         comparatorVoicePairs = [[ascendingNumberComparator,descendingNumberComparator],[ascendingCostComparator,descendingCostComparator]];
         super();
         paneltype = param1;
         if(paneltype == 0)
         {
            homeGudetamaToTop = false;
         }
      }
      
      public function setupProgress(param1:TaskQueue, param2:Sprite, param3:Function) : void
      {
         var _queue:TaskQueue = param1;
         var _picturebookVoiceSprite:Sprite = param2;
         var _setupLayoutForTask:Function = param3;
         queue = _queue;
         picturebookSprite = _picturebookVoiceSprite;
         list = picturebookSprite.getChildByName("list") as List;
         achieveGroup = picturebookSprite.getChildByName("achieveGroup") as Sprite;
         var collectionNumSprite:Sprite = achieveGroup.getChildByName("collectionNumSprite") as Sprite;
         achieveText = collectionNumSprite.getChildByName("achieve") as ColorTextField;
         maxAchieveText = collectionNumSprite.getChildByName("maxAchieve") as ColorTextField;
         var collectionPanelBaseLayout:Sprite = picturebookSprite.getChildByName("collectionPanelBaseLayout") as Sprite;
         var base:Sprite = collectionPanelBaseLayout.getChildByName("baseSprite") as Sprite;
         var labelSprite:Sprite = base.getChildByName("Label") as Sprite;
         labelTitleText = labelSprite.getChildByName("title") as ColorTextField;
         toggleUIGroup = new ToggleUIGroup(base.getChildByName("tabGroup") as Sprite,triggeredToggleButtonCallback);
         filterBtn = base.getChildByName("filterBtn") as ContainerButton;
         filterBtn.addEventListener("triggered",triggeredSortBtn);
         nextRewardButton = base.getChildByName("btnNextReward") as ContainerButton;
         nextRewardButton.addEventListener("triggered",triggeredNextRewardBtn);
         nextRewardIcon = nextRewardButton.getChildByName("imgReward") as Image;
         nextRewardIcon.addEventListener("enterFrame",onEnterFrame);
         var balloonSprite:Sprite = nextRewardButton.getChildByName("balloonSprite") as Sprite;
         var nextRewardWord:ColorTextField = balloonSprite.getChildByName("lblNextReward") as ColorTextField;
         finishSprite = nextRewardButton.getChildByName("finishSprite") as Sprite;
         finishSprite.visible = false;
         if(paneltype == 1)
         {
            var result:Object = getCurrentVoicesMissionData();
            if(result)
            {
               var rusultCode:int = result.resultcode;
               if(rusultCode != -1)
               {
                  missionType = rusultCode;
               }
               var missionData:MissionData = result.missiondata;
               var item:ItemParam = missionData.rewards[0];
               nextRewardWord.text#2 = StringUtil.format(GameSetting.getUIText("collection.nextreward.voice." + missionType),missionData.goal - missionData.currentValue);
               var imageName:String = GudetamaUtil.getItemIconName(item.kind,item.id#2);
               TextureCollector.loadTexture(imageName,function(param1:Texture):void
               {
                  nextRewardIcon.texture = param1;
                  if(rusultCode == -1)
                  {
                     finishSprite.visible = true;
                     nextRewardIcon.color = 5263440;
                     balloonSprite.visible = false;
                  }
               });
            }
         }
         else
         {
            result = GameSetting.getCurrentMissionDataByType(1);
            rusultCode = result.resultcode;
            missionData = result.missiondata;
            if(missionData)
            {
               item = missionData.rewards[0];
               nextRewardWord.text#2 = StringUtil.format(GameSetting.getUIText("collection.nextreward"),missionData.goal - missionData.currentValue);
               imageName = GudetamaUtil.getItemIconName(item.kind,item.id#2);
               TextureCollector.loadTexture(imageName,function(param1:Texture):void
               {
                  nextRewardIcon.texture = param1;
                  if(rusultCode == -1)
                  {
                     finishSprite.visible = true;
                     nextRewardIcon.color = 5263440;
                     balloonSprite.visible = false;
                  }
               });
            }
         }
         _setupLayoutForTask(queue,paneltype == 0 ? "_CollectionGudetamaIcon" : "_CollectionVoiceLabel",function(param1:Object):void
         {
            gudetamaIconExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         _setupLayoutForTask(queue,"_CollectionGudetamaListLabel",function(param1:Object):void
         {
            gudetamaLabelExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         _setupLayoutForTask(queue,"_PageButton",function(param1:Object):void
         {
            pageButtonExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
      }
      
      public function init() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 2;
         layout.verticalGap = 10;
         layout.paddingLeft = 16;
         layout.paddingTop = 5;
         layout.offsetPaintHeight = 150;
         list.layout = layout;
         list.setItemRendererFactoryWithID("icon",function():IListItemRenderer
         {
            if(paneltype == 1)
            {
               return new VoiceIconListItemRenderer(gudetamaIconExtractor,triggeredGudetamaIconUICallback,triggeredVoiceUIVoiceCallback);
            }
            return new GudetamaIconListItemRenderer(gudetamaIconExtractor,triggeredGudetamaIconUICallback);
         });
         list.setItemRendererFactoryWithID("label",function():IListItemRenderer
         {
            return new GudetamaLabelListItemRenderer(gudetamaLabelExtractor);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            if(param1.title is String)
            {
               return "label";
            }
            return "icon";
         };
         list.selectedIndex = -1;
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
         list.addEventListener("scrollComplete",scrollComplete);
         pageManger = new PageManager(400,pageButtonExtractor,5,true);
         pageManger.x = (picturebookSprite.width - 320) / 2;
         pageManger.y = list.y + list.height + 15;
         pageManger.setListener(this);
         picturebookSprite.addChild(pageManger);
         setup();
      }
      
      private function scrollStart(param1:Event) : void
      {
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc2_:ListDataViewPort = list.getChildAt(0) as ListDataViewPort;
         while(_loc4_ < _loc2_.numChildren)
         {
            _loc3_ = _loc2_.getChildAt(_loc4_) as GudetamaIconListItemRenderer;
            if(_loc3_)
            {
               _loc3_.isScrolling();
            }
            _loc4_++;
         }
      }
      
      private function scrollComplete(param1:Event) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc5_:int = 0;
         var _loc4_:* = null;
         if(paneltype == 1)
         {
            _loc2_ = list.getChildAt(0) as ListDataViewPort;
            _loc5_ = 0;
            while(_loc5_ < _loc2_.numChildren)
            {
               _loc3_ = _loc2_.getChildAt(_loc5_) as GudetamaIconListItemRenderer;
               if(_loc3_)
               {
                  _loc3_.update();
               }
               _loc5_++;
            }
         }
         else
         {
            _loc2_ = list.getChildAt(0) as ListDataViewPort;
            _loc5_ = 0;
            while(_loc5_ < _loc2_.numChildren)
            {
               if(_loc4_ = _loc2_.getChildAt(_loc5_) as GudetamaIconListItemRenderer)
               {
                  _loc4_.update();
               }
               _loc5_++;
            }
         }
      }
      
      private function setup() : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:* = null;
         var _loc1_:Boolean = false;
         checkLabelTitle();
         for each(_loc2_ in GameSetting.getGudetamaMap())
         {
            if(!(paneltype == 1 && !UserDataWrapper.wrapper.isScreenableInCollection(_loc2_.id#2)))
            {
               _loc1_ = UserDataWrapper.gudetamaPart.isCooked(_loc2_.id#2);
               if(_loc1_)
               {
                  if(paneltype == 1)
                  {
                     if(UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc2_.id#2,0))
                     {
                        _loc4_++;
                     }
                     if(UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc2_.id#2,1))
                     {
                        _loc4_++;
                     }
                  }
                  else
                  {
                     _loc4_++;
                  }
               }
               if(_loc2_.type == 1)
               {
                  gudetamas.push(_loc2_);
                  _loc3_++;
               }
               else if(GudetamaUtil.isPushEventGudetamaList(_loc2_))
               {
                  eventGudetamas.push(_loc2_);
                  _loc3_++;
               }
            }
         }
         achieveText.text#2 = _loc4_.toString();
         maxAchieveText.text#2 = paneltype == 1 ? (_loc3_ * 2).toString() : _loc3_.toString();
      }
      
      public function addedToContainer() : void
      {
         updateList();
      }
      
      public function transitionOpenFinished() : void
      {
         var _loc3_:* = null;
         var _loc2_:* = 0;
         var _loc5_:int = 0;
         var _loc4_:* = null;
         var _loc1_:ListDataViewPort = list.getChildAt(0) as ListDataViewPort;
         if(paneltype == 1)
         {
            _loc2_ = uint(_loc1_.numChildren);
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc3_ = _loc1_.getChildAt(_loc5_) as VoiceIconListItemRenderer;
               if(_loc3_ != null)
               {
                  if(_loc3_.getGudetamaId() != 6)
                  {
                     _loc3_.touchable = false;
                  }
               }
               _loc5_++;
            }
         }
         else
         {
            _loc2_ = uint(_loc1_.numChildren);
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               if((_loc4_ = _loc1_.getChildAt(_loc5_) as GudetamaIconListItemRenderer) != null)
               {
                  if(_loc4_.getGudetamaId() != 6)
                  {
                     _loc4_.touchable = false;
                  }
               }
               _loc5_++;
            }
         }
         list.verticalScrollPolicy = "off";
      }
      
      public function noticeTutorialAction(param1:int) : void
      {
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc3_:* = 0;
         var _loc6_:int = 0;
         var _loc5_:* = null;
         switch(int(param1))
         {
            case 0:
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               if(paneltype == 1)
               {
                  _loc3_ = uint(_loc2_.numChildren);
                  _loc6_ = 0;
                  while(_loc6_ < _loc3_)
                  {
                     if((_loc4_ = _loc2_.getChildAt(_loc6_) as VoiceIconListItemRenderer) != null)
                     {
                        if(_loc4_.getGudetamaId() != 6)
                        {
                           _loc4_.touchable = true;
                        }
                     }
                     _loc6_++;
                  }
                  list.verticalScrollPolicy = "auto";
                  break;
               }
               _loc3_ = uint(_loc2_.numChildren);
               _loc6_ = 0;
               while(_loc6_ < _loc3_)
               {
                  if((_loc5_ = _loc2_.getChildAt(_loc6_) as GudetamaIconListItemRenderer) != null)
                  {
                     if(_loc5_.getGudetamaId() != 6)
                     {
                        _loc5_.touchable = true;
                     }
                  }
                  _loc6_++;
               }
               list.verticalScrollPolicy = "auto";
               break;
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc3_:* = undefined;
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc6_:int = 0;
         var _loc5_:* = null;
         loop2:
         switch(int(param1) - 1)
         {
            case 0:
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               if(paneltype == 1)
               {
                  while(_loc6_ < _loc2_.numChildren)
                  {
                     if((_loc4_ = _loc2_.getChildAt(_loc6_) as VoiceIconListItemRenderer) != null)
                     {
                        if(_loc4_.getGudetamaId() == 6)
                        {
                           return _loc4_.getSpritePos();
                        }
                     }
                     _loc6_++;
                  }
                  break;
               }
               _loc6_;
               while(true)
               {
                  if(_loc6_ >= _loc2_.numChildren)
                  {
                     break loop2;
                  }
                  if((_loc5_ = _loc2_.getChildAt(_loc6_) as GudetamaIconListItemRenderer) != null)
                  {
                     if(_loc5_.getGudetamaId() == 6)
                     {
                        return _loc5_.getSpritePos();
                     }
                  }
                  _loc6_++;
               }
               break;
         }
         return _loc3_;
      }
      
      private function triggeredNextRewardBtn(param1:Event) : void
      {
         if(paneltype == 1)
         {
            CollectionVoicesMissionDialog.show(missionType);
         }
         else
         {
            CollectionMissionDialog.show(1,achieveText.text#2,maxAchieveText.text#2);
         }
      }
      
      private function updateList() : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc6_:Array;
         var _loc1_:Function = (_loc6_ = paneltype == 0 ? comparatorGudetamaPairs[currentSortIndex] : comparatorVoicePairs[currentSortIndex])[!!sortAscending ? 1 : 0];
         this.comparator = _loc1_;
         showableGudetamas.length = 0;
         collections.length = 0;
         showableIndex = 0;
         currentCategory = -1;
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         if(homeGudetamaToTop)
         {
            topItem = {
               "index":showableIndex,
               "gudetamaDef":homeGudetamaDef,
               "homeGude":true
            };
         }
         var _loc7_:* = (currentFilter1Index & 1) != 0;
         var _loc2_:* = (currentFilter1Index & 2) != 0;
         if(_loc7_)
         {
            addNomalGudetama();
         }
         if(_loc2_)
         {
            addEventGudetama();
         }
         achieveGroup.visible = true;
         var _loc5_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < collections.length)
         {
            _loc3_ = collections[_loc4_];
            if(_loc3_.length > 1)
            {
               _loc5_++;
            }
            _loc4_++;
         }
         pageManger.updatePageInfo(_loc5_,0);
      }
      
      private function addNomalGudetama() : void
      {
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc8_:* = 0;
         var _loc2_:* = null;
         var _loc1_:* = false;
         var _loc10_:Boolean = false;
         var _loc11_:* = false;
         gudetamas.sort(comparator);
         var _loc5_:uint = gudetamas.length;
         var _loc9_:uint = gudetamas[0].number % 100;
         var _loc3_:uint = 0;
         var _loc7_:* = paneltype == 1;
         currentCategory = -1;
         _loc3_ = 0;
         for(; _loc3_ < _loc5_; _loc3_++)
         {
            _loc4_ = gudetamas[_loc3_];
            if(paneltype == 0 && currentSortIndex == 1)
            {
               if(_loc3_ % 100 == 0)
               {
                  _loc6_ = new ListCollection();
                  collections.push(_loc6_);
                  currentCategory = -1;
               }
            }
            else if((_loc8_ = uint(_loc4_.number)) % 100 == _loc9_)
            {
               _loc6_ = new ListCollection();
               collections.push(_loc6_);
            }
            addHomeGudetama(_loc6_);
            addExtraLabel(_loc4_,_loc6_);
            _loc1_ = !_loc7_;
            _loc10_ = UserDataWrapper.wrapper.isScreenableInCollection(_loc4_.id#2);
            if(_loc7_)
            {
               if(_loc10_)
               {
                  _loc1_ = Boolean(checkVoiceFilter(_loc4_));
               }
            }
            if(homeGudetamaToTop)
            {
               if(_loc4_.id#2 == homeGudetamaDef.id#2)
               {
                  continue;
               }
            }
            if(_loc1_)
            {
               _loc11_ = _loc4_.id#2 == homeGudetamaDef.id#2;
               if(_loc10_)
               {
                  showableGudetamas.push(_loc4_);
                  _loc2_ = {
                     "index":showableIndex,
                     "gudetamaDef":_loc4_,
                     "homeGude":_loc11_
                  };
                  showableIndex++;
               }
               else
               {
                  _loc2_ = {
                     "index":-1,
                     "gudetamaDef":_loc4_,
                     "homeGude":_loc11_
                  };
               }
               _loc6_.addItem(_loc2_);
            }
         }
      }
      
      private function addEventGudetama() : void
      {
         var _loc6_:* = null;
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc8_:Boolean = false;
         var _loc2_:* = null;
         var _loc9_:* = false;
         var _loc1_:* = false;
         eventGudetamas.sort(comparator);
         var _loc3_:int = -1;
         var _loc7_:* = paneltype == 1;
         _loc4_ = 0;
         for(; _loc4_ < eventGudetamas.length; _loc4_++)
         {
            if(paneltype == 0 && currentSortIndex == 1)
            {
               if(_loc4_ % 100 == 0)
               {
                  _loc6_ = new ListCollection();
                  collections.push(_loc6_);
                  _loc3_ = -1;
               }
            }
            else if(_loc4_ % 100 == 0)
            {
               _loc6_ = new ListCollection();
               collections.push(_loc6_);
            }
            addHomeGudetama(_loc6_);
            _loc5_ = eventGudetamas[_loc4_];
            addExtraLabel(_loc5_,_loc6_);
            if(homeGudetamaToTop)
            {
               if(_loc5_.id#2 == homeGudetamaDef.id#2)
               {
                  continue;
               }
            }
            _loc8_ = UserDataWrapper.wrapper.isScreenableInCollection(_loc5_.id#2);
            _loc9_ = _loc5_.id#2 == homeGudetamaDef.id#2;
            _loc1_ = !_loc7_;
            if(_loc7_)
            {
               _loc1_ = Boolean(checkVoiceFilter(_loc5_));
            }
            if(_loc1_)
            {
               if(_loc8_)
               {
                  showableGudetamas.push(_loc5_);
                  _loc2_ = {
                     "index":showableIndex,
                     "gudetamaDef":_loc5_,
                     "homeGude":_loc9_
                  };
                  showableIndex++;
               }
               else
               {
                  _loc2_ = {
                     "index":-1,
                     "gudetamaDef":_loc5_,
                     "homeGude":_loc9_
                  };
               }
               _loc6_.addItem(_loc2_);
            }
         }
      }
      
      private function addHomeGudetama(param1:ListCollection) : void
      {
         if(topItem)
         {
            showableGudetamas.push(homeGudetamaDef);
            param1.addItem(topItem);
            showableIndex++;
            topItem = null;
         }
      }
      
      private function addExtraLabel(param1:GudetamaDef, param2:ListCollection) : void
      {
         if(paneltype == 0)
         {
            switch(int(currentSortIndex) - 1)
            {
               case 0:
                  if(currentCategory != param1.category)
                  {
                     param2.addItem({
                        "title":GameSetting.getUIText("gudetama.category." + param1.category),
                        "currentCategory":currentCategory
                     });
                     currentCategory = param1.category;
                  }
            }
         }
      }
      
      private function checkVoiceFilter(param1:GudetamaDef) : Boolean
      {
         var _loc2_:* = false;
         var _loc6_:int = param1.voices.length;
         var _loc5_:* = false;
         var _loc3_:* = (1 & currentFilter2Index) > 0;
         var _loc4_:* = (2 & currentFilter2Index) > 0;
         if(!_loc3_ && !_loc4_)
         {
            return true;
         }
         if(_loc3_)
         {
            _loc5_ = !UserDataWrapper.gudetamaPart.isUnlockedVoice(param1.id#2,0);
         }
         if(_loc4_)
         {
            _loc2_ = !UserDataWrapper.gudetamaPart.isUnlockedVoice(param1.id#2,1);
            if(_loc3_ && (!_loc5_ || !_loc2_))
            {
               return false;
            }
            _loc5_ = _loc2_;
         }
         return _loc5_;
      }
      
      private function checkLabelTitle() : void
      {
         var _loc1_:* = (currentFilter1Index & 2) != 0;
         if(paneltype == 0)
         {
            switch(int(currentSortIndex))
            {
               case 0:
                  if(_loc1_)
                  {
                     labelTitleText.text#2 = GameSetting.getUIText("%collection.gudetama.sort.4");
                  }
                  else
                  {
                     labelTitleText.text#2 = GameSetting.getUIText("%collection.gudetama.sort.0");
                  }
                  break;
               case 1:
                  labelTitleText.text#2 = GameSetting.getUIText("%collection.gudetama.sort.1");
                  break;
               case 2:
                  labelTitleText.text#2 = GameSetting.getUIText("%cooking.cost.2");
            }
         }
         else
         {
            switch(int(currentSortIndex))
            {
               case 0:
                  if(_loc1_)
                  {
                     labelTitleText.text#2 = GameSetting.getUIText("%collection.gudetama.sort.4");
                  }
                  else
                  {
                     labelTitleText.text#2 = GameSetting.getUIText("%collection.voice.sort.0");
                  }
                  break;
               case 1:
                  labelTitleText.text#2 = GameSetting.getUIText("%cooking.cost.2");
            }
         }
      }
      
      private function getCurrentVoicesMissionData() : Object
      {
         var _loc2_:* = null;
         var _loc6_:* = null;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc9_:Array = GameSetting.getMissionDataType(2);
         for each(_loc6_ in _loc9_)
         {
            if(_loc4_ = _loc6_.missionData as MissionData)
            {
               _loc7_ = _loc4_;
               if(_loc4_.goal - _loc4_.currentValue > 0)
               {
                  _loc8_ = _loc4_.goal - _loc4_.currentValue;
                  _loc2_ = _loc4_;
                  break;
               }
            }
         }
         _loc9_ = GameSetting.getMissionDataType(8);
         for each(_loc6_ in _loc9_)
         {
            if(_loc4_ = _loc6_.missionData as MissionData)
            {
               _loc3_ = _loc4_;
               if(_loc4_.goal - _loc4_.currentValue > 0)
               {
                  _loc10_ = _loc4_.goal - _loc4_.currentValue;
                  _loc5_ = _loc4_;
                  break;
               }
            }
         }
         var _loc1_:Object = {};
         if(_loc2_ && _loc5_)
         {
            if(_loc8_ == _loc10_)
            {
               _loc1_ = {
                  "resultcode":2,
                  "missiondata":_loc5_
               };
            }
            else if(_loc8_ > _loc10_)
            {
               _loc1_ = {
                  "resultcode":2,
                  "missiondata":_loc5_
               };
            }
            else
            {
               _loc1_ = {
                  "resultcode":1,
                  "missiondata":_loc2_
               };
            }
         }
         else if(_loc2_)
         {
            _loc1_ = {
               "resultcode":1,
               "missiondata":_loc2_
            };
         }
         else if(_loc5_)
         {
            _loc1_ = {
               "resultcode":2,
               "missiondata":_loc5_
            };
         }
         else
         {
            if(!_loc7_ || !_loc3_)
            {
               return null;
            }
            if(_loc7_.goal == _loc3_.goal)
            {
               _loc1_ = {
                  "resultcode":-1,
                  "missiondata":_loc3_
               };
            }
            else if(_loc7_.goal > _loc3_.goal)
            {
               _loc1_ = {
                  "resultcode":-1,
                  "missiondata":_loc3_
               };
            }
            else
            {
               _loc1_ = {
                  "resultcode":-1,
                  "missiondata":_loc7_
               };
            }
         }
         return _loc1_;
      }
      
      private function ascendingNumberComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.number > param2.number)
         {
            return 1;
         }
         if(param1.number < param2.number)
         {
            return -1;
         }
         return ascendingIdComparator(param1,param2);
      }
      
      private function ascendingNumberComparatorVerCategory(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.number == 0)
         {
            return 1;
         }
         if(param1.number > param2.number)
         {
            return 1;
         }
         if(param1.number < param2.number)
         {
            return -1;
         }
         return descendingIdComparator(param1,param2);
      }
      
      private function descendingNumberComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.number > param2.number)
         {
            return -1;
         }
         if(param1.number < param2.number)
         {
            return 1;
         }
         return descendingIdComparator(param1,param2);
      }
      
      private function ascendingIdComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.id#2 > param2.id#2)
         {
            return 1;
         }
         if(param1.id#2 < param2.id#2)
         {
            return -1;
         }
         return 0;
      }
      
      private function descendingIdComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.id#2 > param2.id#2)
         {
            return -1;
         }
         if(param1.id#2 < param2.id#2)
         {
            return 1;
         }
         return 0;
      }
      
      private function ascendingCostComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.cost > param2.cost)
         {
            return 1;
         }
         if(param1.cost < param2.cost)
         {
            return -1;
         }
         return ascendingIdComparator(param1,param2);
      }
      
      private function descendingCostComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.cost > param2.cost)
         {
            return -1;
         }
         if(param1.cost < param2.cost)
         {
            return 1;
         }
         return descendingIdComparator(param1,param2);
      }
      
      private function ascendingCategoryComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.category > param2.category)
         {
            return 1;
         }
         if(param1.category < param2.category)
         {
            return -1;
         }
         return ascendingNumberComparatorVerCategory(param1,param2);
      }
      
      private function descendingCategoryComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.category > param2.category)
         {
            return -1;
         }
         if(param1.category < param2.category)
         {
            return 1;
         }
         return ascendingNumberComparatorVerCategory(param1,param2);
      }
      
      private function triggeredGudetamaIconUICallback(param1:int) : void
      {
         GudetamaDetailDialog.show(showableGudetamas,param1);
      }
      
      private function triggeredVoiceUIVoiceCallback(param1:VoiceDef) : void
      {
         voiceManager.playVoice(param1);
      }
      
      private function backButtonCallback() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function onEnterFrame(param1:EnterFrameEvent) : void
      {
         try
         {
            update();
         }
         catch(e:Error)
         {
         }
      }
      
      public function update() : void
      {
         if(voiceManager)
         {
            voiceManager.updateVoice();
         }
      }
      
      private function triggeredSortBtn(param1:Event) : void
      {
         if(paneltype == 0)
         {
            CollectionGudetamaFilterDialog.show((currentFilter1Index & 2) != 0,sortAscending,currentSortIndex,currentFilter2Index,homeGudetamaToTop,filterCallback);
         }
         else
         {
            CollectionVoiceFilterDialog.show((currentFilter1Index & 2) != 0,sortAscending,currentSortIndex,currentFilter2Index,homeGudetamaToTop,filterCallback);
         }
      }
      
      private function filterCallback(param1:Boolean, param2:int, param3:int, param4:Boolean) : void
      {
         sortAscending = param1;
         currentSortIndex = param2;
         currentFilter2Index = param3;
         if(paneltype == 0)
         {
            homeGudetamaToTop = false;
         }
         else
         {
            homeGudetamaToTop = param4;
         }
         checkLabelTitle();
         updateList();
      }
      
      public function triggeredToggleButtonCallback(param1:int) : void
      {
         currentFilter1Index = param1;
         checkLabelTitle();
         updateList();
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      public function changePage(param1:int) : void
      {
         list.dataProvider = collections[param1];
      }
      
      override public function set visible(param1:Boolean) : void
      {
         picturebookSprite.visible = param1;
         super.visible = param1;
      }
      
      override public function dispose() : void
      {
         nextRewardIcon.removeEventListener("enterFrame",onEnterFrame);
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         list = null;
         achieveGroup = null;
         achieveText = null;
         maxAchieveText = null;
         gudetamaIconExtractor = null;
         gudetamaLabelExtractor = null;
         collections.length = 0;
         collections = null;
         pageManger = null;
         gudetamas.length = 0;
         gudetamas = null;
         showableGudetamas.length = 0;
         showableGudetamas = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.common.GudetamaUtil;
import gudetama.util.SpriteExtractor;
import starling.display.DisplayObject;
import starling.display.Sprite;

class GudetamaIconListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var gudetamaIconUI:GudetamaIconUI;
   
   private var _isScrolling:Boolean = false;
   
   function GudetamaIconListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      gudetamaIconUI = new GudetamaIconUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   public function isScrolling() : void
   {
      _isScrolling = true;
   }
   
   public function update() : void
   {
      _isScrolling = false;
      gudetamaIconUI.updateData(data#2);
   }
   
   override protected function commitData() : void
   {
      if(!_isScrolling)
      {
         gudetamaIconUI.updateData(data#2);
      }
   }
   
   public function getSpritePos() : Vector.<Number>
   {
      var _loc1_:DisplayObject = gudetamaIconUI.getCookedEggButton();
      if(_loc1_ == null)
      {
         return null;
      }
      return GudetamaUtil.getCenterPosAndWHOnEngine(_loc1_);
   }
   
   public function getGudetamaId() : int
   {
      return gudetamaIconUI.getGudetamaId();
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      gudetamaIconUI.dispose();
      gudetamaIconUI = null;
      super.dispose();
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.common.GudetamaUtil;
import gudetama.util.SpriteExtractor;
import starling.display.DisplayObject;
import starling.display.Sprite;

class VoiceIconListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var voiceCallback:Function;
   
   private var displaySprite:Sprite;
   
   private var voiceLabelUI:VoiceLabelUI;
   
   function VoiceIconListItemRenderer(param1:SpriteExtractor, param2:Function, param3:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
      this.voiceCallback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      voiceLabelUI = new VoiceLabelUI(displaySprite,callback,voiceCallback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      voiceLabelUI.updateData(data#2);
   }
   
   public function getSpritePos() : Vector.<Number>
   {
      var _loc1_:DisplayObject = voiceLabelUI.getCookedEggButton();
      if(_loc1_ == null)
      {
         return null;
      }
      return GudetamaUtil.getCenterPosAndWHOnEngine(_loc1_);
   }
   
   public function getGudetamaId() : int
   {
      return voiceLabelUI.getGudetamaId();
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      voiceLabelUI.dispose();
      voiceLabelUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class GudetamaIconUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var numberText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var voiceGroup:Sprite;
   
   private var voiceText:ColorTextField;
   
   private var emptyImage:Image;
   
   private var lockImage:Image;
   
   private var index:int;
   
   private var gudetamaId:int;
   
   private var defEmptyImageColor:uint;
   
   private var defIconImageColor:uint;
   
   function GudetamaIconUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.setHitMargin(-5,-10);
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      numberText = button.getChildByName("number") as ColorTextField;
      nameText = button.getChildByName("name") as ColorTextField;
      voiceGroup = button.getChildByName("voiceGroup") as Sprite;
      voiceText = voiceGroup.getChildByName("voice") as ColorTextField;
      emptyImage = button.getChildByName("empty") as Image;
      lockImage = button.getChildByName("lock") as Image;
      defIconImageColor = iconImage.color;
      defEmptyImageColor = emptyImage.color;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      reset();
      if(!data)
      {
         return;
      }
      index = data.index;
      var gudetamaDef:GudetamaDef = data.gudetamaDef;
      gudetamaId = gudetamaDef.id#2;
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
      nameText.text#2 = gudetamaDef.getWrappedName();
      var unlockVoiceNum:uint = UserDataWrapper.gudetamaPart.getNumUnlockedVoice(gudetamaDef.id#2);
      voiceGroup.visible = unlockVoiceNum > 0;
      voiceText.text#2 = String(unlockVoiceNum);
      if(!UserDataWrapper.wrapper.isScreenableInCollection(gudetamaDef.id#2))
      {
         iconImage.visible = false;
         emptyImage.visible = true;
         emptyImage.color = 8421504;
         lockImage.visible = true;
         numberText.visible = false;
         nameText.visible = false;
         button.touchable = false;
      }
      else if(!UserDataWrapper.gudetamaPart.isCooked(gudetamaDef.id#2))
      {
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
            iconImage.color = 5263440;
         });
         emptyImage.visible = false;
         lockImage.visible = false;
         numberText.visible = false;
         nameText.visible = false;
         button.touchable = true;
      }
      else
      {
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         emptyImage.visible = false;
         lockImage.visible = false;
         if(gudetamaDef.type != 1)
         {
            numberText.visible = false;
         }
         else
         {
            numberText.visible = true;
         }
         nameText.visible = true;
         button.touchable = true;
      }
   }
   
   private function reset() : void
   {
      iconImage.visible = false;
      iconImage.texture = null;
      iconImage.color = defIconImageColor;
      emptyImage.color = defEmptyImageColor;
      lockImage.visible = false;
      numberText.visible = false;
      nameText.visible = false;
      button.touchable = false;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      if(index < 0)
      {
         return;
      }
      callback(index);
   }
   
   public function getCookedEggButton() : ContainerButton
   {
      if(emptyImage.visible)
      {
         return null;
      }
      return button;
   }
   
   public function getGudetamaId() : int
   {
      return gudetamaId;
   }
   
   public function dispose() : void
   {
      callback = null;
      button = null;
      numberText = null;
      nameText = null;
      voiceText = null;
      emptyImage = null;
      lockImage = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.common.VoiceManager;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.VoiceDef;
import gudetama.engine.SoundManager;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class VoiceLabelUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var voiceCallback:Function;
   
   private var voiceButton1:ContainerButton;
   
   private var voiceButton2:ContainerButton;
   
   private var defVoiceButton1Color:uint;
   
   private var defVoiceButton2Color:uint;
   
   private var speaker1Image:Image;
   
   private var speaker2Image:Image;
   
   private var defSpeaker1ImageColor:uint;
   
   private var defSpeaker2ImageColor:uint;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var deIconImageColor:uint;
   
   private var numberText:ColorTextField;
   
   private var speechText1:ColorTextField;
   
   private var speechText2:ColorTextField;
   
   private var speechText1Color:uint;
   
   private var speechText2Color:uint;
   
   private var emptyImage:Image;
   
   private var lockImage:Image;
   
   private var index:int;
   
   private var gudetamaId:int;
   
   private var voiceDef1:VoiceDef;
   
   private var voiceDef2:VoiceDef;
   
   private var homeIcon:Image;
   
   function VoiceLabelUI(param1:Sprite, param2:Function, param3:Function)
   {
      super(param1);
      this.callback = param2;
      this.voiceCallback = param3;
      voiceButton1 = param1.getChildByName("voiceButton1") as ContainerButton;
      voiceButton1.addEventListener("triggered",triggeredVoiceButton1);
      defVoiceButton1Color = voiceButton1.color;
      speechText1 = voiceButton1.getChildByName("speech") as ColorTextField;
      speechText1Color = speechText1.color;
      speaker1Image = voiceButton1.getChildByName("home1@voice") as Image;
      defSpeaker1ImageColor = speaker1Image.color;
      voiceButton2 = param1.getChildByName("voiceButton2") as ContainerButton;
      voiceButton2.addEventListener("triggered",triggeredVoiceButton2);
      defVoiceButton2Color = voiceButton2.color;
      speechText2 = voiceButton2.getChildByName("speech") as ColorTextField;
      speechText2Color = speechText2.color;
      speaker2Image = voiceButton2.getChildByName("home1@voice") as Image;
      defSpeaker2ImageColor = speaker2Image.color;
      button = param1.getChildByName("button") as ContainerButton;
      button.setHitMargin(-5,-10);
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      deIconImageColor = iconImage.color;
      numberText = param1.getChildByName("number") as ColorTextField;
      emptyImage = button.getChildByName("empty") as Image;
      lockImage = button.getChildByName("lock") as Image;
      homeIcon = button.getChildByName("home") as Image;
      homeIcon.visible = false;
   }
   
   public static function deleteNewLineAndBlank(param1:String) : String
   {
      var _loc2_:RegExp = /\n/g;
      param1 = param1.replace(_loc2_,"");
      _loc2_ = /\r/g;
      param1 = param1.replace(_loc2_,"");
      _loc2_ = /\r\n/g;
      param1 = param1.replace(_loc2_,"");
      var _loc3_:RegExp = /[\s\r\n]+/gim;
      return param1.replace(_loc3_,"");
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      voiceDef1 = null;
      voiceDef2 = null;
      iconImage.color = deIconImageColor;
      voiceButton1.color = defVoiceButton1Color;
      voiceButton2.color = defVoiceButton2Color;
      speaker1Image.color = defSpeaker1ImageColor;
      speaker1Image.alpha = 1;
      speaker2Image.color = defSpeaker2ImageColor;
      speaker2Image.alpha = 1;
      speechText1.color = speechText1Color;
      speechText2.color = speechText2Color;
      homeIcon.visible = false;
      if(!data)
      {
         return;
      }
      index = data.index;
      homeIcon.visible = data.homeGude;
      var gudetamaDef:GudetamaDef = data.gudetamaDef;
      gudetamaId = gudetamaDef.id#2;
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
      var voicemsg1:String = GameSetting.getUIText("collection.voice.invisible");
      if(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,0))
      {
         voiceDef1 = GameSetting.getVoice(gudetamaDef.voices[0]);
         voicemsg1 = VoiceManager.getCombinedNames(voiceDef1);
      }
      else
      {
         voiceButton1.color = 9079434;
         speaker1Image.color = 9075267;
         speaker1Image.alpha = 0.43;
         speechText1.color = 4073756;
      }
      speechText1.text#2 = deleteNewLineAndBlank(voicemsg1);
      var voicemsg2:String = GameSetting.getUIText("collection.voice.invisible");
      if(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,1))
      {
         voiceDef2 = GameSetting.getVoice(gudetamaDef.voices[1]);
         voicemsg2 = VoiceManager.getCombinedNames(voiceDef2);
      }
      else
      {
         voiceButton2.color = 9079434;
         speaker2Image.color = 9075267;
         speaker2Image.alpha = 0.43;
         speechText2.color = 4073756;
      }
      speechText2.text#2 = deleteNewLineAndBlank(voicemsg2);
      if(!UserDataWrapper.wrapper.isScreenableInCollection(gudetamaDef.id#2))
      {
         iconImage.visible = false;
         emptyImage.visible = true;
         emptyImage.color = 8421504;
         lockImage.visible = true;
         button.touchable = false;
      }
      else if(!UserDataWrapper.gudetamaPart.isCooked(gudetamaDef.id#2))
      {
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
            iconImage.color = 5263440;
         });
         emptyImage.visible = false;
         lockImage.visible = false;
         button.touchable = true;
      }
      else
      {
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         emptyImage.visible = false;
         lockImage.visible = false;
         if(gudetamaDef.type != 1)
         {
            numberText.visible = false;
         }
         else
         {
            numberText.visible = true;
         }
         button.touchable = true;
      }
   }
   
   private function triggeredVoiceButton1(param1:Event) : void
   {
      if(index < 0)
      {
         return;
      }
      if(voiceDef1)
      {
         voiceCallback(voiceDef1);
      }
      else
      {
         SoundManager.playEffect("btn_cancel");
      }
   }
   
   private function triggeredVoiceButton2(param1:Event) : void
   {
      if(index < 0)
      {
         return;
      }
      if(voiceDef2)
      {
         voiceCallback(voiceDef2);
      }
      else
      {
         SoundManager.playEffect("btn_cancel");
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      if(index < 0)
      {
         return;
      }
      callback(index);
   }
   
   public function getCookedEggButton() : ContainerButton
   {
      if(emptyImage.visible)
      {
         return null;
      }
      return button;
   }
   
   public function getGudetamaId() : int
   {
      return gudetamaId;
   }
   
   public function dispose() : void
   {
      callback = null;
      button = null;
      numberText = null;
      emptyImage = null;
      lockImage = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class GudetamaLabelListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var gudetamaLabelUI:GudetamaLabelUI;
   
   function GudetamaLabelListItemRenderer(param1:SpriteExtractor)
   {
      super();
      this.extractor = param1;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      gudetamaLabelUI = new GudetamaLabelUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      gudetamaLabelUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      gudetamaLabelUI.dispose();
      gudetamaLabelUI = null;
      super.dispose();
   }
}

import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Sprite;

class GudetamaLabelUI extends UIBase
{
    
   
   private var titleText:ColorTextField;
   
   function GudetamaLabelUI(param1:Sprite)
   {
      super(param1);
      titleText = param1.getChildByName("title") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      titleText.text#2 = param1.title;
      var _loc2_:int = param1.currentCategory;
      if(_loc2_ != -1)
      {
         displaySprite.y += 15;
      }
   }
   
   public function dispose() : void
   {
      titleText = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.engine.TweenAnimator;
import muku.core.TaskQueue;
import starling.display.Sprite;

class ToggleUIGroup
{
    
   
   private var displaySprite:Sprite;
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleUI>;
   
   private var width:Number;
   
   function ToggleUIGroup(param1:Sprite, param2:Function)
   {
      var _loc3_:int = 0;
      toggleUIList = new Vector.<ToggleUI>();
      super();
      this.displaySprite = param1;
      this.callback = param2;
      toggleGroup = new ToggleGroup();
      _loc3_ = 0;
      while(_loc3_ < param1.numChildren)
      {
         toggleUIList.push(new ToggleUI(param1.getChildByName("btn_tab" + _loc3_) as Sprite,triggeredButtonCallback,_loc3_,toggleGroup,_loc3_ == 0));
         _loc3_++;
      }
      toggleUIList[0].setSelected(true);
      width = param1.width;
   }
   
   public function setupWide(param1:TaskQueue) : void
   {
      var _loc3_:* = 0;
      var _loc2_:uint = toggleUIList.length;
      _loc3_ = uint(0);
      while(_loc3_ < _loc2_)
      {
         toggleUIList[_loc3_].setupWide(param1);
         _loc3_++;
      }
   }
   
   public function setVisible(param1:int, param2:Boolean) : void
   {
      toggleUIList[param1].setVisible(param2);
   }
   
   public function get length() : int
   {
      return toggleUIList.length;
   }
   
   public function setupLayout() : void
   {
      var _loc2_:int = 0;
      for each(var _loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc2_++;
         }
      }
      var _loc3_:int = 0;
      for each(_loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc1_.getDisplaySprite().x = (_loc3_ + 1) * (width - _loc2_ * _loc1_.getDisplaySprite().width) / (_loc2_ + 1) + _loc3_ * _loc1_.getDisplaySprite().width;
            _loc3_++;
         }
      }
   }
   
   public function setAllTouchable(param1:Boolean) : void
   {
      var _loc3_:* = 0;
      var _loc2_:uint = toggleUIList.length;
      _loc3_ = uint(0);
      while(_loc3_ < _loc2_)
      {
         toggleUIList[_loc3_].setTouchable(param1);
         _loc3_++;
      }
   }
   
   public function startTween(param1:*, param2:Boolean = false, param3:Function = null) : void
   {
      TweenAnimator.startItself(displaySprite,param1,param2,param3);
   }
   
   private function triggeredButtonCallback(param1:int) : void
   {
      select(param1);
   }
   
   public function select(param1:int) : void
   {
      var _loc4_:* = 0;
      var _loc5_:Boolean = false;
      var _loc3_:Boolean = false;
      for each(var _loc2_ in toggleUIList)
      {
         if(_loc2_.isVisible())
         {
            if(_loc5_ = _loc2_.isSelected())
            {
               _loc4_ |= _loc2_.getIndex() + 1;
               _loc3_ = true;
            }
         }
      }
      if(!_loc3_)
      {
         toggleUIList[param1].setSelected(true);
         return;
      }
      toggleUIList[param1].setSelect(true);
      if(callback)
      {
         callback(_loc4_);
      }
   }
   
   public function dispose() : void
   {
      displaySprite = null;
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
import gudetama.engine.SoundManager;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ToggleUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var index:int;
   
   private var button:ToggleButton;
   
   private var text:ColorTextField;
   
   function ToggleUI(param1:Sprite, param2:Function, param3:int, param4:ToggleGroup, param5:Boolean)
   {
      super(param1);
      this.callback = param2;
      this.index = param3;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      button.toggleGroup = param4;
      setSelected(param5);
      button.addEventListener("custom",chageEvent);
      text = param1.getChildByName("colorTextField") as ColorTextField;
   }
   
   public function setupWide(param1:TaskQueue) : void
   {
      var queue:TaskQueue = param1;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("profile0@btn_off",function(param1:Texture):void
         {
            button.defaultTexture = param1;
            button.width = param1.width;
            button.height = param1.height;
            text.width = param1.width;
            queue.taskDone();
         });
      });
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("profile0@btn_on",function(param1:Texture):void
         {
            button.selectedTexture = param1;
            queue.taskDone();
         });
      });
   }
   
   public function setSelect(param1:Boolean) : void
   {
      text.color = !!button.isSelected ? 5521974 : 16777215;
   }
   
   public function setSelected(param1:Boolean) : void
   {
      button.isSelectedWithOutCustomEvent = param1;
   }
   
   public function isSelected() : Boolean
   {
      return button.isSelected;
   }
   
   public function getIndex() : int
   {
      return index;
   }
   
   private function triggered(param1:Event) : void
   {
      if(callback)
      {
         callback(index);
      }
   }
   
   private function chageEvent() : void
   {
      if(isSelected())
      {
         SoundManager.playEffect("btn_normal");
      }
      if(callback)
      {
         callback(index);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      text = null;
   }
}
