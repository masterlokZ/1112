package async
{
   import flash.events.EventDispatcher;
   
   public class AsyncTask extends EventDispatcher
   {
      
      public static const COMPLETE:String = "asyncTaskComplete";
      
      public static const ERROR:String = "asyncTaskError";
      
      private var _name:String;
      
      private var _executeFunc:Function;
      
      private var _isExecuting:Boolean = false;
      
      private var _isCompleted:Boolean = false;
      
      private var _result:*;
      
      private var _error:String;
      
      public function AsyncTask(param1:String, param2:Function)
      {
         super();
         this._name = param1;
         this._executeFunc = param2;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get isExecuting() : Boolean
      {
         return this._isExecuting;
      }
      
      public function get isCompleted() : Boolean
      {
         return this._isCompleted;
      }
      
      public function get result() : *
      {
         return this._result;
      }
      
      public function get error() : String
      {
         return this._error;
      }
      
      public function execute() : void
      {
         if(this._isExecuting || this._isCompleted)
         {
            return;
         }
         this._isExecuting = true;
         try
         {
            this._executeFunc(this.complete,this.onError);
         }
         catch(e:Error)
         {
            this.onError("Task execution failed: " + e.message);
         }
      }
      
      public function complete(param1:* = null) : void
      {
         if(!this._isExecuting)
         {
            return;
         }
         this._isExecuting = false;
         this._isCompleted = true;
         this._result = param1;
         dispatchEvent(new AsyncTaskEvent("asyncTaskComplete",this));
      }
      
      public function onError(param1:String) : void
      {
         if(!this._isExecuting)
         {
            return;
         }
         this._isExecuting = false;
         this._isCompleted = true;
         this._error = param1;
         dispatchEvent(new AsyncTaskEvent("asyncTaskError",this));
      }
      
      public function reset() : void
      {
         this._isExecuting = false;
         this._isCompleted = false;
         this._result = null;
         this._error = null;
      }
   }
}

