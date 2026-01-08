package events
{
   import flash.events.Event;
   
   public class XMLEvent extends Event
   {
      
      public static const OPEN:String = "open";
      
      public static const COMPLETE:String = "complete";
      
      private var _data:XML;
      
      public function XMLEvent(param1:String, param2:XML)
      {
         super(param1);
         this._data = param2;
      }
      
      public function get data() : XML
      {
         return this._data;
      }
   }
}

