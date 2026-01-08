package events
{
   import flash.events.Event;
   
   public class DNSResolveEvent extends Event
   {
      
      private var _data:String;
      
      public function DNSResolveEvent(param1:String, param2:String)
      {
         super(param1);
         this._data = param2;
      }
      
      public function get data() : String
      {
         return _data;
      }
      
      override public function clone() : Event
      {
         return new DNSResolveEvent(type,_data);
      }
   }
}

