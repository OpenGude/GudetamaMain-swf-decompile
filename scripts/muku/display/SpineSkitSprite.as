package muku.display
{
   import muku.core.MukuGlobal;
   import starling.display.DisplayObject;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class SpineSkitSprite extends Sprite
   {
       
      
      private var skitModelList:Vector.<SpineModel>;
      
      private var currentState:String;
      
      private var showed:Boolean;
      
      public var finishedCallback:Function;
      
      public function SpineSkitSprite()
      {
         super();
         showed = false;
         skitModelList = new Vector.<SpineModel>();
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         var child:DisplayObject = param1;
         var index:int = param2;
         if(child is SpineModel)
         {
            var model:SpineModel = child as SpineModel;
            skitModelList.push(model);
            model.addEventListener("finished",function(param1:Event):void
            {
               var _loc2_:SpineModel = param1.target as SpineModel;
               _loc2_.finish();
               skitModelList.splice(skitModelList.indexOf(_loc2_),1);
               if(skitModelList.length <= 0)
               {
                  finish();
                  if(finishedCallback)
                  {
                     finishedCallback();
                  }
               }
            });
         }
         return super.addChildAt(child,index);
      }
      
      override public function removeChild(param1:DisplayObject, param2:Boolean = false) : DisplayObject
      {
         var _loc3_:int = 0;
         if(MukuGlobal.isBuilderMode() && param1 is SpineModel)
         {
            _loc3_ = skitModelList.indexOf(param1 as SpineModel);
            skitModelList.splice(_loc3_,1);
         }
         return super.removeChild(param1,param2);
      }
      
      override public function dispose() : void
      {
         if(!MukuGlobal.isBuilderMode() && skitModelList)
         {
            skitModelList.length = 0;
            skitModelList = null;
         }
         super.dispose();
      }
      
      public function show() : void
      {
         var _loc1_:* = null;
         for each(_loc1_ in skitModelList)
         {
            if(_loc1_.containsAnimation(state))
            {
               _loc1_.show();
               _loc1_.changeAnimation(currentState,true);
            }
            else
            {
               _loc1_.hide();
            }
         }
         showed = true;
      }
      
      public function finish(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = numChildren;
            _loc3_ = _loc2_ - 1;
            while(_loc3_ >= 0)
            {
               (getChildAt(_loc3_) as SpineSkitModel).finish();
               _loc3_--;
            }
         }
         if(!MukuGlobal.isBuilderMode())
         {
            removeFromParent(true);
         }
         showed = false;
      }
      
      public function changeAnimation(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         var _loc4_:* = null;
         for each(_loc4_ in skitModelList)
         {
            if(_loc4_.containsAnimation(param1))
            {
               if(!_loc4_.isShown())
               {
                  _loc4_.show();
               }
               _loc4_.changeAnimation(param1,param2,param3);
            }
            else
            {
               _loc4_.hide();
            }
         }
         currentState = param1;
      }
      
      public function appendAnimation(param1:String, param2:int = 0, param3:Number = 0, param4:Function = null) : void
      {
         var _loc5_:* = null;
         for each(_loc5_ in skitModelList)
         {
            if(_loc5_.containsAnimation(param1))
            {
               if(!_loc5_.isShown())
               {
                  _loc5_.show();
               }
               _loc5_.appendAnimation(param1,param2,param3,param4);
            }
         }
      }
      
      public function get state() : String
      {
         return currentState;
      }
      
      public function set state(param1:String) : void
      {
         var _loc2_:* = null;
         if(currentState == param1)
         {
            return;
         }
         if(skitModelList.length > 0 && showed)
         {
            for each(_loc2_ in skitModelList)
            {
               if(_loc2_.containsAnimation(param1))
               {
                  if(!_loc2_.isShown())
                  {
                     _loc2_.show();
                  }
                  _loc2_.changeAnimation(param1,true);
               }
               else
               {
                  _loc2_.hide();
               }
            }
         }
         currentState = param1;
      }
   }
}
