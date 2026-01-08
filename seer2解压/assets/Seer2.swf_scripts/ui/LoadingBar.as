package ui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class LoadingBar extends Sprite
   {
      
      private var _stage:Stage;
      
      private var _container:MovieClip;
      
      private var _numberVec:Vector.<MovieClip>;
      
      private var _root:Client;
      
      private var tipTxt:TextField;
      
      private var errorTxt:TextField;
      
      private var inputTxt:TextField;
      
      private var confirmBtn:SimpleButton;
      
      private var clearBtn:SimpleButton;
      
      public function LoadingBar(param1:Stage, param2:Client)
      {
         super();
         this._stage = param1;
         this._root = param2;
      }
      
      public function setup(param1:Class) : void
      {
         this._container = new param1() as MovieClip;
         this._container.gotoAndStop(1);
         addChild(this._container);
         var _loc2_:MovieClip = this._container["num"];
         this.tipTxt = this._container["tipTxt"];
         this._numberVec = new Vector.<MovieClip>();
         this._numberVec.push(_loc2_["unit"]);
         this._numberVec[0].gotoAndStop(1);
         this._numberVec.push(_loc2_["ten"]);
         this._numberVec[1].gotoAndStop(1);
         this._numberVec.push(_loc2_["hundred"]);
         this._numberVec[2].gotoAndStop(1);
         this._stage.addEventListener("resize",this.onResize);
         this.onResize(null);
      }
      
      private function onResize(param1:Event) : void
      {
         if(this._container)
         {
            this._container.scaleX = this._root.width / 1200;
            this._container.scaleY = this._root.height / 660;
         }
      }
      
      public function dispose() : void
      {
         this.hide();
         this._container = null;
         this._numberVec = null;
         this._stage.removeEventListener("resize",this.onResize);
      }
      
      public function show(param1:DisplayObjectContainer) : void
      {
         param1.addChild(this._container);
      }
      
      public function showError(param1:String) : void
      {
         this._container.gotoAndStop(2);
         this.errorTxt = this._container["title"];
         this.errorTxt.selectable = true;
         this.errorTxt.text = param1;
      }
      
      public function inputText(param1:String, param2:Function) : void
      {
         var str:String = param1;
         this._container.gotoAndStop(3);
         this.errorTxt = this._container["title"];
         this.errorTxt.selectable = true;
         this.errorTxt.text = str;
         this.inputTxt = this._container["inputText"];
         this.inputTxt.text = "";
         this.confirmBtn = this._container["confirm"];
         this.clearBtn = this._container["clear"];
         this.confirmBtn.addEventListener("click",function(param1:Event):void
         {
            _container.gotoAndStop(1);
            param2(inputTxt.text);
         });
         this.clearBtn.addEventListener("click",function(param1:Event):void
         {
            inputTxt.text = "";
         });
      }
      
      public function hide() : void
      {
         if(this._container.parent)
         {
            this._container.parent.removeChild(this._container);
         }
      }
      
      public function progress(param1:int) : void
      {
         this.updateNum(param1);
      }
      
      public function setTitle(param1:String) : void
      {
         this.tipTxt = this._container["tipTxt"];
         this.tipTxt.text = param1;
      }
      
      private function updateNum(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = param1.toString().split("").reverse();
         _loc2_ = 0;
         while(_loc2_ < 3)
         {
            if(_loc2_ < _loc3_.length)
            {
               this._numberVec[_loc2_].visible = true;
               this._numberVec[_loc2_].gotoAndStop(int(_loc3_[_loc2_]) + 1);
            }
            else
            {
               this._numberVec[_loc2_].visible = false;
            }
            _loc2_++;
         }
      }
   }
}

