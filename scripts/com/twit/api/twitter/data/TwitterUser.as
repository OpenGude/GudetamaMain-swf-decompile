package com.twit.api.twitter.data
{
   import com.twit.api.vo.ValueObject;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   
   [Bindable]
   public class TwitterUser extends ValueObject
   {
       
      
      private var id#2292:String;
      
      private var name#2292:String;
      
      private var screenName#2292:String;
      
      private var location#2292:String;
      
      private var description#2292:String;
      
      private var profileImageUrl#2292:String;
      
      private var url#2292:String;
      
      private var isProtected#2292:Boolean;
      
      private var friendsCount#2292:Number;
      
      private var followersCount#2292:Number;
      
      private var createdAt#2292:Date;
      
      private var favouritesCount#2292:Number;
      
      private var utcOffset#2292:int;
      
      private var timeZone#2292:String;
      
      private var _following:Boolean;
      
      private var notifications#2292:Boolean;
      
      private var statusesCount#2292:Number;
      
      private var profileBackgroundColor#2292:String;
      
      private var profileTextColor#2292:String;
      
      private var profileLinkColor#2292:String;
      
      private var profileSidebarFillColor#2292:String;
      
      private var profileSidebarBorderColor#2292:String;
      
      private var profileBackgroundImageUrl#2292:String;
      
      private var profileBackgroundTile#2292:String;
      
      private var status#2292:TwitterStatus;
      
      private var profileUseBackgroundImage#2292:Boolean;
      
      private var defaultProfileImage#2292:Boolean;
      
      private var isTranslator#2292:Boolean;
      
      private var followRequestSent#2292:Boolean;
      
      private var contributorsEnabled#2292:Boolean;
      
      private var defaultProfile#2292:Boolean;
      
      private var listedCount#2292:int;
      
      private var language#2292:String;
      
      private var geoEnabled#2292:Boolean;
      
      private var verified#2292:Boolean;
      
      private var showAllInlineMedia#2292:Boolean;
      
      private var _isFollower:Boolean;
      
      private var _isBlocked:Boolean;
      
      public function TwitterUser(param1:Object, param2:Boolean = false, param3:Boolean = false)
      {
         profileUseBackgroundImage#2292 = false;
         defaultProfileImage#2292 = false;
         isTranslator#2292 = false;
         followRequestSent#2292 = false;
         contributorsEnabled#2292 = false;
         defaultProfile#2292 = false;
         listedCount#2292 = 0;
         language#2292 = "en";
         geoEnabled#2292 = false;
         verified#2292 = false;
         showAllInlineMedia#2292 = false;
         super();
         if(param1 == null)
         {
            return;
         }
         if(param2)
         {
            parseXML(param1);
         }
         else if(param3)
         {
            parseSearchJSON(param1);
         }
         else
         {
            parseJSON(param1);
         }
      }
      
      public function get id#2() : String
      {
         return this.id#2292;
      }
      
      public function set id#2(param1:String) : void
      {
         var _loc2_:* = this.id#2292;
         if(_loc2_ !== param1)
         {
            this.id#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"id",_loc2_,param1));
            }
         }
      }
      
      public function get name#2() : String
      {
         return this.name#2292;
      }
      
      public function set name#2(param1:String) : void
      {
         var _loc2_:* = this.name#2292;
         if(_loc2_ !== param1)
         {
            this.name#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"name",_loc2_,param1));
            }
         }
      }
      
      public function get screenName#2() : String
      {
         return this.screenName#2292;
      }
      
      public function set screenName#2(param1:String) : void
      {
         var _loc2_:* = this.screenName#2292;
         if(_loc2_ !== param1)
         {
            this.screenName#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"screenName",_loc2_,param1));
            }
         }
      }
      
      public function get location#2() : String
      {
         return this.location#2292;
      }
      
      public function set location#2(param1:String) : void
      {
         var _loc2_:* = this.location#2292;
         if(_loc2_ !== param1)
         {
            this.location#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"location",_loc2_,param1));
            }
         }
      }
      
      public function get description#2() : String
      {
         return this.description#2292;
      }
      
      public function set description#2(param1:String) : void
      {
         var _loc2_:* = this.description#2292;
         if(_loc2_ !== param1)
         {
            this.description#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"description",_loc2_,param1));
            }
         }
      }
      
      public function get profileImageUrl#2() : String
      {
         return this.profileImageUrl#2292;
      }
      
      public function set profileImageUrl#2(param1:String) : void
      {
         var _loc2_:* = this.profileImageUrl#2292;
         if(_loc2_ !== param1)
         {
            this.profileImageUrl#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileImageUrl",_loc2_,param1));
            }
         }
      }
      
      public function get url#2() : String
      {
         return this.url#2292;
      }
      
      public function set url#2(param1:String) : void
      {
         var _loc2_:* = this.url#2292;
         if(_loc2_ !== param1)
         {
            this.url#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"url",_loc2_,param1));
            }
         }
      }
      
      public function get isProtected#2() : Boolean
      {
         return this.isProtected#2292;
      }
      
      public function set isProtected#2(param1:Boolean) : void
      {
         var _loc2_:* = this.isProtected#2292;
         if(_loc2_ !== param1)
         {
            this.isProtected#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isProtected",_loc2_,param1));
            }
         }
      }
      
      public function get friendsCount#2() : Number
      {
         return this.friendsCount#2292;
      }
      
      public function set friendsCount#2(param1:Number) : void
      {
         var _loc2_:* = this.friendsCount#2292;
         if(_loc2_ !== param1)
         {
            this.friendsCount#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"friendsCount",_loc2_,param1));
            }
         }
      }
      
      public function get followersCount#2() : Number
      {
         return this.followersCount#2292;
      }
      
      public function set followersCount#2(param1:Number) : void
      {
         var _loc2_:* = this.followersCount#2292;
         if(_loc2_ !== param1)
         {
            this.followersCount#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"followersCount",_loc2_,param1));
            }
         }
      }
      
      public function get createdAt#2() : Date
      {
         return this.createdAt#2292;
      }
      
      public function set createdAt#2(param1:Date) : void
      {
         var _loc2_:* = this.createdAt#2292;
         if(_loc2_ !== param1)
         {
            this.createdAt#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"createdAt",_loc2_,param1));
            }
         }
      }
      
      public function get favouritesCount#2() : Number
      {
         return this.favouritesCount#2292;
      }
      
      public function set favouritesCount#2(param1:Number) : void
      {
         var _loc2_:* = this.favouritesCount#2292;
         if(_loc2_ !== param1)
         {
            this.favouritesCount#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"favouritesCount",_loc2_,param1));
            }
         }
      }
      
      public function get utcOffset#2() : int
      {
         return this.utcOffset#2292;
      }
      
      public function set utcOffset#2(param1:int) : void
      {
         var _loc2_:* = this.utcOffset#2292;
         if(_loc2_ !== param1)
         {
            this.utcOffset#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"utcOffset",_loc2_,param1));
            }
         }
      }
      
      public function get timeZone#2() : String
      {
         return this.timeZone#2292;
      }
      
      public function set timeZone#2(param1:String) : void
      {
         var _loc2_:* = this.timeZone#2292;
         if(_loc2_ !== param1)
         {
            this.timeZone#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"timeZone",_loc2_,param1));
            }
         }
      }
      
      public function get notifications#2() : Boolean
      {
         return this.notifications#2292;
      }
      
      public function set notifications#2(param1:Boolean) : void
      {
         var _loc2_:* = this.notifications#2292;
         if(_loc2_ !== param1)
         {
            this.notifications#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"notifications",_loc2_,param1));
            }
         }
      }
      
      public function get statusesCount#2() : Number
      {
         return this.statusesCount#2292;
      }
      
      public function set statusesCount#2(param1:Number) : void
      {
         var _loc2_:* = this.statusesCount#2292;
         if(_loc2_ !== param1)
         {
            this.statusesCount#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"statusesCount",_loc2_,param1));
            }
         }
      }
      
      public function get profileBackgroundColor#2() : String
      {
         return this.profileBackgroundColor#2292;
      }
      
      public function set profileBackgroundColor#2(param1:String) : void
      {
         var _loc2_:* = this.profileBackgroundColor#2292;
         if(_loc2_ !== param1)
         {
            this.profileBackgroundColor#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileBackgroundColor",_loc2_,param1));
            }
         }
      }
      
      public function get profileTextColor#2() : String
      {
         return this.profileTextColor#2292;
      }
      
      public function set profileTextColor#2(param1:String) : void
      {
         var _loc2_:* = this.profileTextColor#2292;
         if(_loc2_ !== param1)
         {
            this.profileTextColor#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileTextColor",_loc2_,param1));
            }
         }
      }
      
      public function get profileLinkColor#2() : String
      {
         return this.profileLinkColor#2292;
      }
      
      public function set profileLinkColor#2(param1:String) : void
      {
         var _loc2_:* = this.profileLinkColor#2292;
         if(_loc2_ !== param1)
         {
            this.profileLinkColor#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileLinkColor",_loc2_,param1));
            }
         }
      }
      
      public function get profileSidebarFillColor#2() : String
      {
         return this.profileSidebarFillColor#2292;
      }
      
      public function set profileSidebarFillColor#2(param1:String) : void
      {
         var _loc2_:* = this.profileSidebarFillColor#2292;
         if(_loc2_ !== param1)
         {
            this.profileSidebarFillColor#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileSidebarFillColor",_loc2_,param1));
            }
         }
      }
      
      public function get profileSidebarBorderColor#2() : String
      {
         return this.profileSidebarBorderColor#2292;
      }
      
      public function set profileSidebarBorderColor#2(param1:String) : void
      {
         var _loc2_:* = this.profileSidebarBorderColor#2292;
         if(_loc2_ !== param1)
         {
            this.profileSidebarBorderColor#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileSidebarBorderColor",_loc2_,param1));
            }
         }
      }
      
      public function get profileBackgroundImageUrl#2() : String
      {
         return this.profileBackgroundImageUrl#2292;
      }
      
      public function set profileBackgroundImageUrl#2(param1:String) : void
      {
         var _loc2_:* = this.profileBackgroundImageUrl#2292;
         if(_loc2_ !== param1)
         {
            this.profileBackgroundImageUrl#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileBackgroundImageUrl",_loc2_,param1));
            }
         }
      }
      
      public function get profileBackgroundTile#2() : String
      {
         return this.profileBackgroundTile#2292;
      }
      
      public function set profileBackgroundTile#2(param1:String) : void
      {
         var _loc2_:* = this.profileBackgroundTile#2292;
         if(_loc2_ !== param1)
         {
            this.profileBackgroundTile#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileBackgroundTile",_loc2_,param1));
            }
         }
      }
      
      public function get status#2() : TwitterStatus
      {
         return this.status#2292;
      }
      
      public function set status#2(param1:TwitterStatus) : void
      {
         var _loc2_:* = this.status#2292;
         if(_loc2_ !== param1)
         {
            this.status#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"status",_loc2_,param1));
            }
         }
      }
      
      public function get profileUseBackgroundImage#2() : Boolean
      {
         return this.profileUseBackgroundImage#2292;
      }
      
      public function set profileUseBackgroundImage#2(param1:Boolean) : void
      {
         var _loc2_:* = this.profileUseBackgroundImage#2292;
         if(_loc2_ !== param1)
         {
            this.profileUseBackgroundImage#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profileUseBackgroundImage",_loc2_,param1));
            }
         }
      }
      
      public function get defaultProfileImage#2() : Boolean
      {
         return this.defaultProfileImage#2292;
      }
      
      public function set defaultProfileImage#2(param1:Boolean) : void
      {
         var _loc2_:* = this.defaultProfileImage#2292;
         if(_loc2_ !== param1)
         {
            this.defaultProfileImage#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"defaultProfileImage",_loc2_,param1));
            }
         }
      }
      
      public function get isTranslator#2() : Boolean
      {
         return this.isTranslator#2292;
      }
      
      public function set isTranslator#2(param1:Boolean) : void
      {
         var _loc2_:* = this.isTranslator#2292;
         if(_loc2_ !== param1)
         {
            this.isTranslator#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isTranslator",_loc2_,param1));
            }
         }
      }
      
      public function get followRequestSent#2() : Boolean
      {
         return this.followRequestSent#2292;
      }
      
      public function set followRequestSent#2(param1:Boolean) : void
      {
         var _loc2_:* = this.followRequestSent#2292;
         if(_loc2_ !== param1)
         {
            this.followRequestSent#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"followRequestSent",_loc2_,param1));
            }
         }
      }
      
      public function get contributorsEnabled#2() : Boolean
      {
         return this.contributorsEnabled#2292;
      }
      
      public function set contributorsEnabled#2(param1:Boolean) : void
      {
         var _loc2_:* = this.contributorsEnabled#2292;
         if(_loc2_ !== param1)
         {
            this.contributorsEnabled#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contributorsEnabled",_loc2_,param1));
            }
         }
      }
      
      public function get defaultProfile#2() : Boolean
      {
         return this.defaultProfile#2292;
      }
      
      public function set defaultProfile#2(param1:Boolean) : void
      {
         var _loc2_:* = this.defaultProfile#2292;
         if(_loc2_ !== param1)
         {
            this.defaultProfile#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"defaultProfile",_loc2_,param1));
            }
         }
      }
      
      public function get listedCount#2() : int
      {
         return this.listedCount#2292;
      }
      
      public function set listedCount#2(param1:int) : void
      {
         var _loc2_:* = this.listedCount#2292;
         if(_loc2_ !== param1)
         {
            this.listedCount#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"listedCount",_loc2_,param1));
            }
         }
      }
      
      public function get language#2() : String
      {
         return this.language#2292;
      }
      
      public function set language#2(param1:String) : void
      {
         var _loc2_:* = this.language#2292;
         if(_loc2_ !== param1)
         {
            this.language#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"language",_loc2_,param1));
            }
         }
      }
      
      public function get geoEnabled#2() : Boolean
      {
         return this.geoEnabled#2292;
      }
      
      public function set geoEnabled#2(param1:Boolean) : void
      {
         var _loc2_:* = this.geoEnabled#2292;
         if(_loc2_ !== param1)
         {
            this.geoEnabled#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"geoEnabled",_loc2_,param1));
            }
         }
      }
      
      public function get verified#2() : Boolean
      {
         return this.verified#2292;
      }
      
      public function set verified#2(param1:Boolean) : void
      {
         var _loc2_:* = this.verified#2292;
         if(_loc2_ !== param1)
         {
            this.verified#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"verified",_loc2_,param1));
            }
         }
      }
      
      public function get showAllInlineMedia#2() : Boolean
      {
         return this.showAllInlineMedia#2292;
      }
      
      public function set showAllInlineMedia#2(param1:Boolean) : void
      {
         var _loc2_:* = this.showAllInlineMedia#2292;
         if(_loc2_ !== param1)
         {
            this.showAllInlineMedia#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showAllInlineMedia",_loc2_,param1));
            }
         }
      }
      
      [Bindable("dataChange")]
      public function get following() : Boolean
      {
         return _following;
      }
      
      public function set following(param1:Boolean) : void
      {
         if(_following == param1)
         {
            return;
         }
         _following = param1;
         dispatchDataChangeEvent();
      }
      
      [Bindable("dataChange")]
      public function get isFollower() : Boolean
      {
         return _isFollower;
      }
      
      public function set isFollower(param1:Boolean) : void
      {
         if(_isFollower == param1)
         {
            return;
         }
         _isFollower = param1;
         dispatchDataChangeEvent();
      }
      
      [Bindable("dataChange")]
      public function get isBlocked() : Boolean
      {
         return _isBlocked;
      }
      
      public function set isBlocked(param1:Boolean) : void
      {
         if(_isBlocked == param1)
         {
            return;
         }
         _isBlocked = param1;
         dispatchDataChangeEvent();
      }
      
      public function parseJSON(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.profileSidebarBorderColor#2 = param1["profile_sidebar_border_color"];
         this.profileBackgroundImageUrl#2 = param1["profile_background_image_url"];
         this.profileSidebarFillColor#2 = param1["profile_sidebar_fill_color"];
         this.profileBackgroundTile#2 = param1["profile_background_tile"];
         this.profileImageUrl#2 = param1["profile_image_url"];
         this.profileUseBackgroundImage#2 = param1["profile_use_background_image"];
         this.profileTextColor#2 = param1["profile_text_color"];
         this.profileLinkColor#2 = param1["profile_link_color"];
         this.profileBackgroundColor#2 = param1["profile_background_color"];
         this.defaultProfileImage#2 = param1["default_profile_image"];
         this.id#2 = param1["id_str"];
         this.name#2 = param1["name"];
         this.screenName#2 = param1["screen_name"];
         this.createdAt#2 = new Date(Date.parse(param1["created_at"]));
         this.language#2 = param1["lang"];
         this.description#2 = param1["description"];
         this.isProtected#2 = param1["protected"];
         this.verified#2 = param1["verified"];
         this.url#2 = param1["url"];
         this.friendsCount#2 = param1["friends_count"];
         this.statusesCount#2 = param1["statuses_count"];
         this.listedCount#2 = param1["listed_count"];
         this.followersCount#2 = param1["followers_count"];
         this.geoEnabled#2 = param1["geo_enabled"];
         this.location#2 = param1["location"];
         this.timeZone#2 = param1["time_zone"];
         this.utcOffset#2 = param1["utc_offset"];
         this.isTranslator#2 = param1["is_translator"];
         this.followRequestSent#2 = param1["follow_request_sent"];
         this.contributorsEnabled#2 = param1["contributors_enabled"];
         this.defaultProfile#2 = param1["default_profile"];
         this.favouritesCount#2 = param1["favourites_count"];
         this.showAllInlineMedia#2 = param1["show_all_inline_media"];
         this.following = param1["following"];
         this.notifications#2 = param1["notifications"];
         if(param1["status"])
         {
            try
            {
               status#2 = new TwitterStatus(param1.status,this);
            }
            catch(e:Error)
            {
               status#2 = null;
            }
         }
      }
      
      public function parseSearchJSON(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         id#2 = param1.from_user_id;
         screenName#2 = param1.from_user;
         name#2 = screenName#2;
         profileImageUrl#2 = param1.profile_image_url;
      }
      
      public function parseXML(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         id#2 = param1.id;
         name#2 = param1.name;
         screenName#2 = param1.screen_name;
         location#2 = param1.location;
         description#2 = param1.description;
         profileImageUrl#2 = param1.profile_image_url;
         url#2 = param1.url;
         isProtected#2 = param1.protect != null && param1.protect.toString() == "true" ? true : false;
         followersCount#2 = Number(param1.followers_count);
         profileBackgroundColor#2 = param1.profile_background_color;
         profileTextColor#2 = param1.profile_text_color;
         profileLinkColor#2 = param1.profile_link_color;
         profileSidebarFillColor#2 = param1.profile_sidebar_fill_color;
         profileSidebarBorderColor#2 = param1.profile_sidebar_border_color;
         friendsCount#2 = Number(param1.friends_count);
         createdAt#2 = new Date(Date.parse(param1.created_at.toString()));
         favouritesCount#2 = Number(param1.favourites_count);
         utcOffset#2 = param1.utc_offset;
         timeZone#2 = param1.time_zone;
         profileBackgroundImageUrl#2 = param1.profile_background_image_url;
         profileBackgroundTile#2 = param1.profile_background_tile;
         _following = param1.following != null && param1.following.toString() == "true" ? true : false;
         notifications#2 = param1.notifications != null && param1.notifications.toString() == "true" ? true : false;
         statusesCount#2 = Number(param1.statuses_count);
         if(param1.status != null && param1.status.toString() != "" && param1.status.text != null && param1.status.text.toString() != "")
         {
            try
            {
               status#2 = new TwitterStatus(param1.status,this);
            }
            catch(e:Error)
            {
               status#2 = null;
            }
         }
      }
      
      protected function dispatchDataChangeEvent() : void
      {
         dispatchEvent(new FlexEvent("dataChange"));
      }
   }
}
