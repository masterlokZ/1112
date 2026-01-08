package async
{
   import flash.events.EventDispatcher;
   
   public class AsyncTaskManager extends EventDispatcher
   {
      
      public static const QUEUE_COMPLETE:String = "queueComplete";
      
      public static const QUEUE_ERROR:String = "queueError";
      
      public static const TASK_COMPLETE:String = "taskComplete";
      
      private var _tasks:Vector.<AsyncTask>;
      
      private var _currentIndex:int = 0;
      
      private var _isExecuting:Boolean = false;
      
      private var _onComplete:Function;
      
      private var _onError:Function;
      
      private var _onTaskComplete:Function;
      
      public function AsyncTaskManager()
      {
         super();
         this._tasks = new Vector.<AsyncTask>();
      }
      
      public function addTask(param1:AsyncTask) : AsyncTaskManager
      {
         this._tasks.push(param1);
         return this;
      }
      
      public function createTask(param1:String, param2:Function) : AsyncTaskManager
      {
         var _loc3_:AsyncTask = new AsyncTask(param1,param2);
         return this.addTask(_loc3_);
      }
      
      public function execute(param1:Function = null, param2:Function = null, param3:Function = null) : void
      {
         if(this._isExecuting)
         {
            return;
         }
         if(this._tasks.length == 0)
         {
            if(param1 != null)
            {
               param1();
            }
            return;
         }
         this._onComplete = param1;
         this._onError = param2;
         this._onTaskComplete = param3;
         this._currentIndex = 0;
         this._isExecuting = true;
         this.executeNext();
      }
      
      private function executeNext() : void
      {
         if(this._currentIndex >= this._tasks.length)
         {
            this._isExecuting = false;
            if(this._onComplete != null)
            {
               this._onComplete();
            }
            dispatchEvent(new AsyncTaskManagerEvent("queueComplete"));
            return;
         }
         var _loc1_:AsyncTask = this._tasks[this._currentIndex];
         _loc1_.addEventListener("asyncTaskComplete",this.onTaskComplete);
         _loc1_.addEventListener("asyncTaskError",this.onTaskError);
         _loc1_.execute();
      }
      
      private function onTaskComplete(param1:AsyncTaskEvent) : void
      {
         var _loc2_:AsyncTask = param1.task;
         _loc2_.removeEventListener("asyncTaskComplete",this.onTaskComplete);
         _loc2_.removeEventListener("asyncTaskError",this.onTaskError);
         if(this._onTaskComplete != null)
         {
            this._onTaskComplete(_loc2_);
         }
         dispatchEvent(new AsyncTaskManagerEvent("taskComplete",_loc2_));
         this._currentIndex++;
         this.executeNext();
      }
      
      private function onTaskError(param1:AsyncTaskEvent) : void
      {
         var _loc2_:AsyncTask = param1.task;
         _loc2_.removeEventListener("asyncTaskComplete",this.onTaskComplete);
         _loc2_.removeEventListener("asyncTaskError",this.onTaskError);
         this._isExecuting = false;
         if(this._onError != null)
         {
            this._onError(_loc2_.error,_loc2_);
         }
         dispatchEvent(new AsyncTaskManagerEvent("queueError",_loc2_));
      }
      
      public function get currentTask() : AsyncTask
      {
         if(this._currentIndex < this._tasks.length)
         {
            return this._tasks[this._currentIndex];
         }
         return null;
      }
      
      public function getPreviousTaskResult() : *
      {
         var _loc1_:AsyncTask = null;
         if(this._currentIndex > 0 && this._currentIndex <= this._tasks.length)
         {
            _loc1_ = this._tasks[this._currentIndex - 1];
            return _loc1_.result;
         }
         return null;
      }
      
      public function get taskCount() : int
      {
         return this._tasks.length;
      }
      
      public function get progress() : Number
      {
         if(this._tasks.length == 0)
         {
            return 1;
         }
         return this._currentIndex / this._tasks.length;
      }
      
      public function get isExecuting() : Boolean
      {
         return this._isExecuting;
      }
      
      public function clear() : void
      {
         if(this._isExecuting)
         {
            return;
         }
         for each(var _loc1_ in this._tasks)
         {
            _loc1_.reset();
         }
         this._tasks.length = 0;
         this._currentIndex = 0;
      }
      
      public function stop() : void
      {
         this._isExecuting = false;
         if(this.currentTask != null)
         {
            this.currentTask.removeEventListener("asyncTaskComplete",this.onTaskComplete);
            this.currentTask.removeEventListener("asyncTaskError",this.onTaskError);
         }
      }
   }
}

