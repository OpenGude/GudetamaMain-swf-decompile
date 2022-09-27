package gudetama.data
{
   import gudetama.data.compati.EventData;
   import gudetama.data.compati.RankingContentDef;
   import gudetama.data.compati.RankingInfo;
   import gudetama.data.compati.RankingRecord;
   import gudetama.data.compati.RankingRewardDef;
   import gudetama.data.compati.RankingRewardItemDef;
   import gudetama.util.StringUtil;
   
   public class RankingInfoWrapper
   {
       
      
      private var info:RankingInfo;
      
      public var rankingId:int;
      
      public var content:RankingContentDef;
      
      public function RankingInfoWrapper(param1:RankingInfo, param2:int, param3:RankingContentDef)
      {
         super();
         this.info = param1;
         this.rankingId = param2;
         this.content = param3;
      }
      
      public function isDeliverRanking() : Boolean
      {
         return content.type = 5;
      }
      
      public function get title() : String
      {
         return info.contentTitle;
      }
      
      public function get desc() : String
      {
         return info.desc;
      }
      
      public function get rank() : int
      {
         return info.myRoughPlace;
      }
      
      public function set rank(param1:int) : void
      {
         info.myRoughPlace = param1;
      }
      
      public function get myPoint() : int
      {
         return info.myPoint;
      }
      
      public function set myPoint(param1:int) : void
      {
         info.myPoint = param1;
      }
      
      public function get totalPoint() : int
      {
         return info.totalPoint;
      }
      
      public function set totalPoint(param1:int) : void
      {
         info.totalPoint = param1;
      }
      
      public function get existsRankingGlobalRewards() : Boolean
      {
         var _loc1_:RankingRewardDef = GameSetting.getRankingReward(content.rewardId);
         if(!_loc1_)
         {
            return false;
         }
         return _loc1_.globalRewards && _loc1_.globalRewards.length > 0;
      }
      
      public function get currentRankingGlobalReward() : RankingRewardItemDef
      {
         var _loc4_:int = 0;
         var _loc2_:* = null;
         var _loc3_:RankingRewardDef = GameSetting.getRankingReward(content.rewardId);
         if(!_loc3_ || !_loc3_.globalRewards)
         {
            return null;
         }
         var _loc1_:* = null;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.globalRewards.length)
         {
            _loc2_ = _loc3_.globalRewards[_loc4_];
            _loc1_ = _loc2_;
            if(totalPoint < _loc2_.argi)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc4_ >= _loc3_.globalRewards.length)
         {
            return null;
         }
         return _loc1_;
      }
      
      public function get restMaxPoint() : int
      {
         var _loc5_:int = 0;
         var _loc2_:* = null;
         var _loc4_:RankingRewardDef;
         if(!(_loc4_ = GameSetting.getRankingReward(content.rewardId)) || !_loc4_.globalRewards)
         {
            return 0;
         }
         var _loc3_:RankingRewardItemDef = null;
         var _loc1_:* = null;
         _loc5_ = 0;
         while(_loc5_ < _loc4_.globalRewards.length)
         {
            _loc2_ = _loc4_.globalRewards[_loc5_];
            if(_loc5_ > 0)
            {
               _loc3_ = _loc4_.globalRewards[_loc5_ - 1];
            }
            _loc1_ = _loc2_;
            if(totalPoint < _loc2_.argi)
            {
               break;
            }
            _loc5_++;
         }
         if(_loc1_ && _loc3_)
         {
            return _loc1_.argi - _loc3_.argi;
         }
         if(_loc1_)
         {
            return _loc1_.argi;
         }
         return 0;
      }
      
      public function get lastMaxPoint() : int
      {
         var _loc4_:int = 0;
         var _loc1_:* = null;
         var _loc3_:RankingRewardDef = GameSetting.getRankingReward(content.rewardId);
         if(!_loc3_ || !_loc3_.globalRewards)
         {
            return 0;
         }
         var _loc2_:RankingRewardItemDef = null;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.globalRewards.length)
         {
            _loc1_ = _loc3_.globalRewards[_loc4_];
            if(_loc4_ > 0)
            {
               _loc2_ = _loc3_.globalRewards[_loc4_ - 1];
            }
            if(totalPoint < _loc1_.argi)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc2_)
         {
            return _loc2_.argi;
         }
         return 0;
      }
      
      public function get rankingGlobalRewards() : Array
      {
         var _loc1_:RankingRewardDef = GameSetting.getRankingReward(content.rewardId);
         if(!_loc1_)
         {
            return null;
         }
         return _loc1_.globalRewards;
      }
      
      public function get maxLevel() : int
      {
         var _loc4_:int = 0;
         var _loc1_:* = null;
         var _loc3_:RankingRewardDef = GameSetting.getRankingReward(content.rewardId);
         if(!_loc3_ || !_loc3_.globalRewards)
         {
            return 0;
         }
         var _loc2_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.globalRewards.length)
         {
            _loc1_ = _loc3_.globalRewards[_loc4_];
            _loc2_ = Math.max(_loc2_,_loc1_.sortedIndex);
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function get currentLevel() : int
      {
         var _loc1_:RankingRewardItemDef = currentRankingGlobalReward;
         if(_loc1_)
         {
            return _loc1_.sortedIndex + 1;
         }
         return maxLevel + 2;
      }
      
      public function get topRecords() : Array
      {
         return info.topRecords;
      }
      
      public function get showOnly() : Boolean
      {
         return info.showOnly;
      }
      
      public function checkTopRecordsIn() : void
      {
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc1_:* = null;
         if(myPoint == 0 || isEmptyTopRecords())
         {
            return;
         }
         var _loc2_:Array = topRecords;
         var _loc11_:* = UserDataWrapper;
         var _loc10_:int = gudetama.data.UserDataWrapper.wrapper._data.encodedUid;
         var _loc8_:Boolean = false;
         var _loc3_:int = 2147483647;
         _loc6_ = 0;
         while(_loc6_ < _loc2_.length)
         {
            if((_loc5_ = _loc2_[_loc6_]).encodeUid == _loc10_)
            {
               _loc5_.playerName = UserDataWrapper.wrapper.getPlayerName();
               _loc5_.point = myPoint;
               _loc8_ = true;
               break;
            }
            _loc3_ = _loc5_.point;
            _loc6_++;
         }
         var _loc4_:* = _loc2_.length >= info.topRecordSizeMax;
         if(!_loc8_ && (_loc3_ <= myPoint || !_loc4_))
         {
            if(_loc4_)
            {
               _loc2_.pop();
            }
            _loc1_ = new RankingRecord();
            _loc1_.encodeUid = _loc10_;
            _loc1_.playerName = UserDataWrapper.wrapper.getPlayerName();
            _loc1_.point = myPoint;
            _loc2_.push(_loc1_);
            _loc8_ = true;
         }
         if(!_loc8_)
         {
            return;
         }
         _loc2_.sort(compareRankingRecord);
         var _loc7_:int = 0;
         var _loc9_:int = -2147483648;
         _loc6_ = 0;
         while(_loc6_ < _loc2_.length)
         {
            _loc5_ = _loc2_[_loc6_];
            if(_loc9_ != _loc5_.point)
            {
               _loc7_ = _loc6_ + 1;
               _loc9_ = _loc5_.point;
            }
            if(_loc5_.encodeUid == _loc10_)
            {
               rank = _loc7_;
               break;
            }
            _loc6_++;
         }
      }
      
      public function isEmptyTopRecords() : Boolean
      {
         return topRecords == null || topRecords.length == 0;
      }
      
      private function compareRankingRecord(param1:RankingRecord, param2:RankingRecord) : int
      {
         if(param1.point > param2.point)
         {
            return -1;
         }
         if(param1.point < param2.point)
         {
            return 1;
         }
         return 0;
      }
      
      public function getMyRankText() : String
      {
         if(rank <= 0 || isEmptyTopRecords())
         {
            return GameSetting.getUIText("ranking.no.rank");
         }
         return GameSetting.getUIText("common.unit.rank").replace("%1",StringUtil.getNumStringCommas(rank));
      }
      
      public function isAttendable() : Boolean
      {
         var _loc1_:EventData = UserDataWrapper.eventPart.getEventDataByRankingId(rankingId);
         return _loc1_.attendable;
      }
   }
}
