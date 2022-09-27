package com.twit.api.twitter.data
{
   import com.twit.api.vo.ValueObject;
   import mx.events.PropertyChangeEvent;
   
   [Bindable]
   public class TwitterStatus extends ValueObject
   {
       
      
      private var createdAt#2292:Date;
      
      private var id#2292:String;
      
      private var text#2292:String;
      
      private var source#2292:String;
      
      private var truncated#2292:Boolean;
      
      private var inReplyToStatusId#2292:String;
      
      private var inReplyToUserId#2292:String;
      
      private var favorited#2292:Boolean;
      
      private var inReplyToScreenName#2292:String;
      
      private var user#2292:TwitterUser;
      
      private var geo#2292:Object;
      
      private var coordinates#2292:Object;
      
      private var place#2292:TwitterPlace;
      
      private var contributors#2292:Array;
      
      private var retweeted#2292:Boolean;
      
      private var retweetCount#2292:int;
      
      private var possiblySensitive#2292:Boolean;
      
      private var urls#2292:Vector.<TwitterEntity>;
      
      private var hashtags#2292:Vector.<TwitterEntity>;
      
      private var userMentions#2292:Vector.<TwitterEntity>;
      
      private var media#2292:Vector.<TwitterEntity>;
      
      private var entities#2292:Vector.<TwitterEntity>;
      
      private var annotations#2292:Object;
      
      private var resultType#2292:String;
      
      private var isMention#2292:Boolean;
      
      private var retweetedStatus#2292:TwitterStatus;
      
      public function TwitterStatus(param1:Object, param2:TwitterUser = null, param3:Boolean = false, param4:Boolean = false)
      {
         geo#2292 = null;
         coordinates#2292 = null;
         place#2292 = null;
         contributors#2292 = null;
         retweeted#2292 = false;
         retweetCount#2292 = 0;
         possiblySensitive#2292 = false;
         urls#2292 = null;
         hashtags#2292 = null;
         userMentions#2292 = null;
         media#2292 = null;
         entities#2292 = null;
         annotations#2292 = null;
         isMention#2292 = false;
         super();
         if(param3)
         {
            parseXML(param1);
            if(param2)
            {
               this.user#2 = param2;
            }
            else if(param1.user != null)
            {
               this.user#2 = new TwitterUser(param1.user);
            }
         }
         else if(param4)
         {
            parseSearchJSON(param1);
            this.user#2 = new TwitterUser(param1["user"],false,true);
         }
         else
         {
            parseJSON(param1);
            this.user#2 = new TwitterUser(param1["user"],false,false);
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
      
      public function get text#2() : String
      {
         return this.text#2292;
      }
      
      public function set text#2(param1:String) : void
      {
         var _loc2_:* = this.text#2292;
         if(_loc2_ !== param1)
         {
            this.text#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"text",_loc2_,param1));
            }
         }
      }
      
      public function get source#2() : String
      {
         return this.source#2292;
      }
      
      public function set source#2(param1:String) : void
      {
         var _loc2_:* = this.source#2292;
         if(_loc2_ !== param1)
         {
            this.source#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"source",_loc2_,param1));
            }
         }
      }
      
      public function get truncated#2() : Boolean
      {
         return this.truncated#2292;
      }
      
      public function set truncated#2(param1:Boolean) : void
      {
         var _loc2_:* = this.truncated#2292;
         if(_loc2_ !== param1)
         {
            this.truncated#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"truncated",_loc2_,param1));
            }
         }
      }
      
      public function get inReplyToStatusId#2() : String
      {
         return this.inReplyToStatusId#2292;
      }
      
      public function set inReplyToStatusId#2(param1:String) : void
      {
         var _loc2_:* = this.inReplyToStatusId#2292;
         if(_loc2_ !== param1)
         {
            this.inReplyToStatusId#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"inReplyToStatusId",_loc2_,param1));
            }
         }
      }
      
      public function get inReplyToUserId#2() : String
      {
         return this.inReplyToUserId#2292;
      }
      
      public function set inReplyToUserId#2(param1:String) : void
      {
         var _loc2_:* = this.inReplyToUserId#2292;
         if(_loc2_ !== param1)
         {
            this.inReplyToUserId#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"inReplyToUserId",_loc2_,param1));
            }
         }
      }
      
      public function get favorited#2() : Boolean
      {
         return this.favorited#2292;
      }
      
      public function set favorited#2(param1:Boolean) : void
      {
         var _loc2_:* = this.favorited#2292;
         if(_loc2_ !== param1)
         {
            this.favorited#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"favorited",_loc2_,param1));
            }
         }
      }
      
      public function get inReplyToScreenName#2() : String
      {
         return this.inReplyToScreenName#2292;
      }
      
      public function set inReplyToScreenName#2(param1:String) : void
      {
         var _loc2_:* = this.inReplyToScreenName#2292;
         if(_loc2_ !== param1)
         {
            this.inReplyToScreenName#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"inReplyToScreenName",_loc2_,param1));
            }
         }
      }
      
      public function get user#2() : TwitterUser
      {
         return this.user#2292;
      }
      
      public function set user#2(param1:TwitterUser) : void
      {
         var _loc2_:* = this.user#2292;
         if(_loc2_ !== param1)
         {
            this.user#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"user",_loc2_,param1));
            }
         }
      }
      
      public function get geo#2() : Object
      {
         return this.geo#2292;
      }
      
      public function set geo#2(param1:Object) : void
      {
         var _loc2_:* = this.geo#2292;
         if(_loc2_ !== param1)
         {
            this.geo#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"geo",_loc2_,param1));
            }
         }
      }
      
      public function get coordinates#2() : Object
      {
         return this.coordinates#2292;
      }
      
      public function set coordinates#2(param1:Object) : void
      {
         var _loc2_:* = this.coordinates#2292;
         if(_loc2_ !== param1)
         {
            this.coordinates#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"coordinates",_loc2_,param1));
            }
         }
      }
      
      public function get place#2() : TwitterPlace
      {
         return this.place#2292;
      }
      
      public function set place#2(param1:TwitterPlace) : void
      {
         var _loc2_:* = this.place#2292;
         if(_loc2_ !== param1)
         {
            this.place#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"place",_loc2_,param1));
            }
         }
      }
      
      public function get contributors#2() : Array
      {
         return this.contributors#2292;
      }
      
      public function set contributors#2(param1:Array) : void
      {
         var _loc2_:* = this.contributors#2292;
         if(_loc2_ !== param1)
         {
            this.contributors#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contributors",_loc2_,param1));
            }
         }
      }
      
      public function get retweeted#2() : Boolean
      {
         return this.retweeted#2292;
      }
      
      public function set retweeted#2(param1:Boolean) : void
      {
         var _loc2_:* = this.retweeted#2292;
         if(_loc2_ !== param1)
         {
            this.retweeted#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"retweeted",_loc2_,param1));
            }
         }
      }
      
      public function get retweetCount#2() : int
      {
         return this.retweetCount#2292;
      }
      
      public function set retweetCount#2(param1:int) : void
      {
         var _loc2_:* = this.retweetCount#2292;
         if(_loc2_ !== param1)
         {
            this.retweetCount#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"retweetCount",_loc2_,param1));
            }
         }
      }
      
      public function get possiblySensitive#2() : Boolean
      {
         return this.possiblySensitive#2292;
      }
      
      public function set possiblySensitive#2(param1:Boolean) : void
      {
         var _loc2_:* = this.possiblySensitive#2292;
         if(_loc2_ !== param1)
         {
            this.possiblySensitive#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"possiblySensitive",_loc2_,param1));
            }
         }
      }
      
      public function get urls#2() : Vector.<TwitterEntity>
      {
         return this.urls#2292;
      }
      
      public function set urls#2(param1:Vector.<TwitterEntity>) : void
      {
         var _loc2_:* = this.urls#2292;
         if(_loc2_ !== param1)
         {
            this.urls#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"urls",_loc2_,param1));
            }
         }
      }
      
      public function get hashtags#2() : Vector.<TwitterEntity>
      {
         return this.hashtags#2292;
      }
      
      public function set hashtags#2(param1:Vector.<TwitterEntity>) : void
      {
         var _loc2_:* = this.hashtags#2292;
         if(_loc2_ !== param1)
         {
            this.hashtags#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hashtags",_loc2_,param1));
            }
         }
      }
      
      public function get userMentions#2() : Vector.<TwitterEntity>
      {
         return this.userMentions#2292;
      }
      
      public function set userMentions#2(param1:Vector.<TwitterEntity>) : void
      {
         var _loc2_:* = this.userMentions#2292;
         if(_loc2_ !== param1)
         {
            this.userMentions#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"userMentions",_loc2_,param1));
            }
         }
      }
      
      public function get media#2() : Vector.<TwitterEntity>
      {
         return this.media#2292;
      }
      
      public function set media#2(param1:Vector.<TwitterEntity>) : void
      {
         var _loc2_:* = this.media#2292;
         if(_loc2_ !== param1)
         {
            this.media#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"media",_loc2_,param1));
            }
         }
      }
      
      public function get entities#2() : Vector.<TwitterEntity>
      {
         return this.entities#2292;
      }
      
      public function set entities#2(param1:Vector.<TwitterEntity>) : void
      {
         var _loc2_:* = this.entities#2292;
         if(_loc2_ !== param1)
         {
            this.entities#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"entities",_loc2_,param1));
            }
         }
      }
      
      public function get annotations#2() : Object
      {
         return this.annotations#2292;
      }
      
      public function set annotations#2(param1:Object) : void
      {
         var _loc2_:* = this.annotations#2292;
         if(_loc2_ !== param1)
         {
            this.annotations#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"annotations",_loc2_,param1));
            }
         }
      }
      
      public function get resultType#2() : String
      {
         return this.resultType#2292;
      }
      
      public function set resultType#2(param1:String) : void
      {
         var _loc2_:* = this.resultType#2292;
         if(_loc2_ !== param1)
         {
            this.resultType#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resultType",_loc2_,param1));
            }
         }
      }
      
      public function get isMention#2() : Boolean
      {
         return this.isMention#2292;
      }
      
      public function set isMention#2(param1:Boolean) : void
      {
         var _loc2_:* = this.isMention#2292;
         if(_loc2_ !== param1)
         {
            this.isMention#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isMention",_loc2_,param1));
            }
         }
      }
      
      public function get retweetedStatus#2() : TwitterStatus
      {
         return this.retweetedStatus#2292;
      }
      
      public function set retweetedStatus#2(param1:TwitterStatus) : void
      {
         var _loc2_:* = this.retweetedStatus#2292;
         if(_loc2_ !== param1)
         {
            this.retweetedStatus#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"retweetedStatus",_loc2_,param1));
            }
         }
      }
      
      public function parseXML(param1:Object) : void
      {
         this.createdAt#2 = new Date(Date.parse(param1.created_at.toString()));
         this.id#2 = param1.id;
         this.text#2 = param1.text;
         this.source#2 = param1.source;
         this.truncated#2 = param1.truncated != null && param1.truncated.toString() == "true" ? true : false;
         this.inReplyToStatusId#2 = param1.in_reply_to_status_id;
         this.inReplyToUserId#2 = param1.in_reply_to_user_id;
         this.favorited#2 = param1.favorited != null && param1.favorited.toString() == "true" ? true : false;
         this.inReplyToScreenName#2 = param1.in_reply_to_screen_name;
         if(param1.retweeted_status != null && param1.retweeted_status.toString() != "")
         {
            this.retweetedStatus#2 = new TwitterStatus(param1.retweeted_status);
         }
      }
      
      public function parseJSON(param1:Object) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         this.coordinates#2 = param1["coordinates"];
         this.favorited#2 = param1["favorited"];
         this.createdAt#2 = new Date(Date.parse(param1["created_at"].toString()));
         this.truncated#2 = param1["truncated"];
         this.text#2 = param1["text"];
         this.annotations#2 = param1["annotations"];
         this.contributors#2 = param1["contributors"];
         this.id#2 = param1["id_str"] == null ? param1["id"].toString() : param1["id_str"];
         this.geo#2 = param1["geo"];
         this.inReplyToUserId#2 = param1["in_reply_to_user_id"];
         this.inReplyToScreenName#2 = param1["in_reply_to_screen_name"];
         this.place#2 = param1["place"] == null ? null : new TwitterPlace(param1["place"]);
         this.source#2 = param1["source"];
         this.inReplyToStatusId#2 = param1["in_reply_to_status_id"];
         this.retweeted#2 = param1["retweeted"];
         this.retweetCount#2 = param1["retweet_count"];
         this.possiblySensitive#2 = param1["possibly_sensitive"];
         if(param1["retweeted_status"])
         {
            this.retweetedStatus#2 = new TwitterStatus(param1["retweeted_status"]);
         }
         if(param1["entities"])
         {
            this.urls#2 = new Vector.<TwitterEntity>();
            if(param1["entities"]["urls"])
            {
               for each(_loc3_ in param1["entities"]["urls"])
               {
                  _loc2_ = new TwitterEntity();
                  _loc2_.parseJSON(_loc3_,"url");
                  this.urls#2.push(_loc2_);
               }
            }
            this.hashtags#2 = new Vector.<TwitterEntity>();
            if(param1["entities"]["hashtags"])
            {
               for each(_loc3_ in param1["entities"]["hashtags"])
               {
                  (_loc5_ = new TwitterEntity()).parseJSON(_loc3_,"hashtag");
                  this.hashtags#2.push(_loc5_);
               }
            }
            this.userMentions#2 = new Vector.<TwitterEntity>();
            if(param1["entities"]["user_mentions"])
            {
               for each(_loc3_ in param1["entities"]["user_mentions"])
               {
                  (_loc6_ = new TwitterEntity()).parseJSON(_loc3_,"usermention");
                  this.userMentions#2.push(_loc6_);
               }
            }
            this.media#2 = new Vector.<TwitterEntity>();
            if(param1["entities"]["media"])
            {
               for each(_loc3_ in param1["entities"]["media"])
               {
                  (_loc4_ = new TwitterEntity()).parseJSON(_loc3_,"media");
                  this.media#2.push(_loc4_);
               }
            }
            this.entities#2 = this.urls#2.concat(this.hashtags#2,this.userMentions#2,this.media#2);
         }
      }
      
      public function parseSearchJSON(param1:Object) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         this.createdAt#2 = new Date(Date.parse(param1["created_at"].toString()));
         this.text#2 = param1["text"];
         this.id#2 = param1["id_str"] == null ? param1["id"].toString() : param1["id_str"];
         this.geo#2 = param1["geo"];
         this.inReplyToUserId#2 = param1["to_user_id_str"];
         this.source#2 = param1["source"];
         if(param1["entities"])
         {
            if(param1["entities"]["urls"])
            {
               this.urls#2 = new Vector.<TwitterEntity>();
               for each(_loc3_ in param1["entities"]["urls"])
               {
                  _loc2_ = new TwitterEntity();
                  _loc2_.parseJSON(_loc3_,"url");
                  this.urls#2.push(_loc2_);
               }
            }
            if(param1["entities"]["hashtags"])
            {
               this.hashtags#2 = new Vector.<TwitterEntity>();
               for each(_loc3_ in param1["entities"]["hashtags"])
               {
                  (_loc4_ = new TwitterEntity()).parseJSON(_loc3_,"hashtag");
                  this.hashtags#2.push(_loc4_);
               }
            }
            if(param1["entities"]["user_mentions"])
            {
               this.userMentions#2 = new Vector.<TwitterEntity>();
               for each(_loc3_ in param1["entities"]["user_mentions"])
               {
                  (_loc5_ = new TwitterEntity()).parseJSON(_loc3_,"usermention");
                  this.urls#2.push(_loc5_);
               }
            }
         }
         if(param1["metadata"])
         {
            this.resultType#2 = param1["metadata"]["result_type"];
         }
      }
   }
}
