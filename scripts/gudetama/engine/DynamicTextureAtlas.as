package gudetama.engine
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.util.StarlingUtil;
   import starling.textures.SubTexture;
   import starling.textures.Texture;
   
   public class DynamicTextureAtlas
   {
      
      private static const MAX_SIZE:int = 2048;
       
      
      public var atlasTexture:Texture;
      
      private var subTextures:Dictionary;
      
      private var regions:Vector.<AtlasRegion>;
      
      private var atlasWidth:Number;
      
      private var atlasHeight:Number;
      
      private var powerX:int;
      
      private var powerY:int;
      
      private var baseBitmapData:BitmapData;
      
      private var addedBitmapDataTable:Object;
      
      private var addedCount:int;
      
      private var onComplete:Function;
      
      private var createCompleted:Boolean;
      
      private var loadQueue:TaskQueue;
      
      private var overedRegions:Vector.<AtlasRegion>;
      
      private var regionCount:int = 0;
      
      public function DynamicTextureAtlas()
      {
         super();
         powerX = 8;
         powerY = 8;
         atlasWidth = 1 << powerX;
         atlasHeight = 1 << powerY;
         addedBitmapDataTable = {};
         regions = new Vector.<AtlasRegion>();
         subTextures = new Dictionary();
         addedCount = 0;
         loadQueue = new TaskQueue();
      }
      
      public function dispose() : void
      {
         if(baseBitmapData)
         {
            baseBitmapData.dispose();
            baseBitmapData = null;
         }
         if(atlasTexture)
         {
            atlasTexture.dispose();
            atlasTexture = null;
         }
         loadQueue = null;
         addedBitmapDataTable = null;
         regions = null;
      }
      
      public function reset() : void
      {
         if(baseBitmapData)
         {
            baseBitmapData.dispose();
            baseBitmapData = null;
         }
         if(atlasTexture)
         {
            atlasTexture.dispose();
            atlasTexture = null;
         }
         regions.length = 0;
         subTextures = new Dictionary();
         loadQueue = new TaskQueue();
         addedCount = 0;
         addedBitmapDataTable = {};
         powerX = 8;
         powerY = 8;
         atlasWidth = 1 << powerX;
         atlasHeight = 1 << powerY;
      }
      
      public function setCompleteCallback(param1:Function) : void
      {
         onComplete = param1;
      }
      
      public function isCreatedAtlas() : Boolean
      {
         return createCompleted;
      }
      
      public function loadSubTexBitmapData(param1:String) : void
      {
         var name:String = param1;
         if(addedBitmapDataTable.hasOwnProperty(name))
         {
            return;
         }
         var path:String = MukuGlobal.makePathFromName(name,".png");
         loadQueue.addTask(function():void
         {
            RsrcManager.getInstance().loadBitmapData(path,function(param1:Object):void
            {
               if(addedBitmapDataTable.hasOwnProperty(name))
               {
                  return;
               }
               addSubTexBitmapData(name,param1 as BitmapData);
               loadQueue.taskDone();
            });
         });
      }
      
      public function addSubTexBitmapData(param1:String, param2:BitmapData) : void
      {
         if(addedBitmapDataTable.hasOwnProperty(param1))
         {
            return;
         }
         addedBitmapDataTable[param1] = param2;
         regions.push(new AtlasRegion(param1,param2.width,param2.height));
         addedCount++;
         createCompleted = false;
      }
      
      public function recreateLoadTask() : void
      {
         loadQueue = new TaskQueue();
      }
      
      public function addLoadTask(param1:Function) : void
      {
         loadQueue.addTask(param1);
      }
      
      public function completeLoadTask() : void
      {
         loadQueue.taskDone();
      }
      
      public function hasTexture(param1:String) : Boolean
      {
         return subTextures.hasOwnProperty(param1);
      }
      
      public function getTexture(param1:String) : Texture
      {
         return subTextures[param1] as Texture;
      }
      
      public function setData(param1:Object) : void
      {
         regions = param1.regions;
         addedBitmapDataTable = param1.bitmapTable;
         addedCount = regions.length;
      }
      
      public function createTextureAtlas(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         loadQueue.startTask(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            regions.sort(function(param1:AtlasRegion, param2:AtlasRegion):Boolean
            {
               var _loc3_:int = param1.width * param1.width + param1.height * param1.height;
               var _loc4_:int = param2.width * param2.width + param2.height * param2.height;
               return _loc3_ > _loc4_ ? -1 : (Number(_loc3_ == _loc4_ ? 0 : 1));
            });
            if(baseBitmapData)
            {
               baseBitmapData.dispose();
            }
            var tree:Vector.<Node> = createTree(atlasWidth,atlasHeight);
            var i:int = 0;
            while(i < tree.length)
            {
               fillAtlas(tree[i],i);
               i++;
            }
            if(atlasTexture)
            {
               atlasTexture.dispose();
            }
            atlasTexture = Texture.fromBitmapData(baseBitmapData);
            subTextures = new Dictionary();
            for each(region in regions)
            {
               addRegion(region);
            }
            createCompleted = true;
            if(onComplete)
            {
               onComplete();
            }
            if(queue)
            {
               queue.taskDone();
            }
         });
      }
      
      public function recreateAtlas() : Object
      {
         regions.sort(function(param1:AtlasRegion, param2:AtlasRegion):Boolean
         {
            var _loc3_:int = param1.width * param1.width + param1.height * param1.height;
            var _loc4_:int = param2.width * param2.width + param2.height * param2.height;
            return _loc3_ > _loc4_ ? -1 : (Number(_loc3_ == _loc4_ ? 0 : 1));
         });
         if(baseBitmapData)
         {
            baseBitmapData.dispose();
         }
         var tree:Vector.<Node> = createTree(atlasWidth,atlasHeight);
         var i:int = 0;
         while(i < tree.length)
         {
            fillAtlas(tree[i],i);
            i++;
         }
         if(atlasTexture)
         {
            atlasTexture.dispose();
         }
         atlasTexture = Texture.fromBitmapData(baseBitmapData);
         for each(region in regions)
         {
            addRegion(region);
         }
         createCompleted = true;
         if(onComplete)
         {
            onComplete();
         }
         if(overedRegions && overedRegions.length > 0)
         {
            var data:Object = {};
            data.regions = overedRegions.concat();
            data.bitmapTable = new Dictionary();
            var length:int = overedRegions.length;
            var index:int = 0;
            while(index < length)
            {
               var name:String = (overedRegions[index] as AtlasRegion).getTextureName();
               data.bitmapTable[name] = addedBitmapDataTable[name];
               index++;
            }
            overedRegions = null;
            return data;
         }
         return null;
      }
      
      private function createTree(param1:Number, param2:Number) : Vector.<Node>
      {
         var _loc8_:* = null;
         var _loc3_:* = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = null;
         var _loc6_:Vector.<Node>;
         (_loc6_ = new Vector.<Node>()).push(new Node(0,0,param1,param2));
         var _loc7_:int = 0;
         for each(_loc8_ in regions)
         {
            _loc4_ = false;
            for each(_loc3_ in _loc6_)
            {
               if(_loc3_.insert(_loc8_) != null)
               {
                  _loc4_ = true;
                  _loc7_++;
                  break;
               }
            }
            if(!_loc4_)
            {
               (_loc5_ = new Node(0,0,param1,param2)).insert(_loc8_);
               _loc6_.push(_loc5_);
            }
         }
         if(_loc7_ < addedCount)
         {
            if(powerX == powerY)
            {
               powerX++;
            }
            else if(powerX > powerY)
            {
               powerY++;
            }
            if(1 << powerX <= 2048 && 1 << powerY <= 2048)
            {
               return createTree(1 << powerX,1 << powerY);
            }
            overedRegions = regions.splice(_loc7_,addedCount - _loc7_);
         }
         baseBitmapData = new BitmapData(param1,param2,true,0);
         atlasWidth = param1;
         atlasHeight = param2;
         return _loc6_;
      }
      
      private function fillAtlas(param1:Node, param2:int) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc6_:* = null;
         if(param1 == null)
         {
            return;
         }
         var _loc5_:AtlasRegion;
         if((_loc5_ = param1.region).textureName != null)
         {
            _loc3_ = addedBitmapDataTable[_loc5_.textureName];
            _loc4_ = StarlingUtil.getRectangleFromPool();
            _loc6_ = StarlingUtil.getPointFromPool();
            _loc4_.setTo(0,0,_loc5_.width,_loc5_.height);
            _loc6_.setTo(_loc5_.x,_loc5_.y);
            baseBitmapData.copyPixels(_loc3_,_loc4_,_loc6_);
         }
         fillAtlas(param1.childs[0],param2);
         fillAtlas(param1.childs[1],param2);
      }
      
      private function addRegion(param1:AtlasRegion) : void
      {
         var _loc2_:String = param1.textureName;
         subTextures[_loc2_] = new SubTexture(atlasTexture,param1 as Rectangle);
      }
      
      private function checkBounds(param1:Node, param2:Rectangle = null) : void
      {
         var _loc3_:* = null;
         if(param1 == null)
         {
            return;
         }
         if(!param2)
         {
            param2 = new Rectangle();
         }
         if(param1.region.textureName != null)
         {
            _loc3_ = param1.region;
            if(_loc3_.x < param2.x)
            {
               param2.x = _loc3_.x;
            }
            if(_loc3_.right > param2.right)
            {
               param2.right = _loc3_.right;
            }
            if(_loc3_.y < param2.y)
            {
               param2.y = _loc3_.y;
            }
            if(_loc3_.bottom > param2.bottom)
            {
               param2.bottom = _loc3_.bottom;
            }
         }
         checkBounds(param1.childs[0],param2);
         checkBounds(param1.childs[1],param2);
      }
   }
}

class Node
{
    
   
   public var childs:Vector.<Node>;
   
   public var region:AtlasRegion;
   
   function Node(param1:int, param2:int, param3:int, param4:int)
   {
      super();
      childs = new Vector.<Node>(2);
      region = new AtlasRegion(null,param3,param4,param1,param2);
   }
   
   private function isLeaf() : Boolean
   {
      return childs[0] == null && childs[1] == null;
   }
   
   public function insert(param1:AtlasRegion) : Node
   {
      var _loc2_:* = null;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      if(!isLeaf())
      {
         _loc2_ = childs[0].insert(param1);
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         return childs[1].insert(param1);
      }
      if(region.textureName != null)
      {
         return null;
      }
      if(!fitsInRegion(param1))
      {
         return null;
      }
      if(param1.width == region.width && param1.height == region.height)
      {
         param1.x = region.x;
         param1.y = region.y;
         region = param1;
         return this;
      }
      _loc3_ = region.width - param1.width;
      _loc4_ = region.height - param1.height;
      if(_loc3_ > _loc4_)
      {
         childs[0] = new Node(region.x,region.y,param1.width,region.height);
         childs[1] = new Node(region.x + param1.width,region.y,region.width - param1.width,region.height);
      }
      else
      {
         childs[0] = new Node(region.x,region.y,region.width,param1.height);
         childs[1] = new Node(region.x,region.y + param1.height,region.width,region.height - param1.height);
      }
      return childs[0].insert(param1);
   }
   
   public function fitsInRegion(param1:AtlasRegion) : Boolean
   {
      return Boolean(param1.width <= region.width && param1.height <= region.height);
   }
}

import flash.geom.Rectangle;

class AtlasRegion extends Rectangle
{
    
   
   public var textureName:String;
   
   public var isRotated:Boolean;
   
   function AtlasRegion(param1:String, param2:Number, param3:Number, param4:int = 0, param5:int = 0)
   {
      this.textureName = param1;
      super(param4,param5,param2,param3);
   }
   
   public function rotate() : void
   {
      var _loc1_:int = width;
      width = height;
      height = _loc1_;
      isRotated = !isRotated;
   }
   
   public function setPosition(param1:int, param2:int) : void
   {
      this.x = param1;
      this.y = param2;
   }
   
   public function getTextureName() : String
   {
      return textureName;
   }
   
   public function clear() : void
   {
      textureName = null;
   }
}
