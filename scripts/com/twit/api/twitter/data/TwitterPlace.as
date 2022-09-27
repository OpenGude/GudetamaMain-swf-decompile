package com.twit.api.twitter.data
{
   public class TwitterPlace
   {
       
      
      public var rawData:Object;
      
      public var name#2:String;
      
      public var countryCode:String;
      
      public var country:String;
      
      public var attributes:Object;
      
      public var url#2:String;
      
      public var id#2:String;
      
      public var boundingBox:Object;
      
      public var fullName:String;
      
      public var type:String;
      
      public function TwitterPlace(param1:Object = null)
      {
         super();
         if(param1)
         {
            parseJSON(param1);
            this.rawData = param1;
         }
      }
      
      public function parseJSON(param1:Object) : void
      {
         name#2 = param1["name"];
         countryCode = param1["country_code"];
         country = param1["country"];
         attributes = param1["attributes"];
         url#2 = param1["url"];
         id#2 = param1["id"];
         boundingBox = param1["bounding_box"];
         fullName = param1["full_name"];
         type = param1["place_type"];
      }
   }
}
