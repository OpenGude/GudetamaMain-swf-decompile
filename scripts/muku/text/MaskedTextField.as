package muku.text
{
   import flash.geom.Point;
   import muku.core.MukuGlobal;
   import starling.display.MeshBatch;
   import starling.text.TextOptions;
   
   public class MaskedTextField extends ColorTextField
   {
       
      
      private var charLocations:Vector.<CharLocationInfo>;
      
      private var updateOnlyQuad:Boolean = false;
      
      private var currPos:int = 0;
      
      private var requestQueue:Vector.<int> = null;
      
      public function MaskedTextField(param1:int = 100, param2:int = 32, param3:String = "", param4:String = "Verdana", param5:Number = 24, param6:uint = 0, param7:Boolean = false)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
      }
      
      override public function updateValuesFrom(param1:ColorTextField) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         super.updateValuesFrom(param1);
         recompose();
         var _loc4_:MaskedTextField = param1 as MaskedTextField;
         if(charLocations && _loc4_.charLocations)
         {
            _loc3_ = charLocations.length;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               charLocations[_loc2_].visible = _loc4_.charLocations[_loc2_].visible;
               _loc2_++;
            }
         }
      }
      
      private function addRequest(param1:int) : void
      {
         if(requestQueue == null)
         {
            requestQueue = new Vector.<int>();
         }
         requestQueue[requestQueue.length] = param1;
         setRequiresRecomposition();
      }
      
      private function getCharLocationInfo(param1:int, param2:Boolean = true) : CharLocationInfo
      {
         for each(var _loc3_ in charLocations)
         {
            if(_loc3_.idx == param1)
            {
               return _loc3_;
            }
            if(_loc3_.idx > param1)
            {
               return !!param2 ? null : _loc3_;
            }
         }
         return null;
      }
      
      public function showCharAt(param1:int) : void
      {
         var _loc2_:* = null;
         if(charLocations)
         {
            _loc2_ = getCharLocationInfo(param1);
            if(_loc2_)
            {
               _loc2_.visible = true;
               setRequiresRecomposition();
               updateOnlyQuad = true;
            }
         }
         else
         {
            addRequest(param1);
         }
      }
      
      public function hideCharAt(param1:int) : void
      {
         var _loc2_:* = null;
         if(charLocations)
         {
            _loc2_ = getCharLocationInfo(param1);
            if(_loc2_)
            {
               _loc2_.visible = false;
               setRequiresRecomposition();
               updateOnlyQuad = true;
            }
         }
      }
      
      public function showCharAll() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(charLocations)
         {
            _loc2_ = charLocations.length;
            _loc1_ = 0;
            while(_loc1_ < _loc2_)
            {
               charLocations[_loc1_].visible = true;
               _loc1_++;
            }
            setRequiresRecomposition();
            updateOnlyQuad = true;
         }
         else
         {
            addRequest(-1);
         }
      }
      
      public function hideCharAll() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(charLocations)
         {
            _loc2_ = charLocations.length;
            _loc1_ = 0;
            while(_loc1_ < _loc2_)
            {
               charLocations[_loc1_].visible = false;
               _loc1_++;
            }
            setRequiresRecomposition();
            updateOnlyQuad = true;
         }
      }
      
      private function disposeCharLocation() : void
      {
         if(charLocations)
         {
            CharLocationInfo.vectorInstanceToPool(charLocations);
            CharLocationInfo.vectorToPool(charLocations);
         }
      }
      
      private function createComposedContents2(param1:PartialBitmapFont) : void
      {
         var _loc2_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:* = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         if(requiresRedraw || mNeedsArrange || charLocations == null)
         {
            _loc2_ = _hitArea.width;
            _loc7_ = _hitArea.height;
            mNeedsArrange = false;
            disposeCharLocation();
            format.size = fontSize;
            _loc8_ = new TextOptions(true,autoScale);
            charLocations = param1.layoutText(_loc2_,_loc7_,mRawText,format,_loc8_);
         }
         if(_meshBatch == null)
         {
            _meshBatch = new MeshBatch();
            _meshBatch.touchable = false;
            addChild(_meshBatch);
         }
         else
         {
            _meshBatch.clear();
         }
         if(!MukuGlobal.isBuilderMode())
         {
            _loc5_ = charLocations.length;
            _loc3_ = 0;
            while(_loc3_ < _loc5_)
            {
               charLocations[_loc3_].visible = false;
               _loc3_++;
            }
            currPos = -1;
            if(requestQueue)
            {
               for each(var _loc4_ in requestQueue)
               {
                  if(_loc4_ <= -1)
                  {
                     _loc3_ = 0;
                     while(_loc3_ < _loc5_)
                     {
                        charLocations[_loc3_].visible = true;
                        _loc3_++;
                     }
                     currPos = _loc5_;
                  }
                  else
                  {
                     for each(var _loc6_ in charLocations)
                     {
                        if(_loc6_.idx == _loc4_)
                        {
                           _loc6_.visible = false;
                           setRequiresRecomposition();
                           updateOnlyQuad = true;
                           break;
                        }
                     }
                  }
               }
            }
            requestQueue = null;
         }
         else
         {
            currPos = charLocations.length;
         }
         param1.applyMeshBatch(_meshBatch,charLocations);
         _meshBatch.batchable = false;
         _textBounds = null;
      }
      
      private function updateQuad() : void
      {
         if(_meshBatch == null)
         {
            _meshBatch = new _meshBatch();
            _meshBatch.touchable = false;
            addChild(_meshBatch);
         }
         else
         {
            _meshBatch.clear();
         }
         var _loc1_:PartialBitmapFont = getBitmapFont(fontName) as PartialBitmapFont;
         _loc1_.applyMeshBatch(_meshBatch,charLocations);
         _meshBatch.batchable = false;
         _textBounds = null;
      }
      
      override protected function recompose() : void
      {
         if(_requiresRecomposition)
         {
            if(updateOnlyQuad && charLocations)
            {
               updateQuad();
            }
            else
            {
               createComposedContents2(checkBitmapFont());
            }
            updateBorder();
            _requiresRecomposition = false;
            updateOnlyQuad = false;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(charLocations)
         {
            disposeCharLocation();
            charLocations = null;
         }
         updateOnlyQuad = false;
         requestQueue = null;
      }
      
      override public function set text#2(param1:String) : void
      {
         if(charLocations)
         {
            disposeCharLocation();
            charLocations = null;
         }
         updateOnlyQuad = false;
         requestQueue = null;
         super.text#2 = param1;
      }
      
      public function getCharPoint(param1:int, param2:Point) : Point
      {
         var _loc3_:* = null;
         if(charLocations)
         {
            _loc3_ = getCharLocationInfo(param1,false);
            if(_loc3_)
            {
               param2.setTo(_loc3_.x + fontSize / 2,_loc3_.y + fontSize / 2);
            }
         }
         return param2;
      }
      
      override public function set autoSize(param1:String) : void
      {
      }
      
      override public function set batchable(param1:Boolean) : void
      {
      }
      
      public function set showPos(param1:Number) : void
      {
         var _loc2_:int = param1;
         if(currPos == _loc2_)
         {
            return;
         }
         currPos = _loc2_;
         if(_loc2_ < 0)
         {
            hideCharAll();
         }
         else
         {
            showCharAt(_loc2_);
         }
      }
      
      public function get showPos() : Number
      {
         return currPos;
      }
   }
}
