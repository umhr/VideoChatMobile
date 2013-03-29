package  
{
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
    public class VideoPart extends Sprite 
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
}