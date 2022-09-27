package muku.display
{
   import flash.geom.Rectangle;
   import starling.display.Mesh;
   import starling.rendering.IndexData;
   import starling.rendering.MeshEffect;
   import starling.rendering.VertexData;
   import starling.rendering.VertexDataFormat;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.Padding;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   
   public class TextureMaskStyle extends MeshStyle
   {
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("threshold:float1");
      
      private static var sPadding:Padding = new Padding();
      
      private static var sBounds:Rectangle = new Rectangle();
      
      private static var sBasCols:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sBasRows:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sPosCols:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sPosRows:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sTexCols:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sTexRows:Vector.<Number> = new Vector.<Number>(3,true);
       
      
      private var _threshold:Number;
      
      private var _scale9Grid:Rectangle;
      
      private var _scaleX:Number;
      
      private var _scaleY:Number;
      
      public function TextureMaskStyle(param1:Number = 0.5)
      {
         super();
         _threshold = param1;
         _scaleX = _scaleY = 1;
      }
      
      override public function copyFrom(param1:MeshStyle) : void
      {
         var _loc2_:TextureMaskStyle = param1 as TextureMaskStyle;
         if(_loc2_)
         {
            _threshold = _loc2_._threshold;
         }
         super.copyFrom(param1);
      }
      
      override public function createEffect() : MeshEffect
      {
         return new TextureMaskEffect();
      }
      
      override public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      override protected function onTargetAssigned(param1:Mesh) : void
      {
         updateVertices();
      }
      
      private function updateVertices() : void
      {
         var _loc2_:int = 0;
         if(texture && _scale9Grid)
         {
            setupScale9Grid();
         }
         var _loc1_:int = vertexData.numVertices;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            vertexData.setFloat(_loc2_,"threshold",_threshold);
            _loc2_++;
         }
         setRequiresRedraw();
      }
      
      private function setupScale9Grid() : void
      {
         var _loc1_:int = 0;
         var _loc10_:int = 0;
         var _loc18_:Number = NaN;
         var _loc6_:int = 0;
         var _loc3_:* = 0;
         var _loc17_:Number = NaN;
         var _loc4_:Texture;
         var _loc19_:Rectangle = (_loc4_ = this.texture).frame;
         var _loc9_:Number = _scaleX > 0 ? _scaleX : Number(-_scaleX);
         var _loc11_:Number = _scaleY > 0 ? _scaleY : Number(-_scaleY);
         var _loc7_:Number = 1 / _loc9_;
         var _loc13_:Number = 1 / _loc11_;
         var _loc5_:VertexData = this.vertexData;
         var _loc8_:IndexData = this.indexData;
         var _loc2_:int = _loc5_.numVertices;
         var _loc12_:Rectangle = Pool.getRectangle();
         var _loc14_:Rectangle = Pool.getRectangle();
         var _loc15_:Rectangle = Pool.getRectangle();
         var _loc16_:Rectangle = Pool.getRectangle();
         _loc12_.copyFrom(_scale9Grid);
         _loc14_.setTo(0,0,_loc4_.frameWidth,_loc4_.frameHeight);
         if(_loc19_)
         {
            _loc15_.setTo(-_loc19_.x,-_loc19_.y,_loc4_.width,_loc4_.height);
         }
         else
         {
            _loc15_.copyFrom(_loc14_);
         }
         RectangleUtil.intersect(_loc12_,_loc15_,_loc16_);
         sBasCols[0] = sBasCols[2] = 0;
         sBasRows[0] = sBasRows[2] = 0;
         sBasCols[1] = _loc16_.width;
         sBasRows[1] = _loc16_.height;
         if(_loc15_.x < _loc12_.x)
         {
            sBasCols[0] = _loc12_.x - _loc15_.x;
         }
         if(_loc15_.y < _loc12_.y)
         {
            sBasRows[0] = _loc12_.y - _loc15_.y;
         }
         if(_loc15_.right > _loc12_.right)
         {
            sBasCols[2] = _loc15_.right - _loc12_.right;
         }
         if(_loc15_.bottom > _loc12_.bottom)
         {
            sBasRows[2] = _loc15_.bottom - _loc12_.bottom;
         }
         if(_loc15_.x < _loc12_.x)
         {
            sPadding.left = _loc15_.x * _loc7_;
         }
         else
         {
            sPadding.left = _loc12_.x * _loc7_ + _loc15_.x - _loc12_.x;
         }
         if(_loc15_.right > _loc12_.right)
         {
            sPadding.right = (_loc14_.width - _loc15_.right) * _loc7_;
         }
         else
         {
            sPadding.right = (_loc14_.width - _loc12_.right) * _loc7_ + _loc12_.right - _loc15_.right;
         }
         if(_loc15_.y < _loc12_.y)
         {
            sPadding.top = _loc15_.y * _loc13_;
         }
         else
         {
            sPadding.top = _loc12_.y * _loc13_ + _loc15_.y - _loc12_.y;
         }
         if(_loc15_.bottom > _loc12_.bottom)
         {
            sPadding.bottom = (_loc14_.height - _loc15_.bottom) * _loc13_;
         }
         else
         {
            sPadding.bottom = (_loc14_.height - _loc12_.bottom) * _loc13_ + _loc12_.bottom - _loc15_.bottom;
         }
         sPosCols[0] = sBasCols[0] * _loc7_;
         sPosCols[2] = sBasCols[2] * _loc7_;
         sPosCols[1] = _loc14_.width - sPadding.left - sPadding.right - sPosCols[0] - sPosCols[2];
         sPosRows[0] = sBasRows[0] * _loc13_;
         sPosRows[2] = sBasRows[2] * _loc13_;
         sPosRows[1] = _loc14_.height - sPadding.top - sPadding.bottom - sPosRows[0] - sPosRows[2];
         if(sPosCols[1] < 0)
         {
            _loc18_ = _loc14_.width / (_loc14_.width - _loc12_.width) * _loc9_;
            sPadding.left *= _loc18_;
            sPosCols[0] *= _loc18_;
            sPosCols[1] = 0.0001;
            sPosCols[2] *= _loc18_;
         }
         if(sPosRows[1] < 0)
         {
            _loc18_ = _loc14_.height / (_loc14_.height - _loc12_.height) * _loc11_;
            sPadding.top *= _loc18_;
            sPosRows[0] *= _loc18_;
            sPosRows[1] = 0.0001;
            sPosRows[2] *= _loc18_;
         }
         _loc10_ = setupScale9GridAttributes(sPadding.left,sPadding.top,sPosCols,sPosRows,setupScale9GridVertexPosition);
         sTexCols[0] = sBasCols[0] / _loc15_.width;
         sTexCols[2] = sBasCols[2] / _loc15_.width;
         sTexCols[1] = 1 - sTexCols[0] - sTexCols[2];
         sTexRows[0] = sBasRows[0] / _loc15_.height;
         sTexRows[2] = sBasRows[2] / _loc15_.height;
         sTexRows[1] = 1 - sTexRows[0] - sTexRows[2];
         setupScale9GridAttributes(0,0,sTexCols,sTexRows,setupScale9GridVertexTexCoords);
         _loc1_ = _loc10_ / 4;
         _loc5_.numVertices = _loc10_;
         _loc8_.numIndices = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc1_)
         {
            _loc8_.addQuad(_loc6_ * 4,_loc6_ * 4 + 1,_loc6_ * 4 + 2,_loc6_ * 4 + 3);
            _loc6_++;
         }
         if(_loc10_ != _loc2_)
         {
            _loc3_ = uint(!!_loc2_ ? _loc5_.getColor(0) : 16777215);
            _loc17_ = !!_loc2_ ? _loc5_.getAlpha(0) : 1;
            _loc5_.colorize("color",_loc3_,_loc17_);
         }
         Pool.putRectangle(_loc14_);
         Pool.putRectangle(_loc15_);
         Pool.putRectangle(_loc12_);
         Pool.putRectangle(_loc16_);
         setRequiresRedraw();
      }
      
      private function setupScale9GridVertexPosition(param1:VertexData, param2:Texture, param3:int, param4:Number, param5:Number) : void
      {
         param1.setPoint(param3,"position",param4,param5);
      }
      
      private function setupScale9GridVertexTexCoords(param1:VertexData, param2:Texture, param3:int, param4:Number, param5:Number) : void
      {
         param2.setTexCoords(param1,param3,"texCoords",param4,param5);
      }
      
      private function setupScale9GridAttributes(param1:Number, param2:Number, param3:Vector.<Number>, param4:Vector.<Number>, param5:Function) : int
      {
         var _loc6_:int = 0;
         var _loc9_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc13_:int = 0;
         var _loc10_:VertexData = this.vertexData;
         var _loc8_:Texture = this.texture;
         var _loc12_:* = param1;
         var _loc11_:* = param2;
         var _loc7_:int = 0;
         _loc13_ = 0;
         while(_loc13_ < 3)
         {
            if((_loc14_ = param4[_loc13_]) > 0)
            {
               _loc6_ = 0;
               while(_loc6_ < 3)
               {
                  if((_loc9_ = param3[_loc6_]) > 0)
                  {
                     param5(_loc10_,_loc8_,_loc7_++,_loc12_,_loc11_);
                     param5(_loc10_,_loc8_,_loc7_++,_loc12_ + _loc9_,_loc11_);
                     param5(_loc10_,_loc8_,_loc7_++,_loc12_,_loc11_ + _loc14_);
                     param5(_loc10_,_loc8_,_loc7_++,_loc12_ + _loc9_,_loc11_ + _loc14_);
                     _loc12_ += _loc9_;
                  }
                  _loc6_++;
               }
               _loc11_ += _loc14_;
            }
            _loc12_ = param1;
            _loc13_++;
         }
         return _loc7_;
      }
      
      public function get scale9Grid() : Rectangle
      {
         return _scale9Grid;
      }
      
      public function set scale9Grid(param1:Rectangle) : void
      {
         if(param1)
         {
            if(_scale9Grid == null)
            {
               _scale9Grid = param1.clone();
            }
            else
            {
               _scale9Grid.copyFrom(param1);
            }
         }
         else
         {
            _scale9Grid = null;
         }
         if(target)
         {
            updateVertices();
         }
      }
      
      public function get threshold() : Number
      {
         return _threshold;
      }
      
      public function set threshold(param1:Number) : void
      {
         if(_threshold != param1 && target)
         {
            _threshold = param1;
            updateVertices();
         }
      }
      
      public function get scaleX() : Number
      {
         return _scaleX;
      }
      
      public function set scaleX(param1:Number) : void
      {
         if(_scaleX != param1 && target)
         {
            updateVertices();
         }
         _scaleX = param1;
      }
      
      public function get scaleY() : Number
      {
         return _scaleY;
      }
      
      public function set scaleY(param1:Number) : void
      {
         if(_scaleY != param1 && target)
         {
            updateVertices();
         }
         _scaleY = param1;
      }
   }
}

import flash.display3D.Context3D;
import muku.display.TextureMaskStyle;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;

class TextureMaskEffect extends MeshEffect
{
   
   public static const VERTEX_FORMAT:VertexDataFormat = TextureMaskStyle.VERTEX_FORMAT;
    
   
   function TextureMaskEffect()
   {
      super();
   }
   
   override protected function createProgram() : Program
   {
      var _loc1_:* = null;
      var _loc2_:* = null;
      if(texture)
      {
         _loc1_ = ["m44 op, va0, vc0","mov v0, va1     ","mul v1, va2, vc4","mov v2, va3     "].join("\n");
         _loc2_ = [tex("ft0","v0",0,texture),"sub ft1, ft0, v2.xxxx","kil ft1.w            ","mul  oc, ft0, v1     "].join("\n");
         return Program.fromSource(_loc1_,_loc2_);
      }
      return super.createProgram();
   }
   
   override protected function beforeDraw(param1:Context3D) : void
   {
      super.beforeDraw(param1);
      if(texture)
      {
         vertexFormat.setVertexBufferAt(3,vertexBuffer,"threshold");
      }
   }
   
   override protected function afterDraw(param1:Context3D) : void
   {
      if(texture)
      {
         param1.setVertexBufferAt(3,null);
      }
      super.afterDraw(param1);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
}
