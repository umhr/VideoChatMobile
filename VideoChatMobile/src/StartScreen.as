package  
{
	import com.bit101.components.*;
	import flash.display.Sprite;
	public class StartScreen extends Sprite{
		public var bt:PushButton;
		public function StartScreen(){
			graphics.beginFill(0, .9);
			graphics.drawRect(0, 0, 465, 465);
			bt = new PushButton(this, 180, 210, "Start Connect", null);
			bt.height = 40;
			new Label(this, 95, 260, "To begin, please click the connections");
		}
	}

}