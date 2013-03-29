package  
{
    import com.bit101.components.*;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NetStatusEvent;
    
    public class VideoChat extends Sprite{
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
}