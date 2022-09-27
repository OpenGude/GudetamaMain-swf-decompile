package feathers.controls
{
   import feathers.skins.IStyleProvider;
   import feathers.utils.display.getDisplayObjectDepthFromStage;
   import feathers.utils.display.stageToStarling;
   import flash.events.KeyboardEvent;
   import starling.core.Starling;
   import starling.events.Event;
   
   public class Screen extends LayoutGroup implements IScreen
   {
      
      public static const AUTO_SIZE_MODE_STAGE:String = "stage";
      
      public static const AUTO_SIZE_MODE_CONTENT:String = "content";
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var _screenID:String;
      
      protected var _owner:Object;
      
      protected var backButtonHandler:Function;
      
      protected var menuButtonHandler:Function;
      
      protected var searchButtonHandler:Function;
      
      public function Screen()
      {
         this.addEventListener("addedToStage",screen_addedToStageHandler);
         super();
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return Screen.globalStyleProvider;
      }
      
      public function get screenID() : String
      {
         return this._screenID;
      }
      
      public function set screenID(param1:String) : void
      {
         this._screenID = param1;
      }
      
      public function get owner() : Object
      {
         return this._owner;
      }
      
      public function set owner(param1:Object) : void
      {
         this._owner = param1;
      }
      
      protected function screen_addedToStageHandler(param1:Event) : void
      {
         if(param1.target != this)
         {
            return;
         }
         this.addEventListener("removedFromStage",screen_removedFromStageHandler);
         var _loc3_:int = -getDisplayObjectDepthFromStage(this);
         var _loc2_:Starling = stageToStarling(this.stage);
         _loc2_.nativeStage.addEventListener("keyDown",screen_nativeStage_keyDownHandler,false,_loc3_,true);
      }
      
      protected function screen_removedFromStageHandler(param1:Event) : void
      {
         if(param1.target != this)
         {
            return;
         }
         this.removeEventListener("removedFromStage",screen_removedFromStageHandler);
         var _loc2_:Starling = stageToStarling(this.stage);
         _loc2_.nativeStage.removeEventListener("keyDown",screen_nativeStage_keyDownHandler);
      }
      
      protected function screen_nativeStage_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(this.backButtonHandler != null && param1.keyCode == 16777238)
         {
            param1.preventDefault();
            this.backButtonHandler();
         }
         if(this.menuButtonHandler != null && param1.keyCode == 16777234)
         {
            param1.preventDefault();
            this.menuButtonHandler();
         }
         if(this.searchButtonHandler != null && param1.keyCode == 16777247)
         {
            param1.preventDefault();
            this.searchButtonHandler();
         }
      }
   }
}
