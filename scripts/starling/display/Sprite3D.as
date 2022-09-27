package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.rad2deg;
   
   public class Sprite3D extends DisplayObjectContainer
   {
      
      private static const E:Number = 1.0E-5;
      
      private static var sHelperPoint:Vector3D = new Vector3D();
      
      private static var sHelperPointAlt:Vector3D = new Vector3D();
      
      private static var sHelperMatrix:Matrix3D = new Matrix3D();
       
      
      private var _rotationX:Number;
      
      private var _rotationY:Number;
      
      private var _scaleZ:Number;
      
      private var _pivotZ:Number;
      
      private var _z:Number;
      
      private var _transformationMatrix:Matrix;
      
      private var _transformationMatrix3D:Matrix3D;
      
      private var _transformationChanged:Boolean;
      
      private var _is2D:Boolean;
      
      public function Sprite3D()
      {
         super();
         _scaleZ = 1;
         _rotationX = _rotationY = _pivotZ = _z = 0;
         _transformationMatrix = new Matrix();
         _transformationMatrix3D = new Matrix3D();
         _is2D = true;
         setIs3D(true);
         addEventListener("added",onAddedChild);
         addEventListener("removed",onRemovedChild);
      }
      
      override public function render(param1:Painter) : void
      {
         if(_is2D)
         {
            super.render(param1);
         }
         else
         {
            param1.finishMeshBatch();
            param1.pushState();
            param1.state.transformModelviewMatrix3D(transformationMatrix3D);
            super.render(param1);
            param1.finishMeshBatch();
            param1.excludeFromCache(this);
            param1.popState();
         }
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         if(_is2D)
         {
            return super.hitTest(param1);
         }
         if(!visible || !touchable)
         {
            return null;
         }
         sHelperMatrix.copyFrom(transformationMatrix3D);
         sHelperMatrix.invert();
         stage.getCameraPosition(this,sHelperPoint);
         MatrixUtil.transformCoords3D(sHelperMatrix,param1.x,param1.y,0,sHelperPointAlt);
         MathUtil.intersectLineWithXYPlane(sHelperPoint,sHelperPointAlt,param1);
         return super.hitTest(param1);
      }
      
      override public function setRequiresRedraw() : void
      {
         _is2D = _z > -0.00001 && _z < 0.00001 && _rotationX > -0.00001 && _rotationX < 0.00001 && _rotationY > -0.00001 && _rotationY < 0.00001 && _pivotZ > -0.00001 && _pivotZ < 0.00001;
         super.setRequiresRedraw();
      }
      
      private function onAddedChild(param1:Event) : void
      {
         recursivelySetIs3D(param1.target as DisplayObject,true);
      }
      
      private function onRemovedChild(param1:Event) : void
      {
         recursivelySetIs3D(param1.target as DisplayObject,false);
      }
      
      private function recursivelySetIs3D(param1:DisplayObject, param2:Boolean) : void
      {
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1 is Sprite3D)
         {
            return;
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc3_ = param1 as DisplayObjectContainer;
            _loc4_ = _loc3_.numChildren;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               recursivelySetIs3D(_loc3_.getChildAt(_loc5_),param2);
               _loc5_++;
            }
         }
         param1.setIs3D(param2);
      }
      
      private function updateMatrices() : void
      {
         var _loc4_:Number = this.x;
         var _loc5_:Number = this.y;
         var _loc1_:Number = this.scaleX;
         var _loc2_:Number = this.scaleY;
         var _loc7_:Number = this.pivotX;
         var _loc6_:Number = this.pivotY;
         var _loc3_:Number = this.rotation;
         _transformationMatrix3D.identity();
         if(_loc1_ != 1 || _loc2_ != 1 || _scaleZ != 1)
         {
            _transformationMatrix3D.appendScale(_loc1_ || 0.00001,_loc2_ || 0.00001,_scaleZ || 0.00001);
         }
         if(_rotationX != 0)
         {
            _transformationMatrix3D.appendRotation(rad2deg(_rotationX),Vector3D.X_AXIS);
         }
         if(_rotationY != 0)
         {
            _transformationMatrix3D.appendRotation(rad2deg(_rotationY),Vector3D.Y_AXIS);
         }
         if(_loc3_ != 0)
         {
            _transformationMatrix3D.appendRotation(rad2deg(_loc3_),Vector3D.Z_AXIS);
         }
         if(_loc4_ != 0 || _loc5_ != 0 || _z != 0)
         {
            _transformationMatrix3D.appendTranslation(_loc4_,_loc5_,_z);
         }
         if(_loc7_ != 0 || _loc6_ != 0 || _pivotZ != 0)
         {
            _transformationMatrix3D.prependTranslation(-_loc7_,-_loc6_,-_pivotZ);
         }
         if(_is2D)
         {
            MatrixUtil.convertTo2D(_transformationMatrix3D,_transformationMatrix);
         }
         else
         {
            _transformationMatrix.identity();
         }
      }
      
      override public function get transformationMatrix() : Matrix
      {
         if(_transformationChanged)
         {
            updateMatrices();
            _transformationChanged = false;
         }
         return _transformationMatrix;
      }
      
      override public function set transformationMatrix(param1:Matrix) : void
      {
         super.transformationMatrix = param1;
         _rotationX = _rotationY = _pivotZ = _z = 0;
         _transformationChanged = true;
      }
      
      override public function get transformationMatrix3D() : Matrix3D
      {
         if(_transformationChanged)
         {
            updateMatrices();
            _transformationChanged = false;
         }
         return _transformationMatrix3D;
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
         _transformationChanged = true;
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         _transformationChanged = true;
      }
      
      public function get z() : Number
      {
         return _z;
      }
      
      public function set z(param1:Number) : void
      {
         _z = param1;
         _transformationChanged = true;
         setRequiresRedraw();
      }
      
      override public function set pivotX(param1:Number) : void
      {
         super.pivotX = param1;
         _transformationChanged = true;
      }
      
      override public function set pivotY(param1:Number) : void
      {
         super.pivotY = param1;
         _transformationChanged = true;
      }
      
      public function get pivotZ() : Number
      {
         return _pivotZ;
      }
      
      public function set pivotZ(param1:Number) : void
      {
         _pivotZ = param1;
         _transformationChanged = true;
         setRequiresRedraw();
      }
      
      override public function set scaleX(param1:Number) : void
      {
         super.scaleX = param1;
         _transformationChanged = true;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         super.scaleY = param1;
         _transformationChanged = true;
      }
      
      public function get scaleZ() : Number
      {
         return _scaleZ;
      }
      
      public function set scaleZ(param1:Number) : void
      {
         _scaleZ = param1;
         _transformationChanged = true;
         setRequiresRedraw();
      }
      
      override public function set scale(param1:Number) : void
      {
         scaleX = scaleY = scaleZ = param1;
      }
      
      override public function set skewX(param1:Number) : void
      {
         throw new Error("3D objects do not support skewing");
      }
      
      override public function set skewY(param1:Number) : void
      {
         throw new Error("3D objects do not support skewing");
      }
      
      override public function set rotation(param1:Number) : void
      {
         super.rotation = param1;
         _transformationChanged = true;
      }
      
      public function get rotationX() : Number
      {
         return _rotationX;
      }
      
      public function set rotationX(param1:Number) : void
      {
         _rotationX = MathUtil.normalizeAngle(param1);
         _transformationChanged = true;
         setRequiresRedraw();
      }
      
      public function get rotationY() : Number
      {
         return _rotationY;
      }
      
      public function set rotationY(param1:Number) : void
      {
         _rotationY = MathUtil.normalizeAngle(param1);
         _transformationChanged = true;
         setRequiresRedraw();
      }
      
      public function get rotationZ() : Number
      {
         return rotation;
      }
      
      public function set rotationZ(param1:Number) : void
      {
         rotation = param1;
      }
   }
}
