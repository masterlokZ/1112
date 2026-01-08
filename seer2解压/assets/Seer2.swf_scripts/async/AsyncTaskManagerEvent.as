package async
{
   import flash.events.Event;
   
   public class AsyncTaskManagerEvent extends Event
   {
      
      private var _task:AsyncTask;
      
      public function AsyncTaskManagerEvent(param1:String, param2:AsyncTask = null, param3:Boolean = false, param4:Boolean = false)
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
         return new AsyncTaskManagerEvent(type,this._task,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("AsyncTaskManagerEvent","type","task","bubbles","cancelable");
      }
   }
}

