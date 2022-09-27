package gudetama.ui
{
   import feathers.controls.renderers.LayoutGroupListItemRenderer;
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   
   public class PresentLogListItemRenderer extends LayoutGroupListItemRenderer
   {
       
      
      private var extractor:SpriteExtractor;
      
      private var enabledDetail:Boolean;
      
      private var callback:Function;
      
      private var displaySprite:Sprite;
      
      private var presentLogUI:PresentLogUI;
      
      public function PresentLogListItemRenderer(param1:SpriteExtractor, param2:Boolean, param3:Function = null)
      {
         super();
         this.extractor = param1;
         this.enabledDetail = param2;
         this.callback = param3;
      }
      
      override protected function initialize() : void
      {
         if(displaySprite)
         {
            return;
         }
         displaySprite = extractor.duplicateAll() as Sprite;
         presentLogUI = new PresentLogUI(displaySprite,enabledDetail,callback);
         addChild(displaySprite);
      }
      
      override protected function commitData() : void
      {
         presentLogUI.updateData(data#2);
      }
      
      override public function dispose() : void
      {
         extractor = null;
         callback = null;
         displaySprite = null;
         presentLogUI.dispose();
         presentLogUI = null;
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.PresentLogData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class PresentLogUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var iconImage:Image;
   
   private var imgSns:Image;
   
   private var levelText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var timeText:ColorTextField;
   
   private var messageText:ColorTextField;
   
   private var detailButton:ContainerButton;
   
   private var encodedUid:int;
   
   function PresentLogUI(param1:Sprite, param2:Boolean, param3:Function)
   {
      super(param1);
      this.callback = param3;
      iconImage = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      levelText = param1.getChildByName("level") as ColorTextField;
      nameText = param1.getChildByName("name") as ColorTextField;
      timeText = param1.getChildByName("time") as ColorTextField;
      messageText = param1.getChildByName("message") as ColorTextField;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
      detailButton.visible = param2;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      encodedUid = data.encodedUid;
      var targetPlayerName:String = data.name;
      var presentLog:PresentLogData = data.presentLog as PresentLogData;
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(presentLog.itemId);
      iconImage.visible = false;
      imgSns.visible = false;
      if(presentLog.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(presentLog.snsProfileImage,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         TextureCollector.loadSnsImage(presentLog.snsType,null,function(param1:Texture):void
         {
            if(param1 != null)
            {
               imgSns.texture = param1;
               imgSns.visible = true;
            }
         });
      }
      else
      {
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(presentLog.avatar).rsrc,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
      }
      levelText.text#2 = presentLog.playerRank.toString();
      nameText.text#2 = presentLog.playerName;
      var date:Date = new Date();
      date.setTime(TimeZoneUtil.offsetSecsToEpochMillis(presentLog.time));
      timeText.text#2 = StringUtil.format(GameSetting.getUIText("profile.presentLog.time"),date.getFullYear(),StringUtil.decimalFormat("00",date.getMonth() + 1),StringUtil.decimalFormat("00",date.getDate()),StringUtil.decimalFormat("00",date.getHours()),StringUtil.decimalFormat("00",date.getMinutes()));
      messageText.text#2 = StringUtil.format(GameSetting.getUIText("profile.presentLog.message"),presentLog.playerName,targetPlayerName,gudetamaDef.name#2);
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      if(callback)
      {
         callback(encodedUid);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      levelText = null;
      nameText = null;
      timeText = null;
      messageText = null;
      if(detailButton)
      {
         detailButton.removeEventListener("triggered",triggeredDetailButton);
         detailButton = null;
      }
   }
}
