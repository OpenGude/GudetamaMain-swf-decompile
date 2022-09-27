package spine.starling
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import spine.Bone;
   import spine.Skeleton;
   import spine.SkeletonData;
   import spine.Slot;
   import spine.atlas.AtlasRegion;
   import spine.attachments.Attachment;
   import spine.attachments.MeshAttachment;
   import spine.attachments.RegionAttachment;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.rendering.IndexData;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.utils.Color;
   import starling.utils.MatrixUtil;
   
   public class SkeletonSprite extends DisplayObject
   {
      
      private static var _tempPoint:Point = new Point();
      
      private static var _tempMatrix:Matrix = new Matrix();
      
      private static var _tempVertices:Vector.<Number> = new Vector.<Number>(8);
      
      static var blendModes:Vector.<String> = new <String>["normal","add","multiply","screen"];
       
      
      private var _skeleton:Skeleton;
      
      public var batchable:Boolean = true;
      
      private var _smoothing:String = "bilinear";
      
      public function SkeletonSprite(param1:SkeletonData)
      {
         super();
         Bone.yDown = true;
         _skeleton = new Skeleton(param1);
         _skeleton.updateWorldTransform();
      }
      
      override public function render(param1:Painter) : void
      {
         var _loc3_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc7_:* = 0;
         var _loc9_:* = null;
         var _loc12_:* = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc24_:* = undefined;
         var _loc17_:* = null;
         var _loc5_:* = null;
         var _loc25_:* = undefined;
         var _loc18_:int = 0;
         var _loc20_:int = 0;
         var _loc6_:* = null;
         var _loc29_:* = null;
         var _loc13_:* = null;
         var _loc2_:* = null;
         var _loc19_:int = 0;
         var _loc22_:* = null;
         var _loc21_:* = null;
         param1.state.alpha *= skeleton.a;
         var _loc15_:String = param1.state.blendMode;
         var _loc23_:Number = skeleton.r * 255;
         var _loc16_:Number = skeleton.g * 255;
         var _loc14_:Number = skeleton.b * 255;
         var _loc27_:Number = skeleton.x;
         var _loc28_:Number = skeleton.y;
         var _loc26_:Vector.<Slot> = skeleton.drawOrder;
         var _loc30_:Vector.<Number> = _tempVertices;
         _loc18_ = 0;
         _loc20_ = _loc26_.length;
         while(_loc18_ < _loc20_)
         {
            if((_loc6_ = _loc26_[_loc18_]).attachment is RegionAttachment)
            {
               (_loc29_ = _loc6_.attachment as RegionAttachment).computeWorldVertices(_loc27_,_loc28_,_loc6_.bone,_loc30_);
               _loc11_ = _loc6_.a * _loc29_.a;
               _loc7_ = uint(Color.rgb(_loc23_ * _loc6_.r * _loc29_.r,_loc16_ * _loc6_.g * _loc29_.g,_loc14_ * _loc6_.b * _loc29_.b));
               if((_loc13_ = _loc29_.rendererObject as Image) == null)
               {
                  _loc2_ = Image(AtlasRegion(_loc29_.rendererObject).rendererObject);
                  _loc29_.rendererObject = _loc13_ = new Image(_loc2_.texture);
                  _loc19_ = 0;
                  while(_loc19_ < 4)
                  {
                     _loc22_ = _loc2_.getTexCoords(_loc19_);
                     _loc13_.setTexCoords(_loc19_,_loc22_.x,_loc22_.y);
                     _loc19_++;
                  }
               }
               _loc13_.setVertexPosition(0,_loc30_[2],_loc30_[3]);
               _loc13_.setVertexColor(0,_loc7_);
               _loc13_.setVertexAlpha(0,_loc11_);
               _loc13_.setVertexPosition(1,_loc30_[4],_loc30_[5]);
               _loc13_.setVertexColor(1,_loc7_);
               _loc13_.setVertexAlpha(1,_loc11_);
               _loc13_.setVertexPosition(2,_loc30_[0],_loc30_[1]);
               _loc13_.setVertexColor(2,_loc7_);
               _loc13_.setVertexAlpha(2,_loc11_);
               _loc13_.setVertexPosition(3,_loc30_[6],_loc30_[7]);
               _loc13_.setVertexColor(3,_loc7_);
               _loc13_.setVertexAlpha(3,_loc11_);
               _loc13_.setRequiresRedraw();
               param1.state.blendMode = blendModes[_loc6_.data#2.blendMode.ordinal];
               param1.batchMesh(_loc13_);
            }
            else if(_loc6_.attachment is MeshAttachment)
            {
               _loc12_ = (_loc4_ = (_loc21_ = MeshAttachment(_loc6_.attachment)).worldVerticesLength) >> 1;
               if(_loc30_.length < _loc4_)
               {
                  _loc30_.length = _loc4_;
               }
               _loc21_.computeWorldVertices(_loc6_,_loc30_);
               if((_loc9_ = _loc21_.rendererObject as SkeletonMesh) == null)
               {
                  if(_loc21_.rendererObject is Image)
                  {
                     _loc21_.rendererObject = _loc9_ = new SkeletonMesh(Image(_loc21_.rendererObject).texture);
                  }
                  if(_loc21_.rendererObject is AtlasRegion)
                  {
                     _loc21_.rendererObject = _loc9_ = new SkeletonMesh(Image(AtlasRegion(_loc21_.rendererObject).rendererObject).texture);
                  }
               }
               if(_loc9_.numIndices != _loc21_.triangles.length)
               {
                  _loc5_ = _loc9_.getIndexData();
                  _loc24_ = _loc21_.triangles;
                  _loc8_ = _loc21_.triangles.length;
                  _loc10_ = 0;
                  while(_loc10_ < _loc8_)
                  {
                     _loc5_.setIndex(_loc10_,_loc24_[_loc10_]);
                     _loc10_++;
                  }
                  _loc5_.numIndices = _loc8_;
                  _loc5_.trim();
               }
               _loc11_ = _loc6_.a * _loc21_.a;
               _loc7_ = uint(Color.rgb(_loc23_ * _loc6_.r * _loc21_.r,_loc16_ * _loc6_.g * _loc21_.g,_loc14_ * _loc6_.b * _loc21_.b));
               _loc17_ = _loc9_.getVertexData();
               _loc25_ = _loc21_.uvs;
               _loc17_.colorize("color",_loc7_,_loc11_);
               _loc10_ = 0;
               _loc3_ = 0;
               while(_loc10_ < _loc12_)
               {
                  _loc9_.setVertexPosition(_loc10_,_loc30_[_loc3_],_loc30_[_loc3_ + 1]);
                  _loc9_.setTexCoords(_loc10_,_loc25_[_loc3_],_loc25_[_loc3_ + 1]);
                  _loc10_++;
                  _loc3_ += 2;
               }
               _loc17_.numVertices = _loc12_;
               param1.state.blendMode = blendModes[_loc6_.data#2.blendMode.ordinal];
               param1.batchMesh(_loc9_);
            }
            _loc18_++;
         }
         param1.state.blendMode = _loc15_;
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:* = null;
         var _loc13_:* = null;
         var _loc7_:int = 0;
         var _loc17_:* = null;
         var _loc18_:* = null;
         var _loc2_:int = 0;
         var _loc15_:Number = NaN;
         var _loc3_:* = NaN;
         if(!touchable)
         {
            return null;
         }
         var _loc14_:* = 1.7976931348623157e+308;
         var _loc12_:* = 1.7976931348623157e+308;
         var _loc5_:* = -1.7976931348623157e+308;
         var _loc4_:* = -1.7976931348623157e+308;
         var _loc11_:Vector.<Slot> = skeleton.slots;
         var _loc19_:Vector.<Number> = _tempVertices;
         var _loc10_:Boolean = true;
         _loc6_ = 0;
         _loc9_ = _loc11_.length;
         for(; _loc6_ < _loc9_; _loc6_++)
         {
            if(_loc13_ = (_loc8_ = _loc11_[_loc6_]).attachment)
            {
               if(_loc13_ is RegionAttachment)
               {
                  _loc17_ = RegionAttachment(_loc8_.attachment);
                  _loc7_ = 8;
                  _loc17_.computeWorldVertices(0,0,_loc8_.bone,_loc19_);
               }
               else
               {
                  if(!(_loc13_ is MeshAttachment))
                  {
                     continue;
                  }
                  _loc7_ = (_loc18_ = MeshAttachment(_loc13_)).worldVerticesLength;
                  if(_loc19_.length < _loc7_)
                  {
                     _loc19_.length = _loc7_;
                  }
                  _loc18_.computeWorldVertices(_loc8_,_loc19_);
               }
               if(_loc7_ != 0)
               {
                  _loc10_ = false;
               }
               _loc2_ = 0;
               while(_loc2_ < _loc7_)
               {
                  _loc15_ = _loc19_[_loc2_];
                  var _loc16_:Number = _loc19_[_loc2_ + 1];
                  _loc14_ = Number(_loc14_ < _loc15_ ? _loc14_ : Number(_loc15_));
                  _loc12_ = Number(_loc12_ < _loc16_ ? _loc12_ : Number(_loc16_));
                  _loc5_ = Number(_loc5_ > _loc15_ ? _loc5_ : Number(_loc15_));
                  _loc4_ = Number(_loc4_ > _loc16_ ? _loc4_ : Number(_loc16_));
                  _loc2_ += 2;
               }
            }
         }
         if(_loc10_)
         {
            return null;
         }
         if(_loc5_ < _loc14_)
         {
            _loc3_ = _loc5_;
            _loc5_ = _loc14_;
            _loc14_ = _loc3_;
         }
         if(_loc4_ < _loc12_)
         {
            _loc3_ = _loc4_;
            _loc4_ = _loc12_;
            _loc12_ = _loc3_;
         }
         if(param1.x >= _loc14_ && param1.x < _loc5_ && param1.y >= _loc12_ && param1.y < _loc4_)
         {
            return this;
         }
         return null;
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         if(!param2)
         {
            param2 = new Rectangle();
         }
         if(param1 == this)
         {
            param2.setTo(0,0,0,0);
         }
         else if(param1 == parent)
         {
            param2.setTo(x,y,0,0);
         }
         else
         {
            getTransformationMatrix(param1,_tempMatrix);
            MatrixUtil.transformCoords(_tempMatrix,0,0,_tempPoint);
            param2.setTo(_tempPoint.x,_tempPoint.y,0,0);
         }
         return param2;
      }
      
      public function get skeleton() : Skeleton
      {
         return _skeleton;
      }
      
      public function get smoothing() : String
      {
         return _smoothing;
      }
      
      public function get tempVertices() : Vector.<Number>
      {
         return _tempVertices;
      }
      
      public function set smoothing(param1:String) : void
      {
         _smoothing = param1;
      }
   }
}
