package starling.textures
{
   import flash.display3D.textures.TextureBase;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.filters.FragmentFilter;
   import starling.rendering.Painter;
   import starling.rendering.RenderState;
   import starling.utils.execute;
   
   public class RenderTexture extends SubTexture
   {
      
      private static const USE_DOUBLE_BUFFERING_DATA_NAME:String = "starling.textures.RenderTexture.useDoubleBuffering";
      
      private static var sClipRect:Rectangle = new Rectangle();
       
      
      private var _activeTexture:Texture;
      
      private var _bufferTexture:Texture;
      
      private var _helperImage:Image;
      
      private var _drawing:Boolean;
      
      private var _bufferReady:Boolean;
      
      private var _isPersistent:Boolean;
      
      public function RenderTexture(param1:int, param2:int, param3:Boolean = true, param4:Number = -1, param5:String = "bgra")
      {
         _isPersistent = param3;
         _activeTexture = Texture.empty(param1,param2,true,false,true,param4,param5);
         _activeTexture.root.onRestore = _activeTexture.root.clear;
         super(_activeTexture,new Rectangle(0,0,param1,param2),true,null,false);
         var _loc7_:Dictionary;
         var _loc6_:Painter;
         var _loc9_:Boolean;
         var _loc8_:String;
         if(param3 && (!!starling.core.Starling.current ? (_loc7_ = (_loc6_ = starling.core.Starling.painter).sharedData, "starling.textures.RenderTexture.useDoubleBuffering" in _loc7_ ? _loc7_["starling.textures.RenderTexture.useDoubleBuffering"] : (_loc9_ = (_loc8_ = !!_loc6_.profile ? _loc6_.profile : "baseline") == "baseline" || _loc8_ == "baselineConstrained", _loc7_["starling.textures.RenderTexture.useDoubleBuffering"] = _loc9_, _loc9_)) : false))
         {
            _bufferTexture = Texture.empty(param1,param2,true,false,true,param4,param5);
            _bufferTexture.root.onRestore = _bufferTexture.root.clear;
            _helperImage = new Image(_bufferTexture);
            _helperImage.textureSmoothing = "none";
         }
      }
      
      public static function get useDoubleBuffering() : Boolean
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = Starling;
         if(starling.core.Starling.sCurrent)
         {
            var _loc6_:* = Starling;
            _loc1_ = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
            _loc2_ = _loc1_.sharedData;
            if("starling.textures.RenderTexture.useDoubleBuffering" in _loc2_)
            {
               return _loc2_["starling.textures.RenderTexture.useDoubleBuffering"];
            }
            _loc3_ = !!_loc1_.profile ? _loc1_.profile : "baseline";
            _loc4_ = _loc3_ == "baseline" || _loc3_ == "baselineConstrained";
            _loc2_["starling.textures.RenderTexture.useDoubleBuffering"] = _loc4_;
            return _loc4_;
         }
         return false;
      }
      
      public static function set useDoubleBuffering(param1:Boolean) : void
      {
         var _loc2_:* = Starling;
         if(starling.core.Starling.sCurrent == null)
         {
            throw new IllegalOperationError("Starling not yet initialized");
         }
         var _loc3_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null).sharedData["starling.textures.RenderTexture.useDoubleBuffering"] = param1;
      }
      
      override public function dispose() : void
      {
         _activeTexture.dispose();
         if(isDoubleBuffered)
         {
            _bufferTexture.dispose();
            _helperImage.dispose();
         }
         super.dispose();
      }
      
      public function draw(param1:DisplayObject, param2:Matrix = null, param3:Number = 1.0, param4:int = 0) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(_drawing)
         {
            render(param1,param2,param3);
         }
         else
         {
            renderBundled(render,param1,param2,param3,param4);
         }
      }
      
      public function drawBundled(param1:Function, param2:int = 0) : void
      {
         renderBundled(param1,null,null,1,param2);
      }
      
      private function render(param1:DisplayObject, param2:Matrix = null, param3:Number = 1.0) : void
      {
         var _loc9_:* = Starling;
         var _loc4_:Painter;
         var _loc7_:RenderState = (_loc4_ = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null).state;
         var _loc6_:Boolean = _loc4_.cacheEnabled;
         var _loc5_:FragmentFilter = param1.filter;
         var _loc8_:DisplayObject = param1.mask;
         _loc4_.cacheEnabled = false;
         _loc4_.pushState();
         _loc7_.alpha = param1.alpha * param3;
         _loc7_.setModelviewMatricesToIdentity();
         _loc7_.blendMode = param1.blendMode == "auto" ? "normal" : param1.blendMode;
         if(param2)
         {
            _loc7_.transformModelviewMatrix(param2);
         }
         else
         {
            _loc7_.transformModelviewMatrix(param1.transformationMatrix);
         }
         if(_loc8_)
         {
            _loc4_.drawMask(_loc8_);
         }
         if(_loc5_)
         {
            _loc5_.render(_loc4_);
         }
         else
         {
            param1.render(_loc4_);
         }
         if(_loc8_)
         {
            _loc4_.eraseMask(_loc8_);
         }
         _loc4_.popState();
         _loc4_.cacheEnabled = _loc6_;
      }
      
      private function renderBundled(param1:Function, param2:DisplayObject = null, param3:Matrix = null, param4:Number = 1.0, param5:int = 0) : void
      {
         var _loc7_:* = null;
         var _loc10_:* = Starling;
         var _loc6_:Painter;
         var _loc9_:RenderState = (_loc6_ = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null).state;
         var _loc11_:* = Starling;
         if(!starling.core.Starling.sCurrent.contextValid)
         {
            return;
         }
         if(isDoubleBuffered)
         {
            _loc7_ = _activeTexture;
            _activeTexture = _bufferTexture;
            _bufferTexture = _loc7_;
            _helperImage.texture = _bufferTexture;
         }
         _loc6_.pushState();
         var _loc8_:Texture = _activeTexture.root;
         _loc9_.setProjectionMatrix(0,0,_loc8_.width,_loc8_.height,width,height);
         sClipRect.setTo(0,0,_activeTexture.width,_activeTexture.height);
         _loc9_.clipRect = sClipRect;
         _loc9_.setRenderTarget(_activeTexture,true,param5);
         _loc6_.prepareToDraw();
         if(isDoubleBuffered || !isPersistent || !_bufferReady)
         {
            _loc6_.clear();
         }
         if(isDoubleBuffered && _bufferReady)
         {
            _helperImage.render(_loc6_);
         }
         else
         {
            _bufferReady = true;
         }
         try
         {
            _drawing = true;
            execute(param1,param2,param3,param4);
         }
         finally
         {
            _drawing = false;
            _loc6_.popState();
         }
      }
      
      public function clear(param1:uint = 0, param2:Number = 0.0) : void
      {
         _activeTexture.root.clear(param1,param2);
         _bufferReady = true;
      }
      
      private function get isDoubleBuffered() : Boolean
      {
         return _bufferTexture != null;
      }
      
      public function get isPersistent() : Boolean
      {
         return _isPersistent;
      }
      
      override public function get base() : TextureBase
      {
         return _activeTexture.base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return _activeTexture.root;
      }
   }
}
