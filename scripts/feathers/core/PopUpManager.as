package feathers.core
{
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public class PopUpManager
   {
      
      protected static const _starlingToPopUpManager:Dictionary = new Dictionary(true);
      
      public static var popUpManagerFactory:Function = defaultPopUpManagerFactory;
       
      
      public function PopUpManager()
      {
         super();
      }
      
      public static function defaultPopUpManagerFactory() : IPopUpManager
      {
         return new DefaultPopUpManager();
      }
      
      public static function forStarling(param1:Starling) : IPopUpManager
      {
         var _loc3_:* = null;
         if(!param1)
         {
            throw new ArgumentError("PopUpManager not found. Starling cannot be null.");
         }
         var _loc2_:IPopUpManager = _starlingToPopUpManager[param1];
         if(!_loc2_)
         {
            _loc3_ = PopUpManager.popUpManagerFactory;
            if(_loc3_ === null)
            {
               _loc3_ = PopUpManager.defaultPopUpManagerFactory;
            }
            _loc2_ = _loc3_();
            if(!_loc2_.root || !param1.stage.contains(_loc2_.root))
            {
               var _loc4_:* = Starling;
               _loc2_.root = starling.core.Starling.sCurrent.stage;
            }
            PopUpManager._starlingToPopUpManager[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public static function get overlayFactory() : Function
      {
         var _loc1_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).overlayFactory;
      }
      
      public static function set overlayFactory(param1:Function) : void
      {
         var _loc2_:* = Starling;
         PopUpManager.forStarling(starling.core.Starling.sCurrent).overlayFactory = param1;
      }
      
      public static function defaultOverlayFactory() : DisplayObject
      {
         return DefaultPopUpManager.defaultOverlayFactory();
      }
      
      public static function get root() : DisplayObjectContainer
      {
         var _loc1_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).root;
      }
      
      public static function set root(param1:DisplayObjectContainer) : void
      {
         var _loc2_:* = Starling;
         PopUpManager.forStarling(starling.core.Starling.sCurrent).root = param1;
      }
      
      public static function get popUpCount() : int
      {
         var _loc1_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).popUpCount;
      }
      
      public static function addPopUp(param1:DisplayObject, param2:Boolean = true, param3:Boolean = true, param4:Function = null) : DisplayObject
      {
         var _loc5_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).addPopUp(param1,param2,param3,param4);
      }
      
      public static function removePopUp(param1:DisplayObject, param2:Boolean = false) : DisplayObject
      {
         var _loc3_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).removePopUp(param1,param2);
      }
      
      public static function removeAllPopUps(param1:Boolean = false) : void
      {
         var _loc2_:* = Starling;
         PopUpManager.forStarling(starling.core.Starling.sCurrent).removeAllPopUps(param1);
      }
      
      public static function isPopUp(param1:DisplayObject) : Boolean
      {
         var _loc2_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).isPopUp(param1);
      }
      
      public static function isTopLevelPopUp(param1:DisplayObject) : Boolean
      {
         var _loc2_:* = Starling;
         return PopUpManager.forStarling(starling.core.Starling.sCurrent).isTopLevelPopUp(param1);
      }
      
      public static function centerPopUp(param1:DisplayObject) : void
      {
         var _loc2_:* = Starling;
         PopUpManager.forStarling(starling.core.Starling.sCurrent).centerPopUp(param1);
      }
   }
}
