package gudetama.ui
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gudetama.engine.Engine;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import muku.util.StarlingUtil;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   
   public class PopupBalloon extends UIBase
   {
      
      private static var pool:Vector.<PopupBalloon> = new Vector.<PopupBalloon>(0);
      
      private static var shownPopupBalloonMap:Object = {};
      
      private static var BACKGROUND_RECTANGLE:Rectangle;
      
      private static var TEXTFIELD_RECTANGLE:Rectangle;
      
      private static var BASE_CORRECTION_SCALE:Number = 100;
       
      
      private var sprite:Sprite;
      
      private var background:Image;
      
      private var textField:ColorTextField;
      
      private var parent:Sprite;
      
      private var connectObject:DisplayObject;
      
      private var text:String;
      
      private var lastPoint:Point;
      
      public function PopupBalloon(param1:Sprite, param2:DisplayObject, param3:String, param4:Rectangle, param5:String)
      {
         var parent:Sprite = param1;
         var connectObject:DisplayObject = param2;
         var text:String = param3;
         var displayScreen:Rectangle = param4;
         var align:String = param5;
         super(null);
         var queue:TaskQueue = new TaskQueue();
         Engine.setupLayoutForTask(queue,"_PopupBalloon",function(param1:Object):void
         {
            displaySprite = param1.object;
            sprite = displaySprite.getChildByName("sprite") as Sprite;
            background = sprite.getChildByName("bg") as Image;
            textField = sprite.getChildByName("text") as ColorTextField;
            if(align)
            {
               textField.format.horizontalAlign = align;
               if(align == "center")
               {
                  textField.x /= 2;
               }
            }
            if(!BACKGROUND_RECTANGLE)
            {
               BACKGROUND_RECTANGLE = new Rectangle(background.x,background.y,background.width,background.height);
            }
            if(!TEXTFIELD_RECTANGLE)
            {
               TEXTFIELD_RECTANGLE = new Rectangle(textField.x,textField.y,textField.width,textField.height);
            }
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup(parent,connectObject,text,displayScreen);
         });
         queue.startTask();
      }
      
      public static function fromPool(param1:Sprite, param2:DisplayObject, param3:String, param4:Rectangle = null, param5:String = null) : void
      {
         var _loc6_:* = null;
         if(shownPopupBalloonMap[param3])
         {
            return;
         }
         if(pool.length)
         {
            (_loc6_ = pool.pop()).setup(param1,param2,param3,param4);
         }
         else
         {
            _loc6_ = new PopupBalloon(param1,param2,param3,param4,param5);
         }
         shownPopupBalloonMap[param3] = _loc6_;
      }
      
      public static function disposeCache() : void
      {
         for each(var _loc1_ in pool)
         {
            _loc1_.dispose();
         }
         pool.length = 0;
         for(var _loc2_ in shownPopupBalloonMap)
         {
            shownPopupBalloonMap[_loc2_].dispose();
            delete shownPopupBalloonMap[_loc2_];
         }
      }
      
      private function setup(param1:Sprite, param2:DisplayObject, param3:String, param4:Rectangle) : void
      {
         var parent:Sprite = param1;
         var connectObject:DisplayObject = param2;
         var text:String = param3;
         var displayScreen:Rectangle = param4;
         this.parent = parent;
         this.connectObject = connectObject;
         this.text = text;
         var _loc5_:* = Engine;
         textField.width = gudetama.engine.Engine.designWidth;
         var _loc6_:* = Engine;
         textField.height = gudetama.engine.Engine.designHeight;
         textField.text#2 = text;
         var textBounds:Rectangle = StarlingUtil.getRectangleFromPool();
         textBounds.setTo(textField.textBounds.x,textField.textBounds.y,textField.textBounds.width,textField.textBounds.height);
         textField.width = textBounds.width + (TEXTFIELD_RECTANGLE.width - textField.fontSize * getCorrectionTextScale());
         textField.height = textBounds.height + (TEXTFIELD_RECTANGLE.height - textField.fontSize * getCorrectionTextScale());
         background.width = textBounds.width + (BACKGROUND_RECTANGLE.width - textField.fontSize);
         background.height = textBounds.height + (BACKGROUND_RECTANGLE.height - textField.fontSize);
         var point:Point = Engine.getCoordGlobal(connectObject,0.5 * connectObject.width);
         lastPoint = new Point(point.x,point.y);
         var _loc8_:* = Engine;
         displaySprite.x = gudetama.engine.Engine._sceneX + lastPoint.x + 0.5 * (background.width - BACKGROUND_RECTANGLE.width);
         var _loc9_:* = Engine;
         displaySprite.y = gudetama.engine.Engine._sceneY + lastPoint.y + 0.5 * (background.height - BACKGROUND_RECTANGLE.height);
         displaySprite.pivotX = sprite.pivotX = 0.5 * background.width;
         displaySprite.pivotY = sprite.pivotY = 0.5 * background.height;
         fit(displayScreen);
         displaySprite.addEventListener("enterFrame",onEnterFrame);
         parent.addChild(displaySprite);
         setVisible(true);
         Engine.getPopupContainer().addChild(displaySprite);
         Engine.lockTouchInput(PopupBalloon);
         startTween("show",false,function():void
         {
            Engine.unlockTouchInput(PopupBalloon);
            Engine.addTouchStageCallback(onTouch);
         });
      }
      
      private function hide() : void
      {
         Engine.removeTouchStageCallback(onTouch);
         var thisObj:PopupBalloon = this;
         startTween("hide",false,function():void
         {
            if(!displaySprite)
            {
               return;
            }
            displaySprite.removeEventListener("enterFrame",onEnterFrame);
            parent.removeChild(displaySprite);
            setVisible(false);
            pool.push(thisObj);
            delete shownPopupBalloonMap[text];
         });
      }
      
      private function fit(param1:Rectangle) : void
      {
         var _loc3_:Rectangle = StarlingUtil.getRectangleFromPool();
         _loc3_.setTo(lastPoint.x - displaySprite.pivotX,lastPoint.y - displaySprite.pivotY,background.width,background.height);
         var _loc2_:* = param1;
         if(!_loc2_)
         {
            var _loc4_:* = Engine;
            var _loc5_:* = Engine;
            _loc2_ = new Rectangle(0,0,gudetama.engine.Engine.designWidth,gudetama.engine.Engine.designHeight);
         }
         if(_loc3_.x < _loc2_.x)
         {
            displaySprite.x += _loc2_.x - _loc3_.x;
         }
         if(_loc3_.x + _loc3_.width > _loc2_.x + _loc2_.width)
         {
            displaySprite.x += _loc2_.x + _loc2_.width - (_loc3_.x + _loc3_.width);
         }
         if(_loc3_.y < _loc2_.y)
         {
            displaySprite.y += _loc2_.y - _loc3_.y;
         }
         if(_loc3_.y + _loc3_.height > _loc2_.y + _loc2_.height)
         {
            displaySprite.y += _loc2_.y + _loc2_.height - (_loc3_.y + _loc3_.height);
         }
      }
      
      private function getCorrectionTextScale() : Number
      {
         var _loc5_:int = 0;
         var _loc6_:* = NaN;
         var _loc4_:* = 0;
         var _loc1_:* = null;
         var _loc2_:* = 0;
         var _loc3_:* = null;
         _loc5_ = text.length;
         _loc6_ = Number(BASE_CORRECTION_SCALE);
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc1_ = text.charAt(_loc4_);
            if(_loc1_ == "@" && _loc4_ + 2 < _loc5_ && text.charAt(_loc4_ + 1) == "[")
            {
               _loc2_ = int(text.indexOf("]",_loc4_ + 1));
               if(_loc2_ < 0)
               {
                  _loc2_ = _loc4_;
               }
               _loc3_ = text.substring(_loc4_ + 2,_loc2_);
               if(_loc3_.indexOf("SCALE") == 0)
               {
                  _loc6_ = Number(_loc6_ < Number(_loc3_.substr(5)) ? _loc6_ : Number(_loc3_.substr(5)));
               }
               _loc4_ = _loc2_;
            }
            _loc4_++;
         }
         if(_loc6_ < BASE_CORRECTION_SCALE / 2)
         {
            _loc6_ = 0;
         }
         _loc6_ /= 100;
         return Math.pow(_loc6_,2);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Point = Engine.getCoordGlobal(connectObject,0.5 * connectObject.width);
         displaySprite.x += _loc2_.x - lastPoint.x;
         displaySprite.y += _loc2_.y - lastPoint.y;
         lastPoint.x = _loc2_.x;
         lastPoint.y = _loc2_.y;
      }
      
      private function onTouch(param1:Touch) : void
      {
         if(param1.phase == "began")
         {
            hide();
         }
      }
      
      public function dispose() : void
      {
         displaySprite.removeEventListener("enterFrame",onEnterFrame);
         displaySprite = null;
         sprite = null;
         background = null;
         textField = null;
         parent = null;
         connectObject = null;
         text = null;
         lastPoint = null;
      }
   }
}
