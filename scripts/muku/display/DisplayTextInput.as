package muku.display
{
   import feathers.controls.TextInput;
   import feathers.core.ITextEditor;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.StageText;
   import flash.ui.Mouse;
   import muku.text.ColorTextField;
   import starling.animation.IAnimatable;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextFormat;
   import starling.textures.Texture;
   
   public class DisplayTextInput extends Sprite implements IAnimatable
   {
       
      
      private var stageText:StageText;
      
      private var hasForcus:Boolean;
      
      private var inputFieldImage:Image;
      
      private var textField:ColorTextField;
      
      private var orgText:String;
      
      private var inputMultiLine:Boolean = false;
      
      private var numMaxInputChars:int;
      
      private var finishInputCallback:Function;
      
      private var textInput:TextInput;
      
      private var keyboardRect:Rectangle;
      
      public function DisplayTextInput(param1:Texture)
      {
         super();
         inputFieldImage = new Image(param1);
         addChild(inputFieldImage);
         textField = new ColorTextField();
         textField.touchable = false;
         addChild(textField);
         inputFieldImage.addEventListener("touch",onTouch);
         keyboardRect = new Rectangle();
         textInput = new TextInput();
         textInput.touchable = false;
         textInput.backgroundSkin = new Quad(10,10,16777215);
         textInput.textEditorFactory = createTextEditorFunction();
         textInput.validate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      public function createTextEditorFunction() : Function
      {
         return function():ITextEditor
         {
            return new CustomTextEditor();
         };
      }
      
      public function setFinishInputCallback(param1:Function) : void
      {
         finishInputCallback = param1;
      }
      
      public function advanceTime(param1:Number) : void
      {
         if(!stageText)
         {
            return;
         }
         trace("DisplayTextInput.advanceTime(time)");
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         Mouse.cursor = !!param1.interactsWith(this) ? "button" : "auto";
         var _loc2_:Touch = param1.getTouch(this,"ended");
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.phase == "ended")
         {
            trace("DisplayTextInput.onTouch(event)");
            var _loc3_:* = Starling;
            starling.core.Starling.sCurrent.stage.addChild(textInput);
            textInput.y = 0;
            var _loc4_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this);
            textInput.setFocus();
         }
      }
      
      private function inputTextCallback(param1:Event) : void
      {
         trace("DisplayTextInput.inputTextCallback(event)");
      }
      
      private function finishInputProcess(param1:Boolean) : void
      {
         touchable = true;
         setRequiresRedraw();
      }
      
      public function get imageWidth() : Number
      {
         return inputFieldImage.width;
      }
      
      public function set imageWidth(param1:Number) : void
      {
         inputFieldImage.width = param1;
         setRequiresRedraw();
      }
      
      public function get imageHeight() : Number
      {
         return inputFieldImage.height;
      }
      
      public function set imageHeight(param1:Number) : void
      {
         inputFieldImage.height = param1;
         setRequiresRedraw();
      }
      
      public function get textX() : Number
      {
         return textField.x;
      }
      
      public function set textX(param1:Number) : void
      {
         textField.x = param1;
         setRequiresRedraw();
      }
      
      public function get textY() : Number
      {
         return textField.y;
      }
      
      public function set textY(param1:Number) : void
      {
         textField.y = param1;
         setRequiresRedraw();
      }
      
      public function get textWidth() : Number
      {
         return textField.width;
      }
      
      public function set textWidth(param1:Number) : void
      {
         textField.width = param1;
         setRequiresRedraw();
      }
      
      public function get textHeight() : Number
      {
         return textField.height;
      }
      
      public function set textHeight(param1:Number) : void
      {
         textField.height = param1;
         setRequiresRedraw();
      }
      
      public function get text#2() : String
      {
         return textField.text#2;
      }
      
      public function set text#2(param1:String) : void
      {
         textField.text#2 = param1;
         if(!orgText || orgText == "")
         {
            orgText = param1;
         }
      }
      
      public function get format() : TextFormat
      {
         return textField.format;
      }
      
      public function set format(param1:TextFormat) : void
      {
         textField.format = param1;
      }
      
      public function get fontSize() : Number
      {
         return textField.fontSize;
      }
      
      public function set fontSize(param1:Number) : void
      {
         textField.fontSize = param1;
      }
      
      public function get basefont() : String
      {
         return textField.basefont;
      }
      
      public function set basefont(param1:String) : void
      {
         textField.basefont = param1;
      }
      
      public function get outline() : Boolean
      {
         return textField.outline;
      }
      
      public function set outline(param1:Boolean) : void
      {
         textField.outline = param1;
      }
      
      public function get outlineColor() : int
      {
         return textField.outlineColor;
      }
      
      public function set outlineColor(param1:int) : void
      {
         textField.outlineColor = param1;
      }
      
      public function get outlineStrength() : Number
      {
         return textField.outlineStrength;
      }
      
      public function set outlineStrength(param1:Number) : void
      {
         textField.outlineStrength = param1;
      }
      
      public function get outlineBlur() : Number
      {
         return textField.outlineBlur;
      }
      
      public function set outlineBlur(param1:Number) : void
      {
         textField.outlineBlur = param1;
      }
      
      public function set onelineMode(param1:Boolean) : void
      {
         textField.onelineMode = param1;
      }
      
      public function get onelineMode() : Boolean
      {
         return textField.onelineMode;
      }
      
      public function set letterSpacing(param1:int) : void
      {
         textField.letterSpacing = param1;
      }
      
      public function get letterSpacing() : int
      {
         return textField.letterSpacing;
      }
      
      public function get inputMultiLineMode() : Boolean
      {
         return inputMultiLine;
      }
      
      public function set inputMultiLineMode(param1:Boolean) : void
      {
         inputMultiLine = param1;
      }
      
      public function get inputMaxChars() : int
      {
         return numMaxInputChars;
      }
      
      public function set inputMaxChars(param1:int) : void
      {
         numMaxInputChars = param1;
      }
      
      public function get inputFieldTexture() : Texture
      {
         return inputFieldImage.texture;
      }
      
      public function set inputFieldTexture(param1:Texture) : void
      {
         inputFieldImage.texture = param1;
         inputFieldImage.width = width;
         inputFieldImage.height = height;
         setRequiresRedraw();
      }
      
      public function get scale9Grid() : Rectangle
      {
         return inputFieldImage.scale9Grid;
      }
      
      public function set scale9Grid(param1:Rectangle) : void
      {
         inputFieldImage.scale9Grid = param1;
      }
      
      public function get keyboardType() : String
      {
         return "";
      }
      
      public function set keyboardType(param1:String) : void
      {
         if(!param1 || param1 == "null")
         {
         }
      }
   }
}

import feathers.controls.text.StageTextTextEditor;
import feathers.utils.geom.matrixToScaleX;
import feathers.utils.geom.matrixToScaleY;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.core.Starling;
import starling.display.Image;
import starling.text.TextFormat;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;
import starling.utils.MatrixUtil;
import starling.utils.Pool;

class CustomTextEditor extends StageTextTextEditor
{
    
   
   function CustomTextEditor()
   {
      super();
   }
   
   override protected function refreshViewPortAndFontSize() : void
   {
      var _loc2_:* = NaN;
      var _loc6_:* = NaN;
      var _loc13_:* = NaN;
      var _loc14_:* = null;
      var _loc22_:* = null;
      var _loc11_:* = null;
      var _loc9_:Matrix = Pool.getMatrix();
      var _loc10_:Point = Pool.getPoint();
      var _loc3_:* = 0;
      var _loc5_:* = 0;
      if(this._stageTextIsTextField)
      {
         _loc3_ = 2;
         _loc5_ = 4;
      }
      this.getTransformationMatrix(this.stage,_loc9_);
      if(this._stageTextHasFocus || this._updateSnapshotOnScaleChange)
      {
         _loc2_ = Number(matrixToScaleX(_loc9_));
         _loc6_ = Number(matrixToScaleY(_loc9_));
         _loc13_ = _loc2_;
         if(_loc6_ < _loc13_)
         {
            _loc13_ = _loc6_;
         }
      }
      else
      {
         _loc2_ = 1;
         _loc6_ = 1;
         _loc13_ = 1;
      }
      var _loc19_:Number = this.getVerticalAlignmentOffsetY();
      if(this.is3D)
      {
         _loc14_ = Pool.getMatrix3D();
         _loc22_ = Pool.getPoint3D();
         this.getTransformationMatrix3D(this.stage,_loc14_);
         MatrixUtil.transformCoords3D(_loc14_,-_loc3_,-_loc3_ + _loc19_,0,_loc22_);
         _loc10_.setTo(_loc22_.x,_loc22_.y);
         Pool.putPoint3D(_loc22_);
         Pool.putMatrix3D(_loc14_);
      }
      else
      {
         MatrixUtil.transformCoords(_loc9_,-_loc3_,-_loc3_ + _loc19_,_loc10_);
      }
      var _loc24_:*;
      var _loc12_:Starling = this.stage !== null ? this.stage.starling : (_loc24_ = Starling, starling.core.Starling.sCurrent);
      var _loc8_:* = 1;
      if(_loc12_.supportHighResolutions)
      {
         _loc8_ = Number(_loc12_.nativeStage.contentsScaleFactor);
      }
      var _loc4_:Rectangle = _loc12_.viewPort;
      var _loc21_:Rectangle;
      if(!(_loc21_ = this.stageText.viewPort))
      {
         _loc21_ = new Rectangle();
      }
      var _loc15_:Number = _loc12_.stage.stageHeight * _loc4_.width / _loc4_.height;
      var _loc7_:Number = _loc4_.width / _loc15_;
      var _loc16_:*;
      if((_loc16_ = Number(Math.round((this.actualWidth + _loc5_) * _loc7_ * _loc2_))) < 1 || _loc16_ !== _loc16_)
      {
         _loc16_ = 1;
      }
      var _loc23_:*;
      if((_loc23_ = Number(Math.round((this.actualHeight + _loc5_) * _loc7_ * _loc6_))) < 1 || _loc23_ !== _loc23_)
      {
         _loc23_ = 1;
      }
      _loc21_.width = _loc16_;
      _loc21_.height = _loc23_;
      var _loc17_:Number;
      if((_loc17_ = Math.round(_loc4_.x + _loc10_.x * _loc7_)) + _loc16_ > 8191)
      {
         _loc17_ = 8191 - _loc16_;
      }
      else if(_loc17_ < -8192)
      {
         _loc17_ = -8192;
      }
      var _loc20_:Number;
      if((_loc20_ = Math.round(_loc4_.y + _loc10_.y * _loc7_)) + _loc23_ > 8191)
      {
         _loc20_ = 8191 - _loc23_;
      }
      else if(_loc20_ < -8192)
      {
         _loc20_ = -8192;
      }
      _loc21_.x = _loc17_;
      _loc21_.y = _loc20_;
      this.stageText.viewPort = _loc21_;
      var _loc18_:int = 12;
      if(this._fontSize > 0)
      {
         _loc18_ = this._fontSize;
      }
      else if((_loc11_ = this._fontStyles.getTextFormatForTarget(this)) !== null)
      {
         if((_loc11_ = this._fontStyles.getTextFormatForTarget(this)) !== null)
         {
            _loc18_ = _loc11_.size;
         }
      }
      var _loc1_:int = _loc18_ * _loc7_ * _loc13_;
      if(this.stageText.fontSize != _loc1_)
      {
         this.stageText.fontSize = _loc1_;
      }
      Pool.putPoint(_loc10_);
      Pool.putMatrix(_loc9_);
   }
   
   override protected function refreshSnapshot() : void
   {
      var _loc5_:* = null;
      var _loc11_:* = null;
      var _loc4_:* = null;
      var _loc8_:Number = NaN;
      var _loc6_:Number = NaN;
      var _loc9_:* = null;
      var _loc13_:*;
      var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc13_ = Starling, starling.core.Starling.sCurrent);
      if(this.stage !== null && this.stageText.stage === null)
      {
         this.stageText.stage = _loc1_.nativeStage;
      }
      if(this.stageText.stage === null)
      {
         this.invalidate("data");
         return;
      }
      var _loc2_:Rectangle = this.stageText.viewPort;
      if(_loc2_.width == 0 || _loc2_.height == 0)
      {
         return;
      }
      var _loc10_:* = 1;
      if(_loc1_.supportHighResolutions)
      {
         _loc10_ = Number(_loc1_.nativeStage.contentsScaleFactor);
      }
      try
      {
         _loc5_ = new BitmapData(_loc2_.width * _loc10_,_loc2_.height * _loc10_,true,16711935);
         this.stageText.drawViewPortToBitmapData(_loc5_);
      }
      catch(error:Error)
      {
         _loc5_.dispose();
         _loc5_ = new BitmapData(_loc2_.width,_loc2_.height,true,16711935);
         this.stageText.drawViewPortToBitmapData(_loc5_);
      }
      if(!this.textSnapshot || this._needsNewTexture)
      {
         _loc4_ = _loc1_.viewPort;
         _loc8_ = _loc1_.stage.stageHeight * _loc4_.width / _loc4_.height;
         _loc6_ = _loc4_.width / _loc8_;
         (_loc11_ = Texture.empty(_loc5_.width / _loc6_,_loc5_.height / _loc6_,true,false,false,_loc6_)).root.uploadBitmapData(_loc5_);
         _loc11_.root.onRestore = texture_onRestore;
      }
      if(!this.textSnapshot)
      {
         this.textSnapshot = new Image(_loc11_);
         this.textSnapshot.pixelSnapping = true;
         this.addChild(this.textSnapshot);
      }
      else if(this._needsNewTexture)
      {
         this.textSnapshot.texture.dispose();
         this.textSnapshot.texture = _loc11_;
         this.textSnapshot.readjustSize();
      }
      else
      {
         (_loc9_ = this.textSnapshot.texture).root.uploadBitmapData(_loc5_);
         this.textSnapshot.setRequiresRedraw();
      }
      var _loc12_:Matrix = Pool.getMatrix();
      this.getTransformationMatrix(this.stage,_loc12_);
      var _loc3_:Number = matrixToScaleX(_loc12_);
      var _loc7_:Number = matrixToScaleY(_loc12_);
      Pool.putMatrix(_loc12_);
      if(this._updateSnapshotOnScaleChange)
      {
         this.textSnapshot.scaleX = 1 / _loc3_;
         this.textSnapshot.scaleY = 1 / _loc7_;
         this._lastGlobalScaleX = _loc3_;
         this._lastGlobalScaleY = _loc7_;
      }
      else
      {
         this.textSnapshot.scaleX = 1;
         this.textSnapshot.scaleY = 1;
      }
      if(_loc10_ > 1 && _loc5_.width == _loc2_.width)
      {
         this.textSnapshot.scaleX *= _loc10_;
         this.textSnapshot.scaleY *= _loc10_;
      }
      _loc5_.dispose();
      this._needsNewTexture = false;
   }
   
   override protected function texture_onRestore() : void
   {
      var _loc5_:*;
      var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc5_ = Starling, starling.core.Starling.sCurrent);
      var _loc2_:Rectangle = _loc1_.viewPort;
      var _loc4_:Number = _loc1_.stage.stageHeight * _loc2_.width / _loc2_.height;
      var _loc3_:Number = _loc2_.width / _loc4_;
      if(this.textSnapshot.texture.scale != _loc3_)
      {
         this.invalidate("size");
      }
      else
      {
         this.refreshSnapshot();
         if(this.textSnapshot)
         {
            this.textSnapshot.visible = !this._stageTextHasFocus;
            this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
         }
         if(!this._stageTextHasFocus)
         {
            this.stageText.visible = false;
         }
      }
   }
   
   override protected function layout(param1:Boolean) : void
   {
      var _loc2_:* = null;
      var _loc7_:* = null;
      var _loc9_:Number = NaN;
      var _loc8_:Number = NaN;
      var _loc4_:* = null;
      var _loc5_:* = null;
      var _loc12_:* = false;
      var _loc6_:Boolean = this.isInvalid("state");
      var _loc10_:Boolean = this.isInvalid("styles");
      var _loc11_:Boolean = this.isInvalid("data");
      var _loc3_:Boolean = this.isInvalid("skin");
      if(param1 || _loc10_ || _loc3_ || _loc6_)
      {
         var _loc13_:*;
         _loc2_ = this.stage !== null ? this.stage.starling : (_loc13_ = Starling, starling.core.Starling.sCurrent);
         _loc7_ = _loc2_.viewPort;
         _loc9_ = _loc2_.stage.stageHeight * _loc7_.width / _loc7_.height;
         _loc8_ = _loc7_.width / _loc9_;
         this.refreshViewPortAndFontSize();
         this.refreshMeasureTextFieldDimensions();
         _loc4_ = this.stageText.viewPort;
         _loc5_ = !!this.textSnapshot ? this.textSnapshot.texture.root : null;
         this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || _loc5_ !== null && (_loc5_.scale !== _loc8_ || _loc4_.width !== _loc5_.nativeWidth || _loc4_.height !== _loc5_.nativeHeight);
      }
      if(!this._stageTextHasFocus && (_loc6_ || _loc10_ || _loc11_ || param1 || this._needsNewTexture))
      {
         if(_loc12_ = this._text.length > 0)
         {
            this.refreshSnapshot();
         }
         if(this.textSnapshot)
         {
            this.textSnapshot.visible = !this._stageTextHasFocus;
            this.textSnapshot.alpha = !!_loc12_ ? 1 : 0;
         }
         this.stageText.visible = false;
      }
      this.doPendingActions();
   }
}
