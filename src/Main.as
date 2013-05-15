package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import org.casalib.util.StageReference;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author nguyen
	 */
	public class Main extends Sprite 
	{
		private var _starling:Starling;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			StageReference.setStage( stage );
			
			_starling = new Starling(Game, this.stage);
			_starling.start();
			Starling.current.showStats = true;
		}
		
	}
	
}