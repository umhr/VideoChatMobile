// forked from mousepancyo's RTMFPビデオチャット（RTMFP Video Chat Example）
package  
{
    import flash.display.Sprite;
    /**
     * ...
     * @author umhr
     */
    [SWF(width = "465", height = "465", backgroundColor = "0", frameRate = "30")]
    public class WonderflMain extends Sprite
    {
        
        public function WonderflMain() 
        {
            addChild(new VideoChat());
        }
        
    }

}


    import com.bit101.components.*;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NetStatusEvent;
    
    class VideoChat extends Sprite{
        private var _braodCastBtn:PushButton;
        private var _sendMessageBtn:PushButton;
        private var _messageTxt:TextArea;
        private var _inputTxt:InputText;
        private var _startScreen:StartScreen;
        private var _videoPart:VideoPart;
        private var _connection:PearAssistConnection;
        
        public function VideoChat() {
            init();
        }
        private function init():void 
        {
            if (stage) onInit();
            else addEventListener(Event.ADDED_TO_STAGE, onInit);
        }
        
        private function onInit(event:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, onInit);
            // entry point
            
            addChild(new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0))); 
            
            _videoPart = new VideoPart();
            addChild(_videoPart);
            
            _connection = new PearAssistConnection();
            
            Style.embedFonts = false;
            Style.fontName = "_typewriter";
            Style.fontSize = 12;
            _braodCastBtn = new PushButton(this, 359, 8, "Broad Cast", broadCast);
			_braodCastBtn.height = 40;
			_braodCastBtn.enabled = false;
            _sendMessageBtn = new PushButton(this, 359, 256, "Send Message", sendMsg);
			_sendMessageBtn.height = 40;
			_sendMessageBtn.enabled = false;
            _messageTxt = new TextArea(this, 8, 304);
            _messageTxt.width = 450;
            _messageTxt.height = 150;
            _inputTxt = new InputText(this, 8, 276);
            _inputTxt.width = 342;
            _inputTxt.height = 20;
            new Label(this, 8, 258, "Send Message");
            //
            _startScreen = new StartScreen();
            _startScreen.bt.addEventListener(MouseEvent.CLICK, doConnect);
            addChild(_startScreen);
        }
        
        private function doConnect(e:MouseEvent):void {
            _startScreen.bt.removeEventListener(MouseEvent.CLICK, doConnect);
            removeChild(_startScreen);
            //
            trace("doConnect");
            _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.addEventListener(Event.CONNECT, connection_connect);
            _connection.doConnect();
        }

        private function connection_connect(event:Event):void 
        {
            watchStream();
        }
        private function netStatusHandler(e:NetStatusEvent):void {
            trace(e.target, e.info.code);
            _messageTxt.text = e.info.code + "\n" + _messageTxt.text;
            switch(e.info.code){
                case "NetConnection.Connect.Success":
                    break;
                case "NetGroup.Connect.Success":
                    break;
                case "NetStream.Connect.Success":
                    break;
                case "NetStream.Publish.Start":
                    break;
                case "NetGroup.Posting.Notify":
                    _messageTxt.text = e.info.message.text + "\n\n" +_messageTxt.text;
                    break;
            }
        }
        
        
        // NetStream
        private function broadCast(e:MouseEvent):void {
            _braodCastBtn.removeEventListener(MouseEvent.CLICK, watchStream);
            _braodCastBtn.enabled = false;
            _videoPart.setUpCamera();
            trace("broadCast");
            _videoPart.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _videoPart.broadCast(_connection.netConnection, _connection.groupSpecifier);
        }
        private function sendMsg(e:MouseEvent):void{
            var messageData:MessageData = new MessageData();
            messageData.text = _inputTxt.text;
            _connection.doPost(messageData);
        }
        private function watchStream():void {
            trace("watchStream");
            _videoPart.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _videoPart.watchStream(_connection.netConnection, _connection.groupSpecifier);
			_sendMessageBtn.enabled = true;
			_braodCastBtn.enabled = true;
        }
    }


import com.bit101.components.*;
import flash.display.Sprite;
class StartScreen extends Sprite{
    public var bt:PushButton;
    public function StartScreen(){
        graphics.beginFill(0, .9);
        graphics.drawRect(0, 0, 465, 465);
        bt = new PushButton(this, 180, 210, "Start Connect", null);
		bt.height = 40;
        new Label(this, 95, 260, "To begin, please click the connections");
    }
}

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

    class PearAssistConnection extends EventDispatcher
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


    
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.NetStatusEvent;
    import flash.media.Camera;
    import flash.media.Microphone;
    import flash.media.SoundCodec;
    import flash.media.Video;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    /**
     * ...
     * @author umhr
     */
    class VideoPart extends Sprite 
    {
        
        private var _cam:Camera;
        private var _mic:Microphone;
        private var _video:Video;
        private var _ns:NetStream;
        private var _rns:NetStream;
        private var _streamName:String = "MultiCastStream";
        public function VideoPart() 
        {
            init();
        }
        private function init():void 
        {
            if (stage) onInit();
            else addEventListener(Event.ADDED_TO_STAGE, onInit);
        }
        
        private function onInit(event:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, onInit);
            // entry point
            
            _video = new Video(320, 240);
            _video.x = 8;
            _video.y = 8;
            
            var sp2:Shape = new Shape();
			sp2.graphics.beginFill(0x222222);
            sp2.graphics.drawRect(_video.x, _video.y, 320, 240);
            sp2.graphics.drawRect(_video.x + 3, _video.y + 3, 320 - 6, 240 - 6);
            addChild(sp2);
            addChild(_video);
            
        }
        
        public function setUpCamera():void{
            _cam = Camera.getCamera();
            _cam.setMode(320, 240, 15);
            _cam.setQuality(0, 90);
            _mic = Microphone.getMicrophone();
            _mic.codec = SoundCodec.SPEEX;
            _mic.setLoopBack();
            var video:Video = new Video(120, 90);
            video.x = 338;
            video.y = 156;
            video.attachCamera(_cam);
            addChild(video);
        }
        
        public function broadCast(_nc:NetConnection, _gs:GroupSpecifier):void {
            _ns = new NetStream(_nc, _gs.groupspecWithAuthorizations());
            _ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _ns.attachCamera(_cam);
            _ns.attachAudio(_mic);
            _ns.publish(_streamName);
            
        }
        public function watchStream(_nc:NetConnection, _gs:GroupSpecifier):void {
            _rns = new NetStream(_nc, _gs.groupspecWithAuthorizations());
            _rns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _video.attachNetStream(_rns);
            _rns.play(_streamName);
        }
        
        public function netStatusHandler(event:NetStatusEvent):void {
            dispatchEvent(event);
        }
        
    }
    
    /**
     * ...
     * @author umhr
     */
    class MessageData 
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

