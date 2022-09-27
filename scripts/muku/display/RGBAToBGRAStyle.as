package muku.display
{
   import starling.display.Mesh;
   import starling.rendering.MeshEffect;
   import starling.rendering.VertexDataFormat;
   import starling.styles.MeshStyle;
   
   public class RGBAToBGRAStyle extends MeshStyle
   {
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("offset:float4");
       
      
      private var _offsets:Vector.<Number>;
      
      public function RGBAToBGRAStyle(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0)
      {
         super();
         _offsets = new Vector.<Number>(4,true);
         setTo(param1,param2,param3,param4);
      }
      
      public function setTo(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0) : void
      {
         _offsets[0] = param1;
         _offsets[1] = param2;
         _offsets[2] = param3;
         _offsets[3] = param4;
         updateVertices();
      }
      
      override public function copyFrom(param1:MeshStyle) : void
      {
         var _loc3_:int = 0;
         var _loc2_:RGBAToBGRAStyle = param1 as RGBAToBGRAStyle;
         if(_loc2_)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _offsets[_loc3_] = _loc2_._offsets[_loc3_];
               _loc3_++;
            }
         }
         super.copyFrom(param1);
      }
      
      override public function createEffect() : MeshEffect
      {
         return new RGBAToBGRAEffect();
      }
      
      override protected function onTargetAssigned(param1:Mesh) : void
      {
         updateVertices();
      }
      
      override public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      private function updateVertices() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(target)
         {
            _loc1_ = vertexData.numVertices;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               vertexData.setPoint4D(_loc2_,"offset",_offsets[0],_offsets[1],_offsets[2],_offsets[3]);
               _loc2_++;
            }
            setRequiresRedraw();
         }
      }
      
      public function get redOffset() : Number
      {
         return _offsets[0];
      }
      
      public function set redOffset(param1:Number) : void
      {
         _offsets[0] = param1;
         updateVertices();
      }
      
      public function get greenOffset() : Number
      {
         return _offsets[1];
      }
      
      public function set greenOffset(param1:Number) : void
      {
         _offsets[1] = param1;
         updateVertices();
      }
      
      public function get blueOffset() : Number
      {
         return _offsets[2];
      }
      
      public function set blueOffset(param1:Number) : void
      {
         _offsets[2] = param1;
         updateVertices();
      }
      
      public function get alphaOffset() : Number
      {
         return _offsets[3];
      }
      
      public function set alphaOffset(param1:Number) : void
      {
         _offsets[3] = param1;
         updateVertices();
      }
   }
}

import flash.display3D.Context3D;
import muku.display.RGBAToBGRAStyle;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;

class RGBAToBGRAEffect extends MeshEffect
{
   
   public static const VERTEX_FORMAT:VertexDataFormat = RGBAToBGRAStyle.VERTEX_FORMAT;
    
   
   function RGBAToBGRAEffect()
   {
      super();
   }
   
   override protected function createProgram() : Program
   {
      var _loc2_:* = null;
      var _loc1_:* = null;
      var _loc3_:String = ["mov ft1, v2","mul ft1.xyz, v2.xyz, ft0.www","add oc, ft0, ft1"].join("\n");
      if(texture)
      {
         _loc1_ = ["m44 op, va0, vc0","mov v0, va1     ","mul v1, va2, vc4","mov v2, va3     "].join("\n");
         _loc2_ = [tex("ft0","v0",0,texture) + "mov ft2 ft0","mov ft0.xyz ft2.zyx","mul ft0, ft0, v1",_loc3_].join("\n");
      }
      else
      {
         _loc1_ = ["m44 op, va0, vc0","mul v0, va2, vc4","mov v2, va3     "].join("\n");
         _loc2_ = ["mov ft0, v0",_loc3_].join("\n");
      }
      return Program.fromSource(_loc1_,_loc2_);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
   
   override protected function beforeDraw(param1:Context3D) : void
   {
      super.beforeDraw(param1);
      vertexFormat.setVertexBufferAt(3,vertexBuffer,"offset");
   }
   
   override protected function afterDraw(param1:Context3D) : void
   {
      param1.setVertexBufferAt(3,null);
      super.afterDraw(param1);
   }
}
