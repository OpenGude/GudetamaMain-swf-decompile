package com.twit.api.twitter.data
{
   public class TwitterEntity
   {
      
      public static const ENTITY_TYPE_URL:String = "url";
      
      public static const ENTITY_TYPE_HASHTAG:String = "hashtag";
      
      public static const ENTITY_TYPE_MENTION:String = "usermention";
      
      public static const ENTITY_TYPE_MEDIA:String = "media";
       
      
      public var rawData:Object;
      
      public var type:String;
      
      public var expandedURL:String;
      
      public var url#2:String;
      
      public var displayURL:String;
      
      public var hashText:String;
      
      public var name#2:String;
      
      public var mentionId:String;
      
      public var screenName#2:String;
      
      public var mediaId:String;
      
      public var mediaURL:String;
      
      public var mediaURLHttps:String;
      
      public var mediaSizes:Object;
      
      public var mediaType:String;
      
      public var indices:Array;
      
      public var startIndex:int;
      
      public var endIndex:int;
      
      public function TwitterEntity()
      {
         super();
      }
      
      public function parseJSON(param1:Object, param2:String) : void
      {
         if(param2 == "url" || param2 == "media")
         {
            expandedURL = param1["expanded_url"];
            url#2 = param1["url"];
            displayURL = param1["display_url"];
         }
         else if(param2 == "hashtag")
         {
            hashText = param1["text"];
         }
         else if(param2 == "usermention")
         {
            name#2 = param1["name"];
            mentionId = param1["id"];
            screenName#2 = param1["screen_name"];
         }
         if(param2 == "media")
         {
            mediaId = param1["id_str"];
            mediaURL = param1["media_url"];
            mediaURLHttps = param1["media_url_https"];
            mediaSizes = param1["sizes"];
            mediaType = param1["type"];
         }
         indices = param1["indices"];
         startIndex = indices[0];
         endIndex = indices[1];
         this.type = param2;
      }
   }
}
