package gudetama.engine
{
   import feathers.core.PopUpManager;
   import starling.display.Quad;
   import starling.display.Sprite;
   
   public class LoadingDialog extends Sprite
   {
      
      private static var instance:LoadingDialog;
      
      private static const CONTROL_LOADING:int = 0;
      
      private static const CONTROL_CONNECTION:int = 1;
      
      private static const CONTROL_NUM:int = 2;
       
      
      private var base:Sprite;
      
      private var loadingMode:Boolean;
      
      private var controls:Vector.<UIControl>;
      
      public function LoadingDialog()
      {
         controls = new Vector.<UIControl>(2);
         super();
         var _loc4_:* = Engine;
         var _loc2_:int = gudetama.engine.Engine.designWidth;
         var _loc5_:* = Engine;
         var _loc1_:int = gudetama.engine.Engine.designHeight;
         base = new Sprite();
         var _loc3_:Quad = new Quad(_loc2_,_loc1_);
         _loc3_.visible = false;
         base.addChild(_loc3_);
         controls[0] = new LoadingUI(base);
         controls[1] = new ConnectionUI(base);
         addChild(base);
      }
      
      public static function create() : void
      {
         if(gudetama.engine.LoadingDialog.instance)
         {
            return;
         }
         instance = new LoadingDialog();
      }
      
      public static function get initialized() : Boolean
      {
         return instance;
      }
      
      public static function resetLoadingText() : void
      {
      }
      
      public static function show() : void
      {
         if(!isShown())
         {
            instance.visible = true;
            PopUpManager.addPopUp(instance);
         }
         instance.show();
      }
      
      public static function hide() : void
      {
         instance.hide();
      }
      
      public static function isShown() : Boolean
      {
         return PopUpManager.isPopUp(instance) || PopUpManager.isTopLevelPopUp(instance);
      }
      
      public static function advanceTime(param1:Number) : void
      {
         instance.advanceTime(param1);
      }
      
      public static function set loadingMode(param1:Boolean) : void
      {
         instance.loadingMode = param1;
      }
      
      private function show() : void
      {
         setVisible(!!loadingMode ? 0 : 1);
      }
      
      private function setVisible(param1:int) : void
      {
         controls[param1].setVisible(true);
         controls[(param1 + 1) % controls.length].setVisible(false);
      }
      
      private function hide() : void
      {
         for each(var _loc1_ in controls)
         {
            _loc1_.stop();
         }
         visible = false;
         if(PopUpManager.isPopUp(this))
         {
            PopUpManager.removePopUp(this);
         }
      }
      
      private function advanceTime(param1:Number) : void
      {
         for each(var _loc2_ in controls)
         {
            _loc2_.advanceTime(param1);
         }
      }
      
      override public function dispose() : void
      {
         for each(var _loc1_ in controls)
         {
            _loc1_.dispose();
         }
         super.dispose();
      }
   }
}

interface UIControl
{
    
   
   function setVisible(param1:Boolean) : void;
   
   function stop() : void;
   
   function advanceTime(param1:Number) : void;
   
   function dispose() : void;
}

import starling.display.Sprite;

class LoadingUI implements UIControl
{
    
   
   function LoadingUI(param1:Sprite)
   {
      super();
   }
   
   public function setVisible(param1:Boolean) : void
   {
   }
   
   public function stop() : void
   {
   }
   
   public function advanceTime(param1:Number) : void
   {
   }
   
   public function dispose() : void
   {
   }
}

import gudetama.engine.EmbeddedAssets;
import gudetama.engine.Engine;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class ConnectionUI implements UIControl
{
   
   private static const ROTATE_TIME:Number = 5;
    
   
   private var circleImage:Image;
   
   private var movieClip3:MovieClip;
   
   private var passedTime:Number = 0;
   
   function ConnectionUI(param1:Sprite)
   {
      super();
      var _loc6_:* = Engine;
      var _loc4_:int = gudetama.engine.Engine.designWidth;
      var _loc7_:* = Engine;
      var _loc2_:int = gudetama.engine.Engine.designHeight;
      circleImage = new Image(Texture.fromBitmap(new EmbeddedAssets.Circle_png()));
      circleImage.x = 0.5 * _loc4_;
      circleImage.y = 0.5 * _loc2_;
      circleImage.pivotX = 0.5 * circleImage.width;
      circleImage.pivotY = 0.5 * circleImage.height;
      param1.addChild(circleImage);
      var _loc3_:XML = XML(new EmbeddedAssets.Loading3_xml());
      var _loc5_:TextureAtlas = new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.Loading3_png()),_loc3_);
      movieClip3 = new MovieClip(_loc5_.getTextures("loading_"),3);
      movieClip3.x = 0.5 * (_loc4_ - movieClip3.width);
      movieClip3.y = 0.5 * (_loc2_ - movieClip3.height);
      param1.addChild(movieClip3);
      var _loc8_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(movieClip3);
   }
   
   public function setVisible(param1:Boolean) : void
   {
      if(!param1)
      {
         circleImage.visible = false;
         movieClip3.visible = false;
         return;
      }
      circleImage.visible = true;
      movieClip3.play();
      movieClip3.visible = true;
   }
   
   public function stop() : void
   {
      movieClip3.stop();
   }
   
   public function advanceTime(param1:Number) : void
   {
      passedTime += param1;
      circleImage.rotation = 2 * 3.141592653589793 * passedTime / 5;
   }
   
   public function dispose() : void
   {
      circleImage = null;
      var _loc1_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(movieClip3);
      movieClip3 = null;
   }
}
