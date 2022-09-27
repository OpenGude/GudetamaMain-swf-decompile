package starling.textures
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display3D.textures.TextureBase;
   import flash.media.Camera;
   import flash.net.NetStream;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import gudetama.util.TimeZoneUtil;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.errors.AbstractMethodError;
   import starling.errors.NotSupportedError;
   import starling.rendering.Painter;
   import starling.utils.Color;
   import starling.utils.execute;
   
   public class ConcreteTexture extends Texture
   {
      
      public static var restoreDisabled:Boolean = false;
      
      protected static var registrants:Dictionary = new Dictionary();
      
      protected static var capturedRegistrants:Object;
       
      
      private var _base:TextureBase;
      
      private var _format:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _mipMapping:Boolean;
      
      private var _premultipliedAlpha:Boolean;
      
      private var _optimizedForRenderTexture:Boolean;
      
      private var _scale:Number;
      
      private var _onRestore:Function;
      
      private var _dataUploaded:Boolean;
      
      private var _getBitmap:Function;
      
      public function ConcreteTexture(param1:TextureBase, param2:String, param3:int, param4:int, param5:Boolean, param6:Boolean, param7:Boolean = false, param8:Number = 1)
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.textures::ConcreteTexture")
         {
            throw new AbstractClassError();
         }
         _scale = param8 <= 0 ? 1 : Number(param8);
         _base = param1;
         _format = param2;
         _width = param3;
         _height = param4;
         _mipMapping = param5;
         _premultipliedAlpha = param6;
         _optimizedForRenderTexture = param7;
         _onRestore = null;
         _getBitmap = null;
         _dataUploaded = false;
      }
      
      public static function setTraceEnabled(param1:Boolean) : void
      {
         if(param1)
         {
            if(!registrants)
            {
               registrants = new Dictionary();
            }
         }
         else
         {
            registrants = null;
         }
      }
      
      public static function getDumpRegistrantTraces() : String
      {
         var _loc8_:* = null;
         var _loc5_:* = null;
         var _loc2_:* = null;
         if(!registrants)
         {
            return "[ConcreteTexture] trace disabled";
         }
         var _loc3_:uint = 0;
         var _loc4_:Object = {};
         var _loc7_:Object = {};
         for(var _loc9_ in registrants)
         {
            _loc5_ = (_loc8_ = registrants[_loc9_]).substr(0,_loc8_.lastIndexOf("["));
            _loc2_ = _loc8_.substr(_loc8_.lastIndexOf("["));
            if(!_loc7_[_loc5_])
            {
               _loc7_[_loc5_] = 1;
               _loc4_[_loc5_] += _loc2_ + ",";
            }
            else
            {
               _loc7_[_loc5_]++;
               _loc4_[_loc5_] += _loc2_ + ",";
            }
            _loc3_++;
         }
         var _loc1_:String = "";
         var _loc10_:uint = 0;
         for(var _loc6_ in _loc7_)
         {
            _loc1_ += "[ConcreteTexture] registrants No." + _loc10_ + " -> count: " + _loc7_[_loc6_] + ", param:" + _loc4_[_loc6_] + " trace: " + _loc6_ + "\n";
            _loc10_++;
         }
         return _loc1_ + ("[ConcreteTexture] registrants count: " + _loc3_);
      }
      
      public static function getRegistrantCountText() : String
      {
         if(!registrants)
         {
            return "[ConcreteTexture] trace disabled";
         }
         var _loc2_:uint = 0;
         var _loc3_:Object = {};
         for(var _loc4_ in registrants)
         {
            _loc2_++;
         }
         return "[ConcreteTexture] registrants count: " + _loc2_;
      }
      
      public static function getRegistrantCount() : int
      {
         if(!registrants)
         {
            return -1;
         }
         var _loc1_:uint = 0;
         var _loc2_:Object = {};
         for(var _loc3_ in registrants)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public static function captureRegistrantTraces() : String
      {
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc1_:* = null;
         if(!capturedRegistrants)
         {
            capturedRegistrants = new Dictionary();
         }
         if(!registrants)
         {
            return "[ConcreteTexture] trace disabled";
         }
         var _loc2_:uint = 0;
         var _loc3_:Object = {};
         var _loc5_:Object = {};
         for(var _loc7_ in registrants)
         {
            _loc4_ = (_loc6_ = registrants[_loc7_]).substr(0,_loc6_.lastIndexOf("["));
            _loc1_ = _loc6_.substr(_loc6_.lastIndexOf("["));
            if(!_loc5_[_loc4_])
            {
               _loc5_[_loc4_] = 1;
               _loc3_[_loc4_] += _loc1_ + ",";
            }
            else
            {
               _loc5_[_loc4_]++;
               _loc3_[_loc4_] += _loc1_ + ",";
            }
            _loc2_++;
         }
         capturedRegistrants["data"] = _loc3_;
         capturedRegistrants["counts"] = _loc5_;
         capturedRegistrants["total"] = _loc2_;
         return "[ConcreteTexture] completed captureRegistrantTraces.";
      }
      
      public static function compareCapturedRegistrantTraces() : String
      {
         var _loc12_:* = null;
         var _loc5_:* = null;
         var _loc9_:* = null;
         var _loc3_:int = 0;
         if(!capturedRegistrants)
         {
            return "";
         }
         var _loc2_:uint = 0;
         var _loc4_:Object = {};
         var _loc11_:Object = {};
         for(var _loc13_ in registrants)
         {
            _loc5_ = (_loc12_ = registrants[_loc13_]).substr(0,_loc12_.lastIndexOf("["));
            _loc9_ = _loc12_.substr(_loc12_.lastIndexOf("["));
            if(!_loc11_[_loc5_])
            {
               _loc11_[_loc5_] = 1;
               _loc4_[_loc5_] += _loc9_ + ",";
            }
            else
            {
               _loc11_[_loc5_]++;
               _loc4_[_loc5_] += _loc9_ + ",";
            }
            _loc2_++;
         }
         var _loc1_:Object = capturedRegistrants["data"];
         var _loc10_:Object = capturedRegistrants["counts"];
         var _loc7_:int = capturedRegistrants["total"];
         var _loc8_:String = "[ConcreteTexture] diff registrants \n";
         var _loc14_:uint = 0;
         for(var _loc6_ in _loc11_)
         {
            if(_loc10_.hasOwnProperty(_loc6_))
            {
               _loc3_ = _loc11_[_loc6_] - _loc10_[_loc6_];
               if(_loc3_ > 0)
               {
                  _loc8_ += "[ConcreteTexture] registrants No." + _loc14_ + " -> count: " + _loc3_ + ", param:" + _loc4_[_loc6_] + " trace: " + _loc6_ + "\n";
                  _loc14_++;
               }
            }
            else
            {
               _loc8_ += "[ConcreteTexture] registrants No." + _loc14_ + " -> count: " + _loc11_[_loc6_] + ", param:" + _loc4_[_loc6_] + " trace: " + _loc6_ + "\n";
               _loc14_++;
            }
         }
         return _loc8_ + ("[ConcreteTexture] registrants count: " + _loc2_);
      }
      
      override public function dispose() : void
      {
         if(_base)
         {
            traceUnregister();
            _base.dispose();
         }
         this.onRestore = null;
         this.getBitmap = null;
         super.dispose();
      }
      
      public function uploadBitmap(param1:Bitmap, param2:* = null) : void
      {
         uploadBitmapData(param1.bitmapData,param2);
      }
      
      public function uploadBitmapData(param1:BitmapData, param2:* = null) : void
      {
         throw new NotSupportedError();
      }
      
      public function uploadAtfData(param1:ByteArray, param2:int = 0, param3:* = null) : void
      {
         throw new NotSupportedError();
      }
      
      public function attachNetStream(param1:NetStream, param2:Function = null) : void
      {
         attachVideo("NetStream",param1,param2);
      }
      
      public function attachCamera(param1:Camera, param2:Function = null) : void
      {
         attachVideo("Camera",param1,param2);
      }
      
      function attachVideo(param1:String, param2:Object, param3:Function = null) : void
      {
         throw new NotSupportedError();
      }
      
      private function onContextCreated() : void
      {
         _dataUploaded = false;
         _base = createBase();
         execute(_onRestore,this);
         if(!_dataUploaded)
         {
            clear();
         }
      }
      
      protected function createBase() : TextureBase
      {
         throw new AbstractMethodError();
      }
      
      function recreateBase() : void
      {
         _base = createBase();
      }
      
      public function clear(param1:uint = 0, param2:Number = 0.0) : void
      {
         if(_premultipliedAlpha && param2 < 1)
         {
            param1 = Color.rgb(Color.getRed(param1) * param2,Color.getGreen(param1) * param2,Color.getBlue(param1) * param2);
         }
         var _loc4_:* = Starling;
         var _loc3_:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         _loc3_.pushState();
         _loc3_.state.renderTarget = this;
         try
         {
            _loc3_.clear(param1,param2);
         }
         catch(e:Error)
         {
         }
         _loc3_.popState();
         setDataUploaded();
      }
      
      protected function setDataUploaded() : void
      {
         if(!_dataUploaded)
         {
            traceRegister();
         }
         _dataUploaded = true;
      }
      
      public function get optimizedForRenderTexture() : Boolean
      {
         return _optimizedForRenderTexture;
      }
      
      public function get isPotTexture() : Boolean
      {
         return false;
      }
      
      public function get onRestore() : Function
      {
         return _onRestore;
      }
      
      public function set onRestore(param1:Function) : void
      {
         if(restoreDisabled)
         {
            param1 = null;
         }
         var _loc2_:* = Starling;
         starling.core.Starling.sCurrent.removeEventListener("context3DCreate",onContextCreated);
         if(param1 != null)
         {
            _onRestore = param1;
            var _loc3_:* = Starling;
            starling.core.Starling.sCurrent.addEventListener("context3DCreate",onContextCreated);
         }
         else
         {
            _onRestore = null;
         }
      }
      
      public function get getBitmap() : Function
      {
         return _getBitmap;
      }
      
      public function set getBitmap(param1:Function) : void
      {
         if(restoreDisabled)
         {
            param1 = null;
         }
         _getBitmap = param1;
      }
      
      override public function get base() : TextureBase
      {
         return _base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return this;
      }
      
      override public function get format() : String
      {
         return _format;
      }
      
      override public function get width() : Number
      {
         return _width / _scale;
      }
      
      override public function get height() : Number
      {
         return _height / _scale;
      }
      
      override public function get nativeWidth() : Number
      {
         return _width;
      }
      
      override public function get nativeHeight() : Number
      {
         return _height;
      }
      
      override public function get scale() : Number
      {
         return _scale;
      }
      
      override public function get mipMapping() : Boolean
      {
         return _mipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return _premultipliedAlpha;
      }
      
      private function traceRegister() : void
      {
         if(!registrants)
         {
            return;
         }
         var _loc1_:String = TimeZoneUtil.getRuntimeElapsedTime();
         registrants[this] = new Error().getStackTrace() + "\n[t:" + _loc1_ + ",w:" + width + ",h:" + height + "]";
      }
      
      private function traceUnregister() : void
      {
         if(!registrants)
         {
            return;
         }
         delete registrants[this];
      }
   }
}
