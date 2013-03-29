package  
{
    /**
     * ...
     * @author umhr
     */
    public class MessageData 
    {
        
        public var user:String;
        public var text:String;
        public var sender:String;
         public function MessageData() 
        {
            
        }
        
        public function toObject():Object {
            
            var result:Object = { };
            
            result.user = user;
            result.text = text;
            result.sender = sender;
            result.uniqueHash = String(new Date().time + Math.random());
            return result;
        }
        
        public function fromObject(object:Object):MessageData {
            user = object.user;
            text = object.text;
            sender = object.sender;
            
            return this;
        }
        
        public function toString():String {
            var result:String = "MessageData:{"
            result += "user:" + user;
            result += ", text:" + text;
            result += ", sender:" + sender;
            result += "}";
            
            return result;
        }
        
    }

}