package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.AvatarDef;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.DecorationDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.SetItemDef;
   import gudetama.data.compati.StampDef;
   import gudetama.data.compati.UsefulDef;
   import gudetama.data.compati.UtensilDef;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class ItemShopDialog_Gudetama extends ChargeDialogBase
   {
      
      private static const DEFALUT_RENDERER_ID:String = "defaultRenderer";
      
      private static const AVATAR_RENDERER_ID:String = "avatarRenderer";
      
      private static const DECO_RENDERER_ID:String = "decoRenderer";
      
      private static const STAMP_RENDERER_ID:String = "stampRenderer";
      
      private static const USEFUL_RENDERER_ID:String = "usefulRenderer";
      
      private static const UTENSIL_RENDERER_ID:String = "utensilRenderer";
      
      private static const CUPGACHA_RENDERER_ID:String = "cupGachaRenderer";
      
      private static const SETITEM_RENDERER_ID:String = "setitemRenderer";
       
      
      private const hasTitleImageTypes:Array = [2,3,4,5,6,8];
      
      private var itemType:int;
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var decorationExtractor:SpriteExtractor;
      
      private var setItemExtractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var loadCount:int;
      
      private var currentSetItem:SetItemDef = null;
      
      private var setItems:Array = null;
      
      private var moveToId:int = -1;
      
      public function ItemShopDialog_Gudetama(param1:int, param2:int)
      {
         collection = collection = new ListCollection();
         super(2);
         this.itemType = param1;
         chargeType = 3;
         moveToId = param2;
      }
      
      public static function show(param1:int, param2:int = -1) : void
      {
         Engine.pushScene(new ItemShopDialog_Gudetama(param1,param2),0,false);
      }
      
      private static function capGachaDataComparator(param1:CupGachaDef, param2:CupGachaDef) : Number
      {
         if(param1.sortIndex > param2.sortIndex)
         {
            return 1;
         }
         if(param1.sortIndex < param2.sortIndex)
         {
            return -1;
         }
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
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"ItemShopDialog_Gudetama",function(param1:Object):void
         {
            var _loc4_:int = 0;
            var _loc5_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object as Sprite;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < hasTitleImageTypes.length)
            {
               _loc5_ = hasTitleImageTypes[_loc4_];
               _loc2_ = _loc3_.getChildByName("title" + _loc5_) as Image;
               _loc2_.visible = itemType == _loc5_;
               _loc4_++;
            }
            list = _loc3_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_ItemShopListItem_Gudetama",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_DecorationShopListItem",function(param1:Object):void
         {
            decorationExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setItems = getEnbaleSetItems();
         if(setItems != null)
         {
            setupLayoutForTask(queue,"_SetItemUI",function(param1:Object):void
            {
               setItemExtractor = SpriteExtractor.forGross(param1.object,param1);
            });
         }
         if(itemType == 4)
         {
            preloadDecorationImages();
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
      }
      
      private function getEnbaleSetItems() : Array
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         if(itemType == 3)
         {
            _loc4_ = 1;
         }
         var _loc1_:Array = null;
         var _loc6_:Object = GameSetting.def.setItemMap;
         var _loc2_:int = TimeZoneUtil.epochMillisToOffsetSecs();
         for(var _loc5_ in _loc6_)
         {
            _loc3_ = _loc6_[_loc5_];
            if(_loc3_.inTerm(_loc2_))
            {
               if(_loc3_.chargeItem != null)
               {
                  if(_loc3_.viewType == _loc4_)
                  {
                     if(_loc1_ == null)
                     {
                        _loc1_ = [];
                     }
                     _loc1_.push(_loc3_);
                  }
               }
            }
         }
         return _loc1_;
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
      
      private function preloadDecorationImages() : void
      {
         var _loc1_:* = null;
         var _loc2_:Object = GameSetting.getDecorationMap();
         for(var _loc3_ in _loc2_)
         {
            _loc1_ = _loc2_[_loc3_] as DecorationDef;
            if(!(!_loc1_.name#2 || _loc1_.name#2 == "" || !_loc1_.price))
            {
               _preloadDecorationImage(_loc3_);
            }
         }
      }
      
      private function _preloadDecorationImage(param1:int) : void
      {
         var id:int = param1;
         loadCount++;
         queue.addTask(function():void
         {
            var iconName:String = GudetamaUtil.getItemImageName(9,id);
            TextureCollector.loadTexture(iconName,function(param1:Texture):void
            {
               loadCount--;
               checkInit();
               queue.taskDone();
            });
         });
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
         layout.horizontalGap = 8;
         layout.verticalGap = 28;
         layout.paddingTop = 10;
         layout.paddingLeft = 23;
         layout.paddingBottom = 20;
         list.layout = layout;
         list.factoryIDFunction = function(param1:Object):String
         {
            if(!param1 || !param1.hasOwnProperty("def"))
            {
               return "defaultRenderer";
            }
            if(param1.def is AvatarDef)
            {
               return "avatarRenderer";
            }
            if(param1.def is DecorationDef)
            {
               return "decoRenderer";
            }
            if(param1.def is StampDef)
            {
               return "stampRenderer";
            }
            if(param1.def is UsefulDef)
            {
               return "usefulRenderer";
            }
            if(param1.def is UtensilDef)
            {
               return "utensilRenderer";
            }
            if(param1.def is SetItemDef)
            {
               return "setitemRenderer";
            }
            if(param1.def is CupGachaDef)
            {
               return "cupGachaRenderer";
            }
            return "defaultRenderer";
         };
         list.setItemRendererFactoryWithID("defaultRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(extractor,GoodsItemUI,processPurchaseItem);
         });
         list.setItemRendererFactoryWithID("avatarRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(extractor,AvatarItemUI,processPurchaseItem);
         });
         list.setItemRendererFactoryWithID("decoRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(decorationExtractor,DecoItemUI,processPurchaseItem);
         });
         list.setItemRendererFactoryWithID("stampRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(extractor,StampItemUI,processPurchaseItem);
         });
         list.setItemRendererFactoryWithID("usefulRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(extractor,UsefulItemUI,processPurchaseItem);
         });
         list.setItemRendererFactoryWithID("utensilRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(extractor,UtensilItemUI,processPurchaseItem);
         });
         list.setItemRendererFactoryWithID("cupGachaRenderer",function():IListItemRenderer
         {
            return new GoodsItemListRenderer(extractor,CupGachaItemUI,processPurchaseItem);
         });
         if(setItemExtractor != null)
         {
            list.setItemRendererFactoryWithID("setitemRenderer",function():IListItemRenderer
            {
               return new SetItemUIRenderer(setItemExtractor,processBuySetItem);
            });
         }
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
         list.typicalItem = new GoodsItemUI(extractor.duplicateAll() as Sprite,null);
         setup();
      }
      
      private function setup() : void
      {
         if(setItems == null)
         {
            makeList();
            return;
         }
         var productIds:Array = [];
         priceMap = {};
         var i:int = 0;
         while(i < setItems.length)
         {
            var setItem:SetItemDef = setItems[i];
            productIds.push(setItem.chargeItem.product_id);
            if(debug)
            {
               priceMap[setItem.chargeItem.product_id] = setItem.chargeItem.price;
            }
            i++;
         }
         if(debug)
         {
            makeList();
            return;
         }
         queue.addTask(function():void
         {
            var _loc1_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               var extEnabled:Boolean = NativeExtensions.requestPriceList(productIds,function(param1:int, param2:String):void
               {
                  var _loc3_:* = null;
                  var _loc5_:* = null;
                  if(param1 >= 0)
                  {
                     param2 = param2.substring(1);
                     _loc3_ = param2.split("/");
                     for each(var _loc4_ in _loc3_)
                     {
                        _loc5_ = _loc4_.split(":");
                        priceMap[_loc5_[0]] = _loc5_[1];
                     }
                     makeList();
                  }
                  else
                  {
                     MessageDialog.show(10,GameSetting.getUIText("pricelist.error." + Math.abs(param1)),null);
                  }
                  queue.taskDone();
               });
               if(!extEnabled)
               {
                  queue.taskDone();
               }
            }
            else
            {
               var _loc3_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  var buillingEnabled:Boolean = NativeExtensions.requestPriceList(productIds,function(param1:int, param2:Array):void
                  {
                     var _loc3_:* = null;
                     var _loc4_:int = 0;
                     var _loc5_:* = null;
                     if(param1 >= 0)
                     {
                        _loc3_ = null;
                        _loc4_ = 0;
                        while(_loc4_ < param2.length)
                        {
                           _loc3_ = param2[_loc4_];
                           if(_loc3_ != null)
                           {
                              _loc5_ = _loc3_.split(":");
                              priceMap[_loc5_[0]] = _loc5_[1];
                           }
                           _loc4_++;
                        }
                        makeList();
                     }
                     else
                     {
                        MessageDialog.show(10,GameSetting.getUIText("pricelist.error." + Math.abs(param1)),null);
                     }
                     queue.taskDone();
                  });
                  if(!buillingEnabled)
                  {
                     queue.taskDone();
                  }
               }
            }
         });
      }
      
      private function scrollComplete(param1:Event = null) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:int = 0;
         _loc2_ = list.getChildAt(0) as ListDataViewPort;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.numChildren)
         {
            _loc3_ = _loc2_.getChildAt(_loc4_) as GoodsItemListRenderer;
            if(_loc3_)
            {
               _loc3_.update();
            }
            _loc4_++;
         }
      }
      
      override protected function makeList() : void
      {
         var _loc10_:* = null;
         var _loc12_:* = 0;
         var _loc9_:* = null;
         var _loc2_:* = null;
         var _loc7_:* = null;
         var _loc8_:* = null;
         var _loc11_:* = null;
         var _loc1_:* = null;
         var _loc4_:* = null;
         var _loc3_:* = null;
         var _loc6_:* = null;
         var _loc5_:* = null;
         collection.removeAll();
         checkSetItem(true);
         if(itemType == 5)
         {
            _loc10_ = GameSetting.getAvatarMap();
            for(_loc12_ in _loc10_)
            {
               if(!(!(_loc9_ = _loc10_[_loc12_] as AvatarDef).name#2 || _loc9_.name#2 == "" || !_loc9_.price))
               {
                  collection.addItem({"def":_loc9_});
               }
            }
         }
         else if(itemType == 4)
         {
            _loc10_ = GameSetting.getDecorationMap();
            for(_loc12_ in _loc10_)
            {
               _loc2_ = _loc10_[_loc12_] as DecorationDef;
               if(!(!_loc2_.name#2 || _loc2_.name#2 == "" || !_loc2_.price))
               {
                  collection.addItem({"def":_loc2_});
               }
            }
         }
         else if(itemType == 6)
         {
            _loc10_ = GameSetting.getStampMap();
            for(_loc12_ in _loc10_)
            {
               if(!(!(_loc7_ = _loc10_[_loc12_] as StampDef).name#2 || _loc7_.name#2 == "" || !_loc7_.price))
               {
                  collection.addItem({"def":_loc7_});
               }
            }
         }
         else if(itemType == 3)
         {
            _loc10_ = GameSetting.getUsefulMap();
            _loc8_ = [];
            for(_loc12_ in _loc10_)
            {
               if(!(!(_loc11_ = _loc10_[_loc12_] as UsefulDef).name#2 || _loc11_.name#2 == "" || !_loc11_.price))
               {
                  if(!(_loc11_.eventId > 0 && !UserDataWrapper.eventPart.isRunningEvent(_loc11_.eventId)))
                  {
                     _loc8_.push(_loc11_);
                  }
               }
            }
            _loc8_.sort(ascendingIdComparator);
            for each(_loc11_ in _loc8_)
            {
               collection.addItem({"def":_loc11_});
            }
         }
         else if(itemType == 2)
         {
            _loc10_ = GameSetting.getUtensilMap();
            for(_loc12_ in _loc10_)
            {
               _loc1_ = _loc10_[_loc12_] as UtensilDef;
               if(!(!_loc1_.name#2 || _loc1_.name#2 == "" || !_loc1_.price))
               {
                  collection.addItem({"def":_loc1_});
               }
            }
         }
         else if(itemType == 8)
         {
            _loc4_ = [];
            _loc3_ = [];
            _loc10_ = GameSetting.def.cupGachaMap;
            for(_loc12_ in _loc10_)
            {
               _loc6_ = _loc10_[_loc12_] as CupGachaDef;
               if(!(!checkAddCupGacha(_loc6_) || !_loc6_.name#2 || _loc6_.name#2 == "" || !_loc6_.price))
               {
                  if(_loc6_.sortIndex > -1)
                  {
                     _loc3_.push(_loc6_);
                  }
                  else
                  {
                     _loc4_.push(_loc6_);
                  }
               }
            }
            _loc3_.sort(capGachaDataComparator);
            _loc4_.sort(capGachaDataComparator);
            for each(_loc5_ in _loc3_)
            {
               collection.addItem({"def":_loc5_});
            }
            _loc5_ = null;
            for each(_loc5_ in _loc4_)
            {
               collection.addItem({"def":_loc5_});
            }
         }
         checkSetItem(false);
      }
      
      private function checkAddCupGacha(param1:CupGachaDef) : Boolean
      {
         var _loc2_:Array = param1.enableCountryFlags;
         if(!_loc2_)
         {
            return true;
         }
         return _loc2_.indexOf(Engine.getCountryCode()) >= 0;
      }
      
      private function checkSetItem(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(setItems == null)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < setItems.length)
         {
            _loc3_ = setItems[_loc2_];
            if(UserDataWrapper.wrapper.isBuyableSetItem(_loc3_) == param1)
            {
               collection.addItem(makeSetItemData(_loc3_,!!priceMap ? priceMap[_loc3_.chargeItem.product_id] : null));
            }
            _loc2_++;
         }
      }
      
      private function makeSetItemData(param1:SetItemDef, param2:String) : Object
      {
         var _loc3_:Object = {};
         var _loc4_:Array = getPrice(param1.chargeItem,param2);
         _loc3_["def"] = param1;
         _loc3_["price"] = _loc4_[0];
         _loc3_["mark"] = _loc4_[1];
         return _loc3_;
      }
      
      private function ascendingIdComparator(param1:Object, param2:Object) : Number
      {
         if(param1.sortIndex > param2.sortIndex)
         {
            return -1;
         }
         if(param1.sortIndex < param2.sortIndex)
         {
            return 1;
         }
         if(param1.id > param2.id)
         {
            return 1;
         }
         if(param1.id < param2.id)
         {
            return -1;
         }
         return 0;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(ItemShopDialog_Gudetama);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
         if(Engine.getGuideTalkPanel())
         {
            setVisibleState(70);
            list.verticalScrollPolicy = "off";
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         if(moveToId != -1)
         {
            var innerQueue:TaskQueue = new TaskQueue();
            if(itemType == 3)
            {
               var i:int = 0;
               while(i < collection.length)
               {
                  var tmpuseful:UsefulDef = collection.getItemAt(i).def as UsefulDef;
                  if(tmpuseful)
                  {
                     loadTexture(8,tmpuseful.rsrc,innerQueue);
                  }
                  i++;
               }
            }
            innerQueue.registerOnProgress(function(param1:Number):void
            {
               var _loc2_:int = 0;
               var _loc3_:* = null;
               var _loc4_:* = null;
               if(param1 < 1)
               {
                  return;
               }
               if(itemType == 3)
               {
                  _loc2_ = 0;
                  while(_loc2_ < collection.length)
                  {
                     _loc3_ = collection.getItemAt(_loc2_).def as UsefulDef;
                     if(_loc3_)
                     {
                        if(_loc3_.id#2 == moveToId)
                        {
                           list.selectedItem = collection.getItemAt(_loc2_);
                           list.scrollToDisplayIndex(_loc2_);
                           break;
                        }
                     }
                     if(_loc4_ = collection.getItemAt(_loc2_).def as SetItemDef)
                     {
                        if(_loc4_.id#2 == moveToId)
                        {
                           list.selectedItem = collection.getItemAt(_loc2_);
                           list.scrollToDisplayIndex(_loc2_);
                           break;
                        }
                     }
                     _loc2_++;
                  }
               }
               _transitionOpenFinished();
            });
            innerQueue.startTask();
         }
         else
         {
            _transitionOpenFinished();
         }
      }
      
      private function _transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            var _loc1_:* = null;
            var _loc3_:* = null;
            var _loc2_:* = 0;
            var _loc4_:* = 0;
            Engine.resumeGuideTalk(noticeTutorialAction,getGuideArrowPos);
            if(Engine.getGuideTalkPanel())
            {
               _loc1_ = list.getChildAt(0) as ListDataViewPort;
               _loc2_ = uint(_loc1_.numChildren);
               _loc4_ = uint(0);
               while(_loc4_ < _loc2_)
               {
                  _loc3_ = _loc1_.getChildAt(_loc4_) as GoodsItemListRenderer;
                  if(_loc3_ && !_loc3_.isPictureBook())
                  {
                     _loc3_.setTouchableItem(false);
                  }
                  _loc4_++;
               }
            }
            Engine.unlockTouchInput(ItemShopDialog_Gudetama);
         });
      }
      
      private function loadTexture(param1:int, param2:int, param3:TaskQueue) : void
      {
         var _kind:int = param1;
         var _id:int = param2;
         var _queue:TaskQueue = param3;
         _queue.addTask(function():void
         {
            var iconName:String = GudetamaUtil.getItemIconName(_kind,_id);
            TextureCollector.loadTexture(iconName,function(param1:Texture):void
            {
               _queue.taskDone();
            });
         });
      }
      
      public function noticeTutorialAction(param1:int) : void
      {
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         switch(int(param1))
         {
            case 0:
               list.verticalScrollPolicy = "auto";
               setVisibleState(94);
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               _loc3_ = uint(_loc2_.numChildren);
               _loc5_ = uint(0);
               while(_loc5_ < _loc3_)
               {
                  if(!(_loc4_ = _loc2_.getChildAt(_loc5_) as GoodsItemListRenderer).isPictureBook())
                  {
                     _loc4_.setTouchableItem(true);
                  }
                  _loc5_++;
               }
               break;
            case 1:
               list.scrollToDisplayIndex(3 - 1,0.5);
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc4_:* = undefined;
         var _loc2_:* = null;
         var _loc5_:* = null;
         var _loc3_:* = 0;
         var _loc6_:* = 0;
         switch(int(param1) - 1)
         {
            case 0:
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               _loc3_ = uint(_loc2_.numChildren);
               _loc6_ = uint(0);
               while(_loc6_ < _loc3_)
               {
                  if((_loc5_ = _loc2_.getChildAt(_loc6_) as GoodsItemListRenderer).isPictureBook())
                  {
                     _loc4_ = _loc5_.getSpritePos();
                  }
                  _loc6_++;
               }
               return _loc4_;
            case 1:
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               _loc3_ = uint(_loc2_.numChildren);
               _loc6_ = uint(0);
               while(_loc6_ < _loc3_)
               {
                  if((_loc5_ = _loc2_.getChildAt(_loc6_) as GoodsItemListRenderer).isTimingPlate())
                  {
                     _loc4_ = _loc5_.getSpritePos();
                  }
                  _loc6_++;
               }
               return _loc4_;
            case 2:
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               _loc3_ = uint(_loc2_.numChildren);
               _loc6_ = uint(0);
               while(_loc6_ < _loc3_)
               {
                  if((_loc5_ = _loc2_.getChildAt(_loc6_) as GoodsItemListRenderer).isMicrowave())
                  {
                     _loc4_ = _loc5_.getSpritePos();
                  }
                  _loc6_++;
               }
               return _loc4_;
            default:
               return _loc4_;
         }
      }
      
      override protected function removedPushedSceneFromContainer(param1:Event) : void
      {
         var _loc2_:Boolean = resumeNoticeTutorial(2,noticeTutorialAction);
         if(!_loc2_)
         {
            processManualStopInfomation();
         }
         super.removedPushedSceneFromContainer(param1);
      }
      
      private function processManualStopInfomation() : void
      {
         if(UserDataWrapper.featurePart.existsFeature(2) && UserDataWrapper.wrapper.isCanStartNoticeFlag(16))
         {
            processNoticeTutorial(16,null,null);
         }
      }
      
      private function processPurchaseItem(param1:ItemParam, param2:GoodsItemUI) : void
      {
         var item:ItemParam = param1;
         var itemUI:GoodsItemUI = param2;
         if(item.kind == 9)
         {
            DecorationPurchaseDialog.show(item,function():void
            {
               itemUI.updateView();
            });
         }
         else
         {
            PurchaseShopDialog.show(item,function():void
            {
               if(itemUI is UtensilItemUI)
               {
                  collection.updateAll();
               }
               else
               {
                  itemUI.updateView();
               }
            });
         }
      }
      
      private function processBuySetItem(param1:SetItemDef) : void
      {
         var setItem:SetItemDef = param1;
         if(!setItem.inTerm(TimeZoneUtil.epochMillisToOffsetSecs()))
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("setitem.term.out"),function():void
            {
               setItems = getEnbaleSetItems();
               makeList();
            });
            return;
         }
         if(!UserDataWrapper.wrapper.isBuyableSetItem(setItem))
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("setitem.not.buyable"),function():void
            {
               makeList();
            });
            return;
         }
         currentSetItem = setItem;
         purchase(setItem.chargeItem);
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         super.backButtonCallback();
         Engine.lockTouchInput(ItemShopDialog_Gudetama);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ItemShopDialog_Gudetama);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         list = null;
         extractor = null;
         decorationExtractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.common.GudetamaUtil;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class GoodsItemListRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var goodsClass:Class;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var item:GoodsItemUI;
   
   function GoodsItemListRenderer(param1:SpriteExtractor, param2:Class, param3:Function)
   {
      super();
      this.extractor = param1;
      this.goodsClass = param2;
      this.callback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      item = new goodsClass(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      item.updateData(data#2);
   }
   
   public function isPictureBook() : Boolean
   {
      var _loc1_:UtensilItemUI = item as UtensilItemUI;
      if(_loc1_)
      {
         return _loc1_.isPictureBook();
      }
      return false;
   }
   
   public function isTimingPlate() : Boolean
   {
      var _loc1_:UtensilItemUI = item as UtensilItemUI;
      if(_loc1_)
      {
         return _loc1_.isTimingPlate();
      }
      return false;
   }
   
   public function isMicrowave() : Boolean
   {
      var _loc1_:UtensilItemUI = item as UtensilItemUI;
      if(_loc1_)
      {
         return _loc1_.isMicrowave();
      }
      return false;
   }
   
   public function setTouchableItem(param1:Boolean) : void
   {
      item.setTouchable(param1);
   }
   
   public function getSpritePos() : Vector.<Number>
   {
      return GudetamaUtil.getCenterPosAndWHOnEngine(displaySprite);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      goodsClass = null;
      callback = null;
      displaySprite = null;
      if(item)
      {
         item.dispose();
         item = null;
      }
      super.dispose();
   }
   
   public function update() : void
   {
      item.updateData(data#2);
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class GoodsItemUI extends UIBase
{
   
   protected static const UPDATE_INTERVAL:int = 1000;
    
   
   private var callback:Function;
   
   protected var button:ContainerButton;
   
   protected var itemIconImage:Image;
   
   protected var itemNameText:ColorTextField;
   
   protected var itemNumText:ColorTextField;
   
   protected var itemNumMat:Image;
   
   protected var priceIconImage:Image;
   
   protected var priceNumText:ColorTextField;
   
   protected var newIcon:Image;
   
   protected var disableImage:Image;
   
   protected var lock:Image;
   
   protected var sumi:Image;
   
   protected var param:ItemParam;
   
   protected var purchasable:Boolean = true;
   
   protected var iconName:String;
   
   protected var _def;
   
   protected var limitSprite:Sprite;
   
   protected var limitText:ColorTextField;
   
   function GoodsItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("itemContainer") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      itemIconImage = button.getChildByName("itemIcon") as Image;
      itemNameText = button.getChildByName("itemName") as ColorTextField;
      itemNumMat = button.getChildByName("itemNumMat") as Image;
      itemNumText = button.getChildByName("itemNum") as ColorTextField;
      priceIconImage = button.getChildByName("priceIcon") as Image;
      priceNumText = button.getChildByName("price") as ColorTextField;
      newIcon = button.getChildByName("new") as Image;
      disableImage = button.getChildByName("disable") as Image;
      lock = button.getChildByName("lock") as Image;
      sumi = button.getChildByName("sumi") as Image;
      sumi.x = (button.width - sumi.width) / 2;
      param = new ItemParam();
      param.num = 1;
      limitSprite = button.getChildByName("kounyuuzikan") as Sprite;
      if(limitSprite)
      {
         limitText = limitSprite.getChildByName("moji") as ColorTextField;
         limitSprite.visible = false;
      }
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
   }
   
   public function updateView() : void
   {
   }
   
   protected function loadItemIcon(param1:int, param2:int) : void
   {
      var kind:int = param1;
      var id:int = param2;
      var iconName:String = GudetamaUtil.getItemIconName(kind,id);
      if(iconName == this.iconName)
      {
         return;
      }
      itemIconImage.visible = false;
      TextureCollector.loadTexture(iconName,function(param1:Texture):void
      {
         if(itemIconImage == null)
         {
            return;
         }
         itemIconImage.texture = param1;
         itemIconImage.visible = true;
      });
      this.iconName = iconName;
   }
   
   private function loadItemIconCallback(param1:Texture) : void
   {
      if(itemIconImage == null)
      {
         return;
      }
      itemIconImage.texture = param1;
      itemIconImage.visible = true;
   }
   
   protected function updatePrice(param1:ItemParam, param2:Boolean) : void
   {
      var price:ItemParam = param1;
      var purchasable:Boolean = param2;
      if(!price)
      {
         return;
      }
      var num:int = price.num > -1 ? price.num : 0;
      priceNumText.text#2 = StringUtil.getNumStringCommas(num);
      if(price.kind == 1 || price.kind == 2)
      {
         TextureCollector.loadTexture("home1@goldegg",function(param1:Texture):void
         {
            if(priceIconImage != null)
            {
               priceIconImage.texture = param1;
            }
         });
         priceNumText.color = 9265969;
      }
      else if(price.kind == 0 || price.kind == 14)
      {
         TextureCollector.loadTexture("home1@gp",function(param1:Texture):void
         {
            if(priceIconImage != null)
            {
               priceIconImage.texture = param1;
            }
         });
         priceNumText.color = 6252140;
      }
   }
   
   protected function triggeredButton(param1:Event) : void
   {
      callback(param,this);
   }
   
   public function dispose() : void
   {
      callback = null;
      if(button)
      {
         button.removeEventListener("triggered",triggeredButton);
         button = null;
      }
      itemIconImage = null;
      itemNameText = null;
      itemNumText = null;
      itemNumMat = null;
      priceIconImage = null;
      priceNumText = null;
      newIcon = null;
      disableImage = null;
      lock = null;
      sumi = null;
      param = null;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.AvatarDef;
import starling.display.Sprite;

class AvatarItemUI extends GoodsItemUI
{
    
   
   function AvatarItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
   }
   
   override public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      _def = param1.def;
      updateView();
   }
   
   override public function updateView() : void
   {
      var _loc2_:AvatarDef = _def as AvatarDef;
      var _loc1_:int = _loc2_.id#2;
      param.id#2 = _loc1_;
      param.kind = 12;
      var _loc4_:Boolean = UserDataWrapper.avatarPart.hasAvatar(_loc1_);
      var _loc3_:Boolean = UserDataWrapper.avatarPart.isAvailable(_loc1_);
      itemNameText.text#2 = _loc2_.name#2;
      itemNumMat.visible = false;
      itemNumText.text#2 = "";
      newIcon.visible = _loc2_.isNew;
      disableImage.visible = _loc4_ || !_loc3_;
      lock.visible = !_loc3_;
      sumi.visible = _loc4_;
      updatePrice(_loc2_.price,purchasable);
      loadItemIcon(12,_loc2_.rsrc);
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.DecorationDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.util.StringUtil;
import starling.display.Sprite;
import starling.textures.Texture;

class DecoItemUI extends GoodsItemUI
{
    
   
   function DecoItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
   }
   
   override public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      _def = param1.def;
      updateView();
   }
   
   override public function updateView() : void
   {
      var _loc2_:DecorationDef = _def as DecorationDef;
      var _loc1_:int = _loc2_.id#2;
      param.id#2 = _loc1_;
      param.kind = 9;
      var _loc4_:Boolean = UserDataWrapper.decorationPart.hasDecoration(_loc1_);
      var _loc3_:Boolean = UserDataWrapper.decorationPart.isAvailable(_loc1_);
      itemNameText.text#2 = _loc2_.name#2;
      newIcon.visible = _loc2_.isNew;
      disableImage.visible = _loc4_ || !_loc3_;
      lock.visible = !_loc3_;
      sumi.visible = _loc4_;
      updatePrice(_loc2_.price,purchasable);
      loadItemIcon(9,_loc2_.rsrc);
   }
   
   override protected function updatePrice(param1:ItemParam, param2:Boolean) : void
   {
      if(!param1)
      {
         return;
      }
      priceNumText.text#2 = StringUtil.getNumStringCommas(param1.num);
      if(param1.kind == 1 || param1.kind == 2)
      {
         startTween("metal");
      }
      else
      {
         startTween("money");
      }
      finishTween();
   }
   
   override protected function loadItemIcon(param1:int, param2:int) : void
   {
      var kind:int = param1;
      var id:int = param2;
      var iconName:String = GudetamaUtil.getItemImageName(kind,id);
      if(iconName == this.iconName)
      {
         return;
      }
      itemIconImage.visible = false;
      TextureCollector.loadTexture(iconName,function(param1:Texture):void
      {
         if(!itemIconImage)
         {
            return;
         }
         itemIconImage.texture = param1;
         itemIconImage.visible = true;
      });
      this.iconName = iconName;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.StampDef;
import starling.display.Sprite;

class StampItemUI extends GoodsItemUI
{
    
   
   function StampItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
   }
   
   override public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      _def = param1.def;
      updateView();
   }
   
   override public function updateView() : void
   {
      var _loc2_:StampDef = _def as StampDef;
      var _loc1_:int = _loc2_.id#2;
      param.id#2 = _loc1_;
      param.kind = 11;
      var _loc3_:Boolean = UserDataWrapper.stampPart.isStampAddable(param);
      var _loc4_:Boolean = UserDataWrapper.stampPart.isAvailable(_loc1_);
      var _loc5_:int = UserDataWrapper.stampPart.getNumStamp(_loc1_);
      itemNameText.text#2 = _loc2_.name#2;
      itemNumText.text#2 = "" + _loc5_;
      newIcon.visible = _loc2_.isNew;
      disableImage.visible = !_loc3_ || !_loc4_;
      lock.visible = !_loc4_;
      sumi.visible = !_loc3_;
      updatePrice(_loc2_.price,purchasable);
      loadItemIcon(11,_loc2_.rsrc);
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UsefulData;
import gudetama.data.compati.UsefulDef;
import gudetama.engine.Engine;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;

class UsefulItemUI extends GoodsItemUI
{
    
   
   private var def:UsefulDef;
   
   private var nextUpdateTime:int;
   
   private var lastRestSec:int = 0;
   
   function UsefulItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
   }
   
   override public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      _def = param1.def;
      updateView();
   }
   
   override public function updateView() : void
   {
      limitSprite.visible = false;
      def = _def as UsefulDef;
      var _loc1_:int = def.id#2;
      param.id#2 = _loc1_;
      param.kind = 8;
      var _loc2_:Boolean = UserDataWrapper.usefulPart.isUsefulAddable(param);
      var _loc3_:Boolean = UserDataWrapper.usefulPart.isAvailable(_loc1_);
      var _loc4_:int = UserDataWrapper.usefulPart.getNumUseful(_loc1_);
      itemNameText.text#2 = def.name#2;
      itemNumText.text#2 = "" + _loc4_;
      newIcon.visible = def.isNew;
      disableImage.visible = !_loc2_ || !_loc3_;
      lock.visible = !_loc3_;
      sumi.visible = !_loc2_;
      updatePrice(def.price,purchasable);
      loadItemIcon(8,def.rsrc);
      updateLimitTime();
   }
   
   private function updateLimitTime() : void
   {
      var _loc1_:int = 0;
      var _loc2_:UsefulData = UserDataWrapper.usefulPart.getUseful(def.id#2);
      if(_loc2_.nextAvailablePurchaseSec != -1)
      {
         displaySprite.addEventListener("enterFrame",onEnterFrame);
         _loc1_ = Math.max(0,_loc2_.nextAvailablePurchaseSec - TimeZoneUtil.epochMillisToOffsetSecs());
         if(_loc1_ > 0)
         {
            limitText.text#2 = StringUtil.format(GameSetting.getUIText("common.msg.limit"),TimeZoneUtil.getRestTimeText(_loc1_));
            limitSprite.visible = true;
            disableImage.visible = true;
         }
      }
      else
      {
         displaySprite.removeEventListener("enterFrame",onEnterFrame);
      }
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
      if(Engine.now < nextUpdateTime)
      {
         return;
      }
      updateLimitTime();
      nextUpdateTime = Engine.now + 1000;
   }
   
   override public function dispose() : void
   {
      displaySprite.removeEventListener("enterFrame",onEnterFrame);
      super.dispose();
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.UtensilDef;
import starling.display.Sprite;

class UtensilItemUI extends GoodsItemUI
{
    
   
   function UtensilItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
   }
   
   override public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      _def = param1.def;
      updateView();
   }
   
   override public function updateView() : void
   {
      var _loc2_:UtensilDef = _def as UtensilDef;
      var _loc1_:int = _loc2_.id#2;
      param.id#2 = _loc1_;
      param.kind = 10;
      var _loc4_:Boolean = UserDataWrapper.utensilPart.hasUtensil(_loc1_);
      var _loc3_:Boolean = UserDataWrapper.utensilPart.isAvailable(_loc1_);
      if(!checkPriceLimit(_loc2_.price))
      {
         _loc3_ = true;
         _loc4_ = true;
      }
      itemNameText.text#2 = _loc2_.name#2;
      itemNumMat.visible = false;
      itemNumText.text#2 = "";
      newIcon.visible = _loc2_.isNew;
      disableImage.visible = _loc4_ || !_loc3_;
      lock.visible = !_loc3_;
      sumi.visible = _loc4_;
      updatePrice(_loc2_.price,purchasable);
      loadItemIcon(10,_loc2_.rsrc);
   }
   
   private function checkPriceLimit(param1:ItemParam) : Boolean
   {
      if(param1.kind == 1 || param1.kind == 2 || param1.kind == 0 || param1.kind == 14)
      {
         return param1.num > -1;
      }
      return true;
   }
   
   public function isPictureBook() : Boolean
   {
      return param.id#2 == 1;
   }
   
   public function isTimingPlate() : Boolean
   {
      return param.id#2 == 3;
   }
   
   public function isMicrowave() : Boolean
   {
      return param.id#2 == 4;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.CupGachaDef;
import starling.display.Sprite;

class CupGachaItemUI extends GoodsItemUI
{
    
   
   function CupGachaItemUI(param1:Sprite, param2:Function)
   {
      super(param1,param2);
   }
   
   override public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      _def = param1.def;
      updateView();
   }
   
   override public function updateView() : void
   {
      var _loc2_:CupGachaDef = _def as CupGachaDef;
      var _loc1_:int = _loc2_.id#2;
      param.id#2 = _loc1_;
      param.kind = 19;
      var _loc5_:UserDataWrapper;
      var _loc3_:Boolean = (_loc5_ = UserDataWrapper.wrapper).canAddCupGacha(_loc1_);
      var _loc4_:Boolean = _loc5_.isAvailableCupGacha(_loc1_);
      itemNameText.text#2 = _loc2_.name#2;
      itemNumMat.visible = false;
      itemNumText.text#2 = "";
      newIcon.visible = _loc2_.isNew;
      disableImage.visible = !_loc3_ || !_loc4_;
      lock.visible = !_loc4_;
      sumi.visible = false;
      updatePrice(_loc2_.price,purchasable);
      loadItemIcon(19,_loc2_.id#2);
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class SetItemUIRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:SetItemUI;
   
   function SetItemUIRenderer(param1:SpriteExtractor, param2:Function)
   {
      super(param1,param2);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new SetItemUI(displaySprite,callback);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.SetItemDef;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.ui.ItemsShowDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class SetItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var setItemDef:SetItemDef;
   
   private var bannerImage:Image;
   
   private var buyBtn:ContainerButton;
   
   private var detailBtn:ContainerButton;
   
   private var maxText:ColorTextField;
   
   private var priceText:ColorTextField;
   
   private var bonusSprite:Sprite;
   
   private var labelText:ColorTextField;
   
   private var descText:ColorTextField;
   
   function SetItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      bannerImage = param1.getChildByName("banner") as Image;
      buyBtn = param1.getChildByName("buyBtn") as ContainerButton;
      buyBtn.addEventListener("triggered",triggeredBuyBtn);
      detailBtn = param1.getChildByName("detailBtn") as ContainerButton;
      detailBtn.addEventListener("triggered",triggeredDetailBtn);
      priceText = param1.getChildByName("price") as ColorTextField;
      bonusSprite = param1.getChildByName("bonusSprite") as Sprite;
      labelText = bonusSprite.getChildByName("label") as ColorTextField;
      descText = param1.getChildByName("desc") as ColorTextField;
   }
   
   private function triggeredBuyBtn(param1:Event) : void
   {
      callback(setItemDef);
   }
   
   private function triggeredDetailBtn(param1:Event) : void
   {
      ItemsShowDialog.show(setItemDef.items,null,GameSetting.getUIText("common.msg.getitems"),GameSetting.getUIText("%common.detail"));
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      setItemDef = data.def as SetItemDef;
      TextureCollector.loadTexture("shop0@banner" + setItemDef.rsrc,function(param1:Texture):void
      {
         if(bannerImage != null)
         {
            bannerImage.texture = param1;
         }
      });
      if(data.mark)
      {
         priceText.text#2 = StringUtil.format(data.mark,StringUtil.getNumStringCommas(data.price));
      }
      else
      {
         var isOneStore:Boolean = false;
         priceText.text#2 = StringUtil.format(GameSetting.getUIText(!!isOneStore ? "realmoney.mark.kr" : "realmoney.mark"),StringUtil.getNumStringCommas(data.price));
      }
      var count:int = UserDataWrapper.wrapper.getSetItemBuyableCount(setItemDef);
      if(count != -1)
      {
         if(count > 0)
         {
            labelText.text#2 = GameSetting.getUIText("setitem.buyable.rest").replace("%1",count);
            buyBtn.enableDrawCache(true,false,false);
            buyBtn.touchable = true;
         }
         else
         {
            labelText.text#2 = GameSetting.getUIText("setitem.not.buyable");
            if(buyBtn.touchable)
            {
               buyBtn.enableDrawCache(true,false,true);
               buyBtn.touchable = false;
            }
            else
            {
               buyBtn.enabled = false;
               buyBtn.touchable = false;
            }
         }
         bonusSprite.visible = true;
      }
      else
      {
         bonusSprite.visible = false;
      }
      var desc:String = GameSetting.getUIText("setitem.desc");
      descText.text#2 = desc;
      TweenAnimator.startItself(displaySprite,"pos" + (desc.length > 0 ? 1 : 0));
      TweenAnimator.finishItself(displaySprite);
   }
   
   public function dispose() : void
   {
      buyBtn.removeEventListener("triggered",triggeredBuyBtn);
      buyBtn = null;
      detailBtn.removeEventListener("triggered",triggeredDetailBtn);
      detailBtn = null;
   }
}
