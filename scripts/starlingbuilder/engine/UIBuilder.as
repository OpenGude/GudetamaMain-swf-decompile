package starlingbuilder.engine
{
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.textures.Texture;
   import starlingbuilder.engine.format.DefaultDataFormatter;
   import starlingbuilder.engine.format.IDataFormatter;
   import starlingbuilder.engine.format.StableJSONEncoder;
   import starlingbuilder.engine.localization.DefaultLocalizationHandler;
   import starlingbuilder.engine.localization.ILocalization;
   import starlingbuilder.engine.localization.ILocalizationHandler;
   import starlingbuilder.engine.tween.ITweenBuilder;
   import starlingbuilder.engine.util.ObjectLocaterUtil;
   import starlingbuilder.engine.util.ParamUtil;
   import starlingbuilder.engine.util.SaveUtil;
   
   public class UIBuilder implements IUIBuilder
   {
      
      private static const RESOURCE_CLASSES:Array = ["XML","Object","feathers.data.ListCollection","feathers.data.HierarchicalCollection"];
      
      private static const notRoundable:Array = ["rotation","rotationX","rotationY","angle"];
       
      
      private var _assetMediator:IAssetMediator;
      
      private var _dataFormatter:IDataFormatter;
      
      private var _factory:UIElementFactory;
      
      private var _forEditor:Boolean;
      
      private var _template:Object;
      
      private var _localization:ILocalization;
      
      private var _localizationHandler:ILocalizationHandler;
      
      private var _displayObjectHandler:IDisplayObjectHandler;
      
      private var _tweenBuilder:ITweenBuilder;
      
      public function UIBuilder(param1:IAssetMediator, param2:Boolean = false, param3:Object = null, param4:ILocalization = null, param5:ITweenBuilder = null)
      {
         super();
         _assetMediator = param1;
         _dataFormatter = new DefaultDataFormatter();
         _factory = new UIElementFactory(_assetMediator,param2);
         _forEditor = param2;
         _template = param3;
         _localization = param4;
         _localizationHandler = new DefaultLocalizationHandler();
         _tweenBuilder = param5;
      }
      
      private static function removeDefault(param1:Object, param2:Array) : void
      {
         for each(var _loc3_ in param2)
         {
            if(ObjectLocaterUtil.get(param1,_loc3_.name) == _loc3_.default_value)
            {
               ObjectLocaterUtil.del(param1,_loc3_.name);
            }
         }
      }
      
      private static function willSaveProperty(param1:Object, param2:Object, param3:Object) : Boolean
      {
         if(!param1.hasOwnProperty(param2.name))
         {
            return false;
         }
         if(param2.default_value == "NaN" && isNaN(param1[param2.name]))
         {
            return false;
         }
         if(param2.read_only)
         {
            return false;
         }
         if(param2.default_value && "cls" in param2.default_value && ParamUtil.getClassName(param1[param2.name]) == param2.default_value.cls)
         {
            return false;
         }
         if(!SaveUtil.willSave(param1,param2,param3))
         {
            return false;
         }
         return param2.default_value == undefined || param2.default_value != param1[param2.name];
      }
      
      private static function doTrimLeadingSpace(param1:DisplayObjectContainer) : void
      {
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc2_:* = null;
         var _loc4_:* = 2147483647;
         var _loc3_:* = 2147483647;
         _loc6_ = 0;
         while(_loc6_ < param1.numChildren)
         {
            _loc2_ = (_loc5_ = param1.getChildAt(_loc6_)).getBounds(param1);
            if(_loc2_.x < _loc4_)
            {
               _loc4_ = Number(_loc2_.x);
            }
            if(_loc2_.y < _loc3_)
            {
               _loc3_ = Number(_loc2_.y);
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < param1.numChildren)
         {
            _loc5_.x = (_loc5_ = param1.getChildAt(_loc6_)).x - _loc4_;
            _loc5_.y -= _loc3_;
            _loc6_++;
         }
      }
      
      public static function cloneObject(param1:Object) : Object
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      public static function find(param1:DisplayObjectContainer, param2:String) : DisplayObject
      {
         var _loc4_:* = null;
         var _loc3_:Array = param2.split(".");
         for each(var _loc5_ in _loc3_)
         {
            if(param1 == null)
            {
               return null;
            }
            param1 = (_loc4_ = param1.getChildByName(_loc5_)) as DisplayObjectContainer;
         }
         return _loc4_;
      }
      
      public static function bind(param1:Object, param2:Dictionary) : void
      {
         var _loc4_:* = null;
         for(var _loc3_ in param2)
         {
            if("name" in _loc3_)
            {
               _loc4_ = _loc3_["name"];
            }
            else
            {
               _loc4_ = null;
            }
            if(_loc4_ && _loc4_.charAt(0) == "_")
            {
               if(!(_loc4_ in param1))
               {
                  throw new Error("Property name not defined: ",_loc4_);
               }
               param1[_loc4_] = _loc3_;
            }
         }
      }
      
      public static function findByTag(param1:String, param2:Dictionary) : Array
      {
         var _loc4_:* = null;
         var _loc3_:Array = [];
         for(var _loc5_ in param2)
         {
            if((_loc4_ = param2[_loc5_]) && _loc4_.customParams && _loc4_.customParams.tag == param1)
            {
               _loc3_.push(_loc5_);
            }
         }
         return _loc3_;
      }
      
      public function load(param1:Object, param2:Boolean = true, param3:Object = null) : Object
      {
         if(_dataFormatter)
         {
            param1 = _dataFormatter.read(param1);
         }
         var _loc5_:Dictionary = new Dictionary();
         var _loc4_:DisplayObject = loadTree(param1.layout,_factory,_loc5_);
         if(param2 && _loc4_ is DisplayObjectContainer)
         {
            doTrimLeadingSpace(_loc4_ as DisplayObjectContainer);
         }
         localizeTexts(_loc4_,_loc5_);
         if(param3)
         {
            bind(param3,_loc5_);
         }
         return {
            "object":_loc4_,
            "params":_loc5_,
            "data":param1
         };
      }
      
      private function loadTree(param1:Object, param2:UIElementFactory, param3:Dictionary) : DisplayObject
      {
         var _loc6_:* = null;
         var _loc8_:* = null;
         var _loc11_:* = null;
         var _loc9_:* = undefined;
         var _loc7_:int = 0;
         var _loc12_:* = null;
         var _loc10_:DisplayObject = param2.create(param1) as DisplayObject;
         param3[_loc10_] = param1;
         var _loc4_:DisplayObjectContainer;
         if(_loc4_ = _loc10_ as DisplayObjectContainer)
         {
            if(param1.children)
            {
               for each(var _loc5_ in param1.children)
               {
                  if(!(!_forEditor && _loc5_.customParams && _loc5_.customParams.forEditor))
                  {
                     _loc4_.addChild(loadTree(_loc5_,param2,param3));
                  }
               }
            }
            if(isExternalSource(param1))
            {
               _loc6_ = _dataFormatter.read(_assetMediator.getExternalData(param1.customParams.source));
               if(_forEditor)
               {
                  _loc4_.addChild(create(_loc6_,false) as DisplayObject);
                  param3[_loc10_] = param1;
               }
               else
               {
                  if((_loc8_ = load(_loc6_,false)).object is DisplayObjectContainer)
                  {
                     _loc11_ = _loc8_.object as DisplayObjectContainer;
                     _loc9_ = new Vector.<DisplayObject>();
                     _loc7_ = 0;
                     while(_loc7_ < _loc11_.numChildren)
                     {
                        _loc9_.push(_loc11_.getChildAt(_loc7_));
                        _loc7_++;
                     }
                     for each(var _loc14_ in _loc9_)
                     {
                        _loc4_.addChild(_loc14_);
                     }
                  }
                  _loc12_ = _loc8_.params as Dictionary;
                  for(var _loc13_ in _loc12_)
                  {
                     param3[_loc13_] = _loc12_[_loc13_];
                  }
               }
            }
         }
         if(_displayObjectHandler)
         {
            _displayObjectHandler.onCreate(_loc10_,param3);
         }
         return _loc10_;
      }
      
      public function save(param1:DisplayObjectContainer, param2:Object, param3:String, param4:Object = null) : Object
      {
         if(!_template)
         {
            throw new Error("template not found!");
         }
         var _loc5_:Object;
         (_loc5_ = {}).version = param3;
         _loc5_.layout = saveTree(param1.getChildAt(0),param2);
         _loc5_.setting = cloneObject(param4);
         if(_dataFormatter)
         {
            _loc5_ = _dataFormatter.write(_loc5_);
         }
         return _loc5_;
      }
      
      public function isContainer(param1:Object) : Boolean
      {
         if(param1 && ParamUtil.isContainer(_template,param1.cls) && !param1.customParams.source)
         {
            return true;
         }
         return false;
      }
      
      public function copy(param1:DisplayObject, param2:Object) : String
      {
         if(!_template)
         {
            throw new Error("template not found!");
         }
         return StableJSONEncoder.stringify(saveTree(param1,param2));
      }
      
      public function paste(param1:String) : Object
      {
         return {"layout":JSON.parse(param1)};
      }
      
      public function setExternalSource(param1:Object, param2:String) : void
      {
         param1.customParams.source = param2;
      }
      
      private function isExternalSource(param1:Object) : Boolean
      {
         if(param1 && param1.customParams && param1.customParams.source)
         {
            return true;
         }
         return false;
      }
      
      private function saveTree(param1:DisplayObject, param2:Object) : Object
      {
         var _loc5_:int = 0;
         var _loc4_:Object = saveElement(param1,ParamUtil.getParams(_template,param1),param2[param1]);
         var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc3_ && isContainer(param2[param1]))
         {
            _loc4_.children = [];
            _loc5_ = 0;
            while(_loc5_ < _loc3_.numChildren)
            {
               _loc4_.children.push(saveTree(_loc3_.getChildAt(_loc5_),param2));
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      private function saveElement(param1:Object, param2:Array, param3:Object) : Object
      {
         var _loc4_:* = null;
         var _loc5_:Object;
         (_loc5_ = {
            "params":{},
            "constructorParams":[],
            "customParams":{}
         }).cls = ParamUtil.getClassName(param1);
         if(param3)
         {
            _loc5_.constructorParams = cloneObject(param3.constructorParams);
            _loc5_.customParams = cloneObject(param3.customParams);
            if(param3.tweenData)
            {
               _loc5_.tweenData = cloneObject(param3.tweenData);
            }
            if(param3.effectData)
            {
               _loc5_.effectData = cloneObject(param3.effectData);
            }
            removeDefault(_loc5_,ParamUtil.getCustomParams(_template));
         }
         for each(var _loc6_ in param2)
         {
            if(willSaveProperty(param1,_loc6_,_loc5_))
            {
               if(_loc6_.hasOwnProperty("cls"))
               {
                  if(param1[_loc6_.name] is Texture || RESOURCE_CLASSES.indexOf(ParamUtil.getClassName(param1[_loc6_.name])) != -1)
                  {
                     _loc5_.params[_loc6_.name] = cloneObject(param3.params[_loc6_.name]);
                  }
                  else if(_loc4_ = param1[_loc6_.name])
                  {
                     _loc5_.params[_loc6_.name] = saveElement(_loc4_,ParamUtil.getParams(_template,_loc4_),cloneObject(param3.params[_loc6_.name]));
                  }
               }
               else
               {
                  saveProperty(_loc5_.params,param1,_loc6_.name);
               }
            }
         }
         return _loc5_;
      }
      
      private function isRoundable(param1:String) : Boolean
      {
         return notRoundable.indexOf(param1) < 0;
      }
      
      private function saveProperty(param1:Object, param2:Object, param3:String) : void
      {
         var _loc4_:Object;
         if((_loc4_ = param2[param3]) is Number && isRoundable(param3))
         {
            _loc4_ = roundToDigit(_loc4_ as Number);
         }
         param1[param3] = _loc4_;
      }
      
      private function roundToDigit(param1:Number, param2:int = 2) : Number
      {
         var _loc3_:Number = Math.pow(10,param2);
         return Math.round(param1 * _loc3_) / _loc3_;
      }
      
      public function createUIElement(param1:Object) : Object
      {
         return {
            "object":_factory.create(param1),
            "params":param1
         };
      }
      
      public function get dataFormatter() : IDataFormatter
      {
         return _dataFormatter;
      }
      
      public function set dataFormatter(param1:IDataFormatter) : void
      {
         _dataFormatter = param1;
      }
      
      public function create(param1:Object, param2:Boolean = true, param3:Object = null) : Object
      {
         return load(param1,param2,param3).object;
      }
      
      public function localizeTexts(param1:DisplayObject, param2:Dictionary) : void
      {
         if(_localization && _localization.locale)
         {
            localizeTree(param1,param2);
         }
      }
      
      private function localizeTree(param1:DisplayObject, param2:Dictionary) : void
      {
         var _loc5_:* = null;
         var _loc4_:int = 0;
         var _loc6_:Object;
         if((_loc6_ = param2[param1]) && _loc6_.customParams && _loc6_.customParams.localizeKey)
         {
            if((_loc5_ = _localization.getLocalizedText(_loc6_.customParams.localizeKey)) == null)
            {
               _loc5_ = _loc6_.customParams.localizeKey;
            }
            if(param1.hasOwnProperty("text"))
            {
               param1["text"] = _loc5_;
            }
            if(param1.hasOwnProperty("label"))
            {
               param1["label"] = _loc5_;
            }
            if(_localizationHandler)
            {
               _localizationHandler.localize(param1,_loc5_,param2,_localization.locale);
            }
         }
         var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               localizeTree(_loc3_.getChildAt(_loc4_),param2);
               _loc4_++;
            }
         }
      }
      
      public function get tweenBuilder() : ITweenBuilder
      {
         return _tweenBuilder;
      }
      
      public function set tweenBuilder(param1:ITweenBuilder) : void
      {
         _tweenBuilder = param1;
      }
      
      public function get localization() : ILocalization
      {
         return _localization;
      }
      
      public function set localization(param1:ILocalization) : void
      {
         _localization = param1;
      }
      
      public function get localizationHandler() : ILocalizationHandler
      {
         return _localizationHandler;
      }
      
      public function set localizationHandler(param1:ILocalizationHandler) : void
      {
         _localizationHandler = param1;
      }
      
      public function get displayObjectHandler() : IDisplayObjectHandler
      {
         return _displayObjectHandler;
      }
      
      public function set displayObjectHandler(param1:IDisplayObjectHandler) : void
      {
         _displayObjectHandler = param1;
      }
      
      public function get prettyData() : Boolean
      {
         return _dataFormatter.prettyData;
      }
      
      public function set prettyData(param1:Boolean) : void
      {
         _dataFormatter.prettyData = param1;
      }
   }
}
