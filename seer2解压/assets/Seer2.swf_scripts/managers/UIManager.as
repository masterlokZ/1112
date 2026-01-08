package managers
{
   import com.seer2.extensions.resolution.ResolutionController;
   import flash.desktop.NativeApplication;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.ContextMenu;
   import ui.Background;
   import ui.LoadingBar;
   
   public class UIManager
   {
      
      private var _stage:Stage;
      
      private var _root:Sprite;
      
      private var _progressBar:LoadingBar;
      
      private var _loginContent:DisplayObject;
      
      private var _background:Background;
      
      private var _closeButton:SimpleButton;
      
      private var _fixWidth:Number;
      
      private var _fixHeight:Number;
      
      public function UIManager(param1:Stage, param2:Sprite)
      {
         super();
         this._stage = param1;
         this._root = param2;
      }
      
      public function initializeStage() : void
      {
         var _loc1_:ContextMenu = new ContextMenu();
         _loc1_.hideBuiltInItems();
         this._root.contextMenu = _loc1_;
         if(this._stage.stageWidth > this._stage.stageHeight * 1.82)
         {
            ResolutionController.instance.setResolutionScale(this._stage.stageHeight / 660);
         }
         else
         {
            ResolutionController.instance.setResolutionScale(this._stage.stageWidth / 1200);
         }
      }
      
      public function setupGameArea() : void
      {
         if(this._stage.stageWidth > this._stage.stageHeight * 1.82)
         {
            this._fixWidth = int(this._stage.stageHeight * 1.82);
            this._fixHeight = this._stage.stageHeight;
         }
         else
         {
            this._fixWidth = this._stage.stageWidth;
            this._fixHeight = int(this._stage.stageWidth * 0.55);
         }
         this._root.width = this._fixWidth;
         this._root.height = this._fixHeight;
         this._root.x = (this._stage.stageWidth - this._fixWidth) / 2;
         this._root.y = (this._stage.stageHeight - this._fixHeight) / 2;
         this._root.scrollRect = new Rectangle(0,0,this._fixWidth,this._fixHeight);
      }
      
      public function createBackground() : void
      {
         this._background = new Background();
         this._stage.addEventListener("resize",function(param1:Event):void
         {
            if(_background)
            {
               _background.width = _stage.stageWidth;
               _background.height = _stage.stageHeight;
            }
         });
         this._background.width = this._stage.stageWidth;
         this._background.height = this._stage.stageHeight;
         this._stage.addChildAt(this._background,0);
      }
      
      public function createCloseButton() : void
      {
         this._closeButton = this.createButton(0,0,25,100,"关闭游戏");
         this._closeButton.addEventListener("click",this.onCloseGame);
         this._stage.addChild(this._closeButton);
      }
      
      private function createButton(param1:int, param2:int, param3:int, param4:int, param5:String) : SimpleButton
      {
         var x:int = param1;
         var y:int = param2;
         var height:int = param3;
         var width:int = param4;
         var label:String = param5;
         var createButtonState:Function = function(param1:uint, param2:String):Sprite
         {
            var _loc3_:Sprite = new Sprite();
            _loc3_.graphics.beginFill(param1);
            _loc3_.graphics.drawRect(0,0,width,height);
            _loc3_.graphics.endFill();
            var _loc4_:TextField = createStaticText(0,0,height,width,false);
            _loc4_.text = param2;
            _loc4_.selectable = false;
            _loc3_.addChild(_loc4_);
            return _loc3_;
         };
         var normalState:Sprite = createButtonState(5591163,label);
         var hoverState:Sprite = createButtonState(7700386,label);
         var downState:Sprite = createButtonState(6369338,label);
         var disabledState:Sprite = createButtonState(6369338,"已禁用");
         var button:SimpleButton = new SimpleButton(normalState,hoverState,downState,disabledState);
         button.x = x;
         button.y = y;
         return button;
      }
      
      private function createStaticText(param1:int, param2:int, param3:int, param4:int, param5:Boolean) : TextField
      {
         var _loc6_:TextField = new TextField();
         var _loc7_:TextFormat = new TextFormat();
         _loc6_.text = "";
         _loc6_.x = param1;
         _loc6_.y = param2;
         _loc6_.height = param3;
         _loc6_.width = param4;
         _loc6_.mouseEnabled = param5;
         _loc6_.alpha = 0.9;
         _loc7_.size = param3 - 3;
         _loc7_.color = 10798591;
         _loc6_.defaultTextFormat = _loc7_;
         return _loc6_;
      }
      
      public function setupProgressBar(param1:Class, param2:*) : void
      {
         this._progressBar = new LoadingBar(this._stage,param2);
         this._progressBar.setup(param1);
      }
      
      public function showProgressBar() : void
      {
         if(this._progressBar)
         {
            this._progressBar.show(this._root);
         }
      }
      
      public function hideProgressBar() : void
      {
         if(this._progressBar)
         {
            this._progressBar.hide();
         }
      }
      
      public function setProgressTitle(param1:String) : void
      {
         if(this._progressBar)
         {
            this._progressBar.setTitle(param1);
         }
      }
      
      public function updateProgress(param1:int) : void
      {
         if(this._progressBar)
         {
            this._progressBar.progress(param1);
         }
      }
      
      public function showError(param1:String) : void
      {
         if(this._progressBar)
         {
            this._progressBar.showError(param1);
         }
      }
      
      public function inputText(param1:String, param2:Function) : void
      {
         if(this._progressBar)
         {
            this._progressBar.inputText(param1,param2);
         }
      }
      
      public function setLoginContent(param1:DisplayObject) : void
      {
         this._loginContent = param1;
         this._root.addChild(this._loginContent);
         this.layoutLoginContent();
      }
      
      public function removeLoginContent() : void
      {
         if(this._loginContent && this._root.contains(this._loginContent))
         {
            this._root.removeChild(this._loginContent);
            this._loginContent = null;
         }
      }
      
      public function layoutLoginContent() : void
      {
         if(this._loginContent && this._loginContent.hasOwnProperty("layOut"))
         {
            this._loginContent["layOut"](this._root);
         }
      }
      
      private function onCloseGame(param1:MouseEvent) : void
      {
         ResolutionController.instance.dispose();
         NativeApplication.nativeApplication.exit();
      }
      
      public function dispose() : void
      {
         if(this._progressBar)
         {
            this._progressBar.dispose();
            this._progressBar = null;
         }
         this.removeLoginContent();
      }
      
      public function get fixWidth() : Number
      {
         return this._fixWidth;
      }
      
      public function get fixHeight() : Number
      {
         return this._fixHeight;
      }
      
      public function get progressBar() : LoadingBar
      {
         return this._progressBar;
      }
   }
}

