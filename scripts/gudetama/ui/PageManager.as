package gudetama.ui
{
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   
   public class PageManager extends Sprite
   {
       
      
      private var extractor:SpriteExtractor;
      
      private var _w:int;
      
      private var btnNum:int;
      
      private var btnMax:int;
      
      private var pageMax:int;
      
      private var jumpVal:int;
      
      private var btnW:int;
      
      private var pageSpace:int = 20;
      
      private var jumpPageSpace:int = 20;
      
      private var page:int;
      
      private var btns:Array;
      
      private var btnJumpBack:PageButton;
      
      private var btnJumpNext:PageButton;
      
      private var needPageText:Boolean;
      
      private var listener:PageManagerListener;
      
      public function PageManager(param1:int, param2:SpriteExtractor, param3:int, param4:Boolean, param5:int = 0)
      {
         super();
         _w = param1;
         this.extractor = param2;
         this.btnMax = param3;
         page = -1;
         this.needPageText = param4;
         jumpVal = param5;
         btns = [];
         if(param5 > 0)
         {
            btnJumpBack = new PageButton(param2,pushPage,param4);
            addChild(btnJumpBack);
            btnJumpNext = new PageButton(param2,pushPage,param4);
            addChild(btnJumpNext);
         }
      }
      
      public function updatePageInfo(param1:int, param2:int) : void
      {
         var _loc5_:* = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         btnNum = Math.min(btnMax,param1);
         pageMax = param1;
         if(btns.length < btnNum)
         {
            while(btns.length < btnNum)
            {
               btnW = (_loc5_ = new PageButton(extractor,pushPage,needPageText)).width;
               addChild(_loc5_);
               btns.push(_loc5_);
            }
         }
         if(jumpVal > 0)
         {
            btnJumpBack.x = 0;
            btnJumpNext.x = _w - btnW;
            _loc3_ = _w - (btnW + jumpPageSpace) * 2;
            _loc6_ = (_loc6_ = btnJumpBack.x + btnW + jumpPageSpace) + (_loc3_ - btnW * btnNum - (btnNum > 1 ? (btnNum - 1) * pageSpace : 0)) / 2;
         }
         else
         {
            _loc3_ = _w;
            _loc6_ = (_loc3_ - btnW * btnNum - (btnNum > 1 ? (btnNum - 1) * pageSpace : 0)) / 2;
         }
         _loc4_ = 0;
         while(_loc4_ < btnNum)
         {
            (_loc5_ = PageButton(btns[_loc4_])).x = _loc6_;
            _loc6_ += btnW + pageSpace;
            _loc4_++;
         }
         changePage(param2,true);
      }
      
      private function changePage(param1:int, param2:Boolean) : void
      {
         var _loc10_:* = null;
         var _loc6_:int = 0;
         var _loc4_:* = 0;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         if(page == param1 && !param2)
         {
            return;
         }
         page = param1;
         var _loc3_:* = int((btnNum - 1) / 2);
         var _loc9_:int = (btnNum - 1) / 2 + (btnNum % 2 == 0 ? 1 : 0);
         for each(_loc10_ in btns)
         {
            _loc10_.visible = false;
         }
         if(page - _loc3_ < 0)
         {
            _loc6_ = 0;
         }
         else if(page + _loc9_ > pageMax - 1)
         {
            _loc6_ = pageMax - btnNum;
         }
         else
         {
            _loc6_ = page - _loc3_;
         }
         _loc7_ = 0;
         while(_loc7_ < btnNum)
         {
            (_loc10_ = PageButton(btns[_loc7_])).page = _loc6_ + _loc7_;
            if(_loc10_.page == page)
            {
               _loc4_ = _loc7_;
               _loc10_.enabled = false;
            }
            else
            {
               _loc10_.enabled = true;
            }
            _loc10_.visible = true;
            _loc7_++;
         }
         if(jumpVal > 0)
         {
            _loc3_ = _loc4_;
            if(page - _loc3_ <= 0)
            {
               btnJumpBack.visible = false;
            }
            else
            {
               _loc5_ = Math.max(0,page - jumpVal);
               btnJumpBack.page = _loc5_;
               btnJumpBack.visible = true;
            }
            _loc9_ = btnNum - (_loc4_ + 1);
            if(page + _loc9_ >= pageMax - 1)
            {
               btnJumpNext.visible = false;
            }
            else
            {
               _loc8_ = Math.min(pageMax - 1,page + jumpVal);
               btnJumpNext.page = _loc8_;
               btnJumpNext.visible = true;
            }
         }
         listener.changePage(param1);
      }
      
      public function setListener(param1:PageManagerListener) : void
      {
         listener = param1;
      }
      
      private function pushPage(param1:int) : void
      {
         changePage(param1,false);
      }
      
      override public function dispose() : void
      {
         btns.length = 0;
         btns = null;
         btnJumpBack = null;
         btnJumpNext = null;
         listener = null;
         super.dispose();
      }
   }
}
