package starlingbuilder.engine
{
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import muku.core.MukuGlobal;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class UIElementFactory
   {
      
      public static const PARAMS:Object = {
         "x":1,
         "y":1,
         "width":2,
         "height":2,
         "scaleX":3,
         "scaleY":3,
         "rotation":4
      };
       
      
      protected var _assetMediator:IAssetMediator;
      
      protected var _forEditor:Boolean;
      
      public function UIElementFactory(param1:IAssetMediator, param2:Boolean = false)
      {
         super();
         _assetMediator = param1;
         _forEditor = param2;
      }
      
      public static function sortParams(param1:Array, param2:Object) : void
      {
         var array:Array = param1;
         var params:Object = param2;
         array.sort(function(param1:String, param2:String):int
         {
            var _loc3_:int = int(params[param1]) - int(params[param2]);
            if(_loc3_ != 0)
            {
               return _loc3_;
            }
            return param1 < param2 ? -1 : 1;
         });
      }
      
      protected function setDefaultParams(param1:Object, param2:Object) : void
      {
         if(!_forEditor)
         {
            if(param1 is Image)
            {
               param1.touchable = false;
            }
         }
      }
      
      protected function setDirectParams(param1:Object, param2:Object) : void
      {
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc4_:Array = [];
         for(_loc5_ in param2.params)
         {
            _loc4_.push(_loc5_);
         }
         sortParams(_loc4_,PARAMS);
         for each(_loc5_ in _loc4_)
         {
            _loc3_ = param2.params[_loc5_];
            if(_loc3_ && _loc3_.hasOwnProperty("cls"))
            {
               param1[_loc5_] = create(_loc3_);
            }
            else if(param1.hasOwnProperty(_loc5_))
            {
               param1[_loc5_] = _loc3_;
            }
         }
      }
      
      protected function setDefault(param1:Object, param2:Object) : void
      {
         setDefaultParams(param1,param2);
         setDirectParams(param1,param2);
      }
      
      private function createTexture(param1:Object) : Object
      {
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc8_:* = null;
         var _loc4_:* = null;
         var _loc9_:* = null;
         var _loc5_:* = null;
         var _loc2_:* = null;
         var _loc10_:* = null;
         var _loc7_:String;
         switch(_loc7_ = param1.cls)
         {
            case "starling.textures.Texture":
               if((_loc6_ = _assetMediator.getTexture(param1.textureName)) == null)
               {
                  throw new Error("Texture " + param1.textureName + " not found");
               }
               return _loc6_;
               break;
            case "feathers.textures.Scale3Textures":
               if((_loc6_ = _assetMediator.getTexture(param1.textureName)) == null)
               {
                  throw new Error("Texture " + param1.textureName + " not found");
               }
               _loc3_ = param1.scaleRatio;
               _loc9_ = "horizontal";
               if(_loc3_.length == 3)
               {
                  _loc9_ = _loc3_[2];
               }
               _loc8_ = getDefinitionByName("feathers.textures.Scale3Textures") as Class;
               if(_loc9_ == "horizontal")
               {
                  _loc5_ = new _loc8_(_loc6_,_loc6_.width * _loc3_[0],_loc6_.width * _loc3_[1],_loc9_);
               }
               else
               {
                  _loc5_ = new _loc8_(_loc6_,_loc6_.height * _loc3_[0],_loc6_.height * _loc3_[1],_loc9_);
               }
               return _loc5_;
               break;
            case "feathers.textures.Scale9Textures":
               if((_loc6_ = _assetMediator.getTexture(param1.textureName)) == null)
               {
                  throw new Error("Texture " + param1.textureName + " not found");
               }
               _loc3_ = param1.scaleRatio;
               _loc2_ = new Rectangle(_loc6_.width * _loc3_[0],_loc6_.height * _loc3_[1],_loc6_.width * _loc3_[2],_loc6_.height * _loc3_[3]);
               return new (_loc8_ = getDefinitionByName("feathers.textures.Scale9Textures") as Class)(_loc6_,_loc2_);
               break;
            case "__AS3__.vec.Vector.<starling.textures.Texture>":
               return _assetMediator.getTextures(param1.value);
            case "XML":
               if((_loc4_ = _assetMediator.getXml(param1.name)) == null)
               {
                  throw new Error("XML " + param1.name + " not found");
               }
               return _loc4_;
               break;
            case "Object":
               if((_loc4_ = _assetMediator.getObject(param1.name)) == null)
               {
                  throw new Error("Object " + param1.name + " not found");
               }
               return _loc4_;
               break;
            case "feathers.data.ListCollection":
               break;
            case "feathers.data.HierarchicalCollection":
               break;
            default:
               return null;
         }
         return new (_loc8_ = getDefinitionByName(_loc7_) as Class)(param1.data);
      }
      
      public function create(param1:Object) : Object
      {
         var _loc8_:* = null;
         var _loc10_:* = null;
         var _loc3_:* = undefined;
         var _loc7_:* = null;
         var _loc9_:Array = param1.constructorParams as Array;
         var _loc4_:Object;
         if(_loc4_ = createTexture(param1))
         {
            return _loc4_;
         }
         if(!_forEditor && param1.customParams && param1.customParams.customComponentClass && param1.customParams.customComponentClass != "null")
         {
            try
            {
               _loc10_ = getDefinitionByName(param1.customParams.customComponentClass) as Class;
            }
            catch(e:Error)
            {
               trace("Class " + param1.customParams.customComponentClass + " can\'t be instantiated.");
            }
         }
         if(!_loc10_)
         {
            _loc10_ = getDefinitionByName(param1.cls) as Class;
         }
         var _loc2_:Array = createArgumentsFromParams(_loc9_);
         if(param1.cls == "starling.display.MovieClip")
         {
            if(MukuGlobal.isBuilderMode())
            {
               param1.params["textureNames"] = null;
               param1.params["textureNamePrefix"] = "";
               for each(var _loc6_ in _loc9_)
               {
                  if(_loc6_.hasOwnProperty("cls"))
                  {
                     param1.params["textureNamePrefix"] = _loc6_.value;
                     _loc3_ = MukuGlobal.assetManager.getTextureNames(_loc6_.value);
                     _loc7_ = [];
                     for each(var _loc5_ in _loc3_)
                     {
                        _loc7_[_loc7_.length] = _loc5_;
                     }
                     param1.params["textureNames"] = _loc7_;
                  }
               }
            }
         }
         try
         {
            _loc8_ = createObjectFromClass(_loc10_,_loc2_);
         }
         catch(e:Error)
         {
            _loc8_ = createObjectFromClass(_loc10_,[]);
         }
         setDefault(_loc8_,param1);
         return _loc8_;
      }
      
      private function createObjectFromClass(param1:Class, param2:Array) : Object
      {
         switch(int(param2.length))
         {
            case 0:
               return new param1();
            case 1:
               return new param1(param2[0]);
            case 2:
               return new param1(param2[0],param2[1]);
            case 3:
               return new param1(param2[0],param2[1],param2[2]);
            case 4:
               return new param1(param2[0],param2[1],param2[2],param2[3]);
            case 5:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4]);
            case 6:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5]);
            case 7:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6]);
            case 8:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7]);
            case 9:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8]);
            default:
               throw new Error("Number of arguments not supported!");
         }
      }
      
      private function createArgumentsFromParams(param1:Array) : Array
      {
         var _loc2_:Array = [];
         for each(var _loc3_ in param1)
         {
            if(_loc3_.hasOwnProperty("cls"))
            {
               _loc2_.push(create(_loc3_));
            }
            else
            {
               _loc2_.push(_loc3_.value);
            }
         }
         return _loc2_;
      }
   }
}
