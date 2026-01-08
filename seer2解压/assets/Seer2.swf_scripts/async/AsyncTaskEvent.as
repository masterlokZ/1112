package async
{
   import flash.events.Event;
   
   public class AsyncTaskEvent extends Event
   {
      
      private var _task:AsyncTask;
      
      public function AsyncTaskEvent(param1:String, param2:AsyncTask, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._task = param2;
      }
      
      public function get task() : AsyncTask
      {
         return this._task;
      }
      
      override public function clone() : Event
      {
         return new AsyncTaskEvent(type,this._task,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("AsyncTaskEvent","type","task","bubbles","cancelable");
      }
   }
}

