package gudetama.ui
{
   import avmplus.getQualifiedClassName;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.Engine;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.kitchen.CookingScene;
   import gudetama.util.GudeActUtil;
   import gudetama.util.StringUtil;
   import starling.display.Sprite;
   
   public class RecipeMakeButton extends UIBase
   {
       
      
      private var states:int;
      
      private var state:int;
      
      private var displaySprite:Sprite;
      
      private var backButtonCallback:Function;
      
      private var targetType:int;
      
      private var targetId:int;
      
      private var recipeNoteId:int;
      
      private var lock:Boolean;
      
      private var enable:Boolean;
      
      private var isCook:Boolean;
      
      private var stateEnable:Boolean = false;
      
      private var currentstate:int;
      
      public function RecipeMakeButton(param1:Sprite, param2:int, param3:Function, param4:Boolean)
      {
         displaySprite = param1;
         super(displaySprite);
         this.states = param2;
         this.backButtonCallback = param3;
         this.stateEnable = param4;
         displaySprite.addEventListener("triggered",triggeredCookingButton);
      }
      
      public function setup(param1:int, param2:int, param3:int, param4:Boolean = false, param5:Boolean = false, param6:Boolean = true) : void
      {
         targetType = param1;
         targetId = param2;
         recipeNoteId = param3;
         this.lock = param4;
         this.enable = param5;
         this.isCook = param6;
         if(param1 == 0)
         {
            state = GudeActUtil.checkState(param2,states,param4,param5,param6);
            if((state & 2) != 0)
            {
               startTween("lock");
            }
            else if(state != 0)
            {
               startTween("disable");
            }
            else
            {
               startTween("enable");
            }
         }
         else if(!UserDataWrapper.recipeNotePart.isAvailable(param3))
         {
            startTween("lock");
         }
         else
         {
            startTween("enable");
         }
         if(stateEnable)
         {
            startTween("enable");
         }
         finishTween();
      }
      
      private function triggeredCookingButton() : void
      {
         if(targetType == 0)
         {
            cookGudetama();
         }
         else
         {
            moveToCookingSceneRecipe();
         }
      }
      
      private function cookGudetama() : void
      {
         var _loc4_:* = null;
         var _loc1_:* = null;
         var _loc2_:GudetamaDef = GameSetting.getGudetama(targetId);
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(_loc2_.recipeNoteId);
         if((state & 1) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.uncountable.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 16) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.uncountable.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 32) != 0)
         {
            if(!(_loc4_ = !!_loc3_ ? GameSetting.getKitchenware(_loc3_.kitchenwareId) : null) && _loc2_.kitchenwareId > 0)
            {
               _loc4_ = GameSetting.getKitchenware(_loc2_.kitchenwareId);
            }
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.cooking.needAvailableKitchenware.desc"),_loc4_.name#2),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 64) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.outOfTerm.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 128) != 0)
         {
            _loc3_ = GameSetting.getRecipeNote(_loc2_.recipeNoteId);
            if(!_loc3_.premises || _loc3_.premises.length == 0)
            {
               return;
            }
            _loc1_ = GameSetting.getRecipeNote(_loc3_.premises[0]);
            backButtonCallback();
            LockedRecipeNoteDialog.show(_loc3_.id#2);
         }
         else if((state & 256) != 0)
         {
            backButtonCallback();
            LockedRecipeNoteDialog.show(_loc2_.recipeNoteId);
         }
         else if((state & 512) != 0)
         {
            showPurchaseRecipeDialog(_loc2_.recipeNoteId);
         }
         else if((state & 1024) != 0)
         {
            backButtonCallback();
            LockedRecipeDialog.show(targetId);
         }
         else
         {
            moveToCookingScene();
         }
      }
      
      private function showRecipeNote(param1:int) : void
      {
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(param1);
         if(!_loc3_.premises || _loc3_.premises.length == 0)
         {
            return;
         }
         var _loc2_:RecipeNoteDef = GameSetting.getRecipeNote(_loc3_.premises[0]);
         backButtonCallback();
         LockedRecipeNoteDialog.show(_loc3_.id#2);
      }
      
      private function moveToCookingScene() : void
      {
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(targetId);
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
         if(!kitchenwareDef && gudetamaDef.kitchenwareId > 0)
         {
            kitchenwareDef = GameSetting.getKitchenware(gudetamaDef.kitchenwareId);
         }
         var isHappening:Boolean = UserDataWrapper.gudetamaPart.isHappening(targetId);
         var isFailure:Boolean = UserDataWrapper.gudetamaPart.isFailure(targetId);
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2
         };
         if(!isFailure)
         {
            param["recipeNoteId"] = recipeNoteDef.id#2;
            if(!isHappening)
            {
               param["gudetamaId"] = gudetamaDef.id#2;
            }
         }
         if(UserDataWrapper.kitchenwarePart.isCooking(kitchenwareDef.type))
         {
            LocalMessageDialog.show(1,GameSetting.getUIText("gudetamaShortage.cooking.alreadyCooking.desc"),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               changeScene(kitchenwareDef.type,param);
            },GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else
         {
            changeScene(kitchenwareDef.type,param);
         }
      }
      
      private function moveToCookingSceneRecipe() : void
      {
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(targetId);
         if(!UserDataWrapper.recipeNotePart.isPurchased(recipeNoteDef.id#2))
         {
            backButtonCallback();
            if(!UserDataWrapper.recipeNotePart.isPurchased(recipeNoteDef.id#2) && UserDataWrapper.recipeNotePart.isVisible(recipeNoteDef.id#2) && UserDataWrapper.recipeNotePart.isAvailable(recipeNoteDef.id#2))
            {
               showPurchaseRecipeDialog(recipeNoteDef.id#2);
            }
            else
            {
               LockedRecipeNoteDialog.show(recipeNoteDef.id#2);
            }
            return;
         }
         var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
         if(!kitchenwareDef)
         {
            return;
         }
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2
         };
         param["recipeNoteId"] = recipeNoteDef.id#2;
         if(UserDataWrapper.kitchenwarePart.isCooking(kitchenwareDef.type))
         {
            LocalMessageDialog.show(1,GameSetting.getUIText("gudetamaShortage.cooking.alreadyCooking.desc"),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               changeScene(kitchenwareDef.type,param);
            },GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else
         {
            changeScene(kitchenwareDef.type,param);
         }
      }
      
      private function showPurchaseRecipeDialog(param1:int) : void
      {
         var _id:int = param1;
         currentstate = ResidentMenuUI_Gudetama.getInstance().getCurrentSate();
         chageSceneState(141,function():void
         {
            PurchaseRecipeDialog.show(_id,function(param1:Boolean):void
            {
               var _close:Boolean = param1;
               chageSceneState(currentstate,function():void
               {
                  AcquiredKitchenwareDialog.show(function():void
                  {
                     AcquiredRecipeNoteDialog.show(function():void
                     {
                        var _loc2_:* = null;
                        var _loc3_:* = null;
                        var _loc1_:* = null;
                        if(!_close)
                        {
                           _loc2_ = GameSetting.getRecipeNote(_id);
                           _loc3_ = !!_loc2_ ? GameSetting.getKitchenware(_loc2_.kitchenwareId) : null;
                           if(!_loc3_)
                           {
                              return;
                           }
                           _loc1_ = {
                              "kitchenwareType":_loc3_.type,
                              "kitchenwareId":_loc3_.id#2
                           };
                           _loc1_["recipeNoteId"] = _loc2_.id#2;
                           if(targetType == 0)
                           {
                              _loc1_["gudetamaId"] = targetId;
                           }
                           changeScene(_loc3_.type,_loc1_);
                        }
                     });
                  });
                  if(targetType == 0)
                  {
                     state = GudeActUtil.checkState(targetId,states,lock,enable,isCook);
                  }
                  setup(targetType,targetId,recipeNoteId,false,false,true);
               });
            },true);
         });
      }
      
      private function chageSceneState(param1:int, param2:Function) : void
      {
         var _state:int = param1;
         var _callback:Function = param2;
         if(_state == ResidentMenuUI_Gudetama.getInstance().getCurrentSate())
         {
            _callback();
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(_state,function():void
         {
            _callback();
         },false);
      }
      
      private function changeScene(param1:int, param2:Object) : void
      {
         var _type:int = param1;
         var _param:Object = param2;
         var cookingScene:CookingScene = Engine.getScene(getQualifiedClassName(CookingScene)) as CookingScene;
         if(GameSetting.getRule().cookingShortCut && cookingScene)
         {
            backButtonCallback();
            if(GameSetting.getRule().memoryCookingRecipe)
            {
               cookingScene.changePageAnimeWithMemory(_type,false,_param);
            }
            else
            {
               cookingScene.changePageAnime(_type,false,_param);
            }
         }
         else
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
            {
               Engine.switchScene(new HomeScene(_type,_param));
            });
         }
      }
      
      public function dispose() : void
      {
         displaySprite.removeEventListener("triggered",triggeredCookingButton);
      }
      
      public function set visible(param1:*) : void
      {
         displaySprite.visible = param1;
      }
   }
}
