package com.taomee.seer2.app.arena
{
   import com.taomee.seer2.app.arena.data.AnimiationHitInfo;
   import com.taomee.seer2.app.arena.util.HitInfoConfig;
   import com.taomee.seer2.core.animation.IAnimation;
   import com.taomee.seer2.core.player.FighterMoviePlayer;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.setTimeout;
   
   public class FighterAnimation extends Sprite implements IAnimation
   {
      
      public static const EVT_END:String = "end";
      
      public static const EVT_HIT:String = "fighterHit";
      
      private static const MODE_STOP_IDLE:String = "stopIdle";
      
      private static const MODE_STOP_LAST_FRAME:String = "stopLastFrame";
      
      private static const MODE_REPLAY:String = "replay";
      
      private static const MODE_BLANK:String = "blank";
      
      private var _mc:MovieClip;
      
      private var _actionAnimation:MovieClip;
      
      private var _currentLabel:String;
      
      private var _mode:String;
      
      private var _fighterResourceId:uint;
      
      private var _moviePlayer:FighterMoviePlayer;
      
      public function FighterAnimation()
      {
         super();
         this.mouseChildren = false;
         this.mouseEnabled = false;
      }
      
      public function setup(param1:MovieClip, param2:uint) : void
      {
         this._fighterResourceId = param2;
         if(param1 != null)
         {
            this._mc = param1;
            addChild(this._mc);
            return;
         }
         throw new Error("没有战斗精灵的素材资源！[" + this._fighterResourceId + "]");
      }
      
      public function get totalFrameNum() : uint
      {
         return this._mc.totalFrames;
      }
      
      public function get currentFrameIndex() : uint
      {
         return this._mc.currentFrame;
      }
      
      public function get currentFrameLabel() : String
      {
         return this._mc.currentFrameLabel;
      }
      
      public function play() : void
      {
         this._mc.play();
      }
      
      public function stop() : void
      {
         this._mc.stop();
      }
      
      public function gotoAndPlay(param1:uint) : void
      {
         this._mc.gotoAndPlay(param1);
      }
      
      public function gotoAndStop(param1:uint) : void
      {
         this._mc.gotoAndStop(param1);
      }
      
      public function hasLabel(param1:String) : Boolean
      {
         var _loc2_:FrameLabel = null;
         var _loc3_:Array = this._mc.currentLabels;
         var _loc5_:int = int(_loc3_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc5_)
         {
            _loc2_ = _loc3_[_loc4_] as FrameLabel;
            if(_loc2_.name == param1)
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      private function adjustCurrentLabel(param1:String) : String
      {
         if(param1 == "濒死" && this.hasLabel("濒死") == false)
         {
            return "失败";
         }
         if(param1 == "个性出场" && this.hasLabel("个性出场") == false)
         {
            return "待机";
         }
         return param1;
      }
      
      private function calculateMode(param1:String) : String
      {
         var _loc2_:String = "blank";
         switch(param1)
         {
            case "待机":
               _loc2_ = "replay";
               break;
            case "属性攻击":
            case "物理攻击":
            case "必杀":
            case "合体攻击":
            case "特殊攻击":
            case "闪避":
            case "被打":
            case "个性出场":
            case "变身效果":
               _loc2_ = "stopIdle";
               break;
            case "濒死":
            case "失败":
            case "胜利":
               _loc2_ = "stopLastFrame";
         }
         return _loc2_;
      }
      
      public function gotoLabel(param1:String) : void
      {
         this.removeActionPlayEventListener();
         this._currentLabel = this.adjustCurrentLabel(param1);
         this._mode = this.calculateMode(this._currentLabel);
         if(this._mode != "blank")
         {
            this._mc.addEventListener("frameConstructed",this.onFrameConstructed);
         }
         this._mc.gotoAndStop(this._currentLabel);
      }
      
      private function onFrameConstructed(param1:Event) : void
      {
         var onActionPlay:Function = null;
         var dispatchHitEvent:Function = null;
         var hitInfo:AnimiationHitInfo = null;
         var time:Number = NaN;
         var evt:Event = param1;
         onActionPlay = function():void
         {
            removeActionPlayEventListener();
            doActionEnd();
         };
         dispatchHitEvent = function():void
         {
            dispatchEvent(new Event("fighterHit"));
         };
         if(this._mc != null && this._mc.numChildren > 0)
         {
            this._mc.removeEventListener("frameConstructed",this.onFrameConstructed);
            this._actionAnimation = this._mc.getChildAt(0) as MovieClip;
            if(this._currentLabel == "物理攻击" || this._currentLabel == "属性攻击" || this._currentLabel == "特殊攻击" || this._currentLabel == "必杀" || this._currentLabel == "合体攻击")
            {
               hitInfo = HitInfoConfig.getHitData(this._fighterResourceId);
               time = hitInfo.getHitValue(this._currentLabel);
               setTimeout(dispatchHitEvent,time);
            }
            this.playAnimation(onActionPlay);
         }
      }
      
      private function playAnimation(param1:Function = null) : void
      {
         this._moviePlayer = new FighterMoviePlayer(this._actionAnimation,param1,40);
      }
      
      private function removeActionPlayEventListener() : void
      {
         if(this._moviePlayer != null)
         {
            this._moviePlayer.destroy();
            this._moviePlayer = null;
         }
      }
      
      private function doActionEnd() : void
      {
         if(this._mode == "stopIdle")
         {
            this.gotoLabel("待机");
         }
         else if(this._mode == "stopLastFrame")
         {
            this._actionAnimation.stop();
         }
         else if(this._mode == "replay")
         {
            this.playAnimation(this.onReplayComplete);
         }
         this.dispathchActionEndEvent("end");
      }
      
      private function onReplayComplete() : void
      {
         this.removeActionPlayEventListener();
         this.playAnimation(this.onReplayComplete);
      }
      
      private function dispathchActionEndEvent(param1:String) : void
      {
         if(this.hasEventListener(param1))
         {
            dispatchEvent(new Event(param1));
         }
      }
      
      public function isStopAllAnimation(param1:Boolean) : void
      {
      }
      
      public function update() : void
      {
      }
      
      public function dispose() : void
      {
         this.removeActionPlayEventListener();
         this._actionAnimation = null;
         if(this._mc != null)
         {
            try
            {
               this._mc.gotoAndStop("空");
            }
            catch(e:*)
            {
            }
            removeChild(this._mc);
         }
         this._mc = null;
      }
   }
}

