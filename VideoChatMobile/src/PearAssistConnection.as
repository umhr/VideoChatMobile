package  
{
    /**
     * ...
     * @author umhr
     */
    import flash.events.AsyncErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroup;

    public class PearAssistConnection extends EventDispatcher
    {
        public static const SERVER    : String = 'rtmfp://p2p.rtmfp.net/';
        public static const GROUPNAME : String = 'jp.mztm.p2p.videochatwonderfl';
        
        //書き換えてね
        public static const DEVKEY    : String = 'dfb4523e3b903bf5b39b1058-2a475abd8e6f';
        
        private var _netConnection:NetConnection;
        private var _netGroup:NetGroup;
        private var _groupSpecifier:GroupSpecifier;
        
        public function PearAssistConnection() 
        {
            _netConnection = new NetConnection();
            _netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncErrorHandler);
            _netConnection.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
            _netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusHandler);
            _netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorHandler);
        }
        
        public function doConnect():void
        {
            _netConnection.connect(SERVER + DEVKEY + '/');
        }
        
        public function doPost(messageData:MessageData):void
        {
            _netGroup.post(messageData.toObject());
        }
        
        private function onConnectCallback():void
        {
            _groupSpecifier = new GroupSpecifier(GROUPNAME);
            _groupSpecifier.postingEnabled = true;
            _groupSpecifier.serverChannelEnabled = true;
            
            //_groupSpecifier.ipMulticastMemberUpdatesEnabled = true;
            _groupSpecifier.multicastEnabled = true;
            
            _netGroup = new NetGroup(_netConnection, _groupSpecifier.toString());
            _netGroup.addEventListener(NetStatusEvent.NET_STATUS, group_netStatus);
        }
        
        private function group_netStatus(event:NetStatusEvent):void 
        {
            switch(event.info.code)
            {
                case 'NetGroup.Neighbor.Connect' : 
                    break;
                case 'NetGroup.Posting.Notify' : 
                    dispatchEvent(event);
                    break;
            }
        }
        
        
        
        private function onNetStatusHandler(event:NetStatusEvent):void 
        {
            switch(event.info.code)
            {
                case 'NetConnection.Connect.Success' :
                    onConnectCallback();
                    break;
                case 'NetGroup.Connect.Success' : 
                    dispatchEvent(new Event(Event.CONNECT));
                    break;
                case 'NetGroup.Connect.Failed' : 
                case 'NetGroup.Connect.Rejected' : 
                case 'NetGroup.Connect.Closed' : 
                    break;
            }
        }
        
        private function onSecurityErrorHandler(event:SecurityErrorEvent):void 
        {
            
        }
        private function onIOErrorHandler(event:IOErrorEvent):void 
        {
            
        }
        
        private function onAsyncErrorHandler(event:AsyncErrorEvent):void 
        {
            
        }
        
        public function get netConnection():NetConnection 
        {
            return _netConnection;
        }
        
        public function get groupSpecifier():GroupSpecifier 
        {
            return _groupSpecifier;
        }
        
    }
}