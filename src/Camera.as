package  
{
	import Interfaces.IRenderable;
	import com.telosinternational.starlingbasic.Broadcaster;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.events.Event;
	/**
	 * ...
	 * @author Aaron Malley
	 */
	public class Camera extends DisplayObject
	{	
		static public const GET_CAMERA:String = "Camera_GET_CAMERA";
		
		private var _rect:Rectangle;		
		public function get rect():Rectangle { return _rect; }
		
		public function Camera( width:int, height:int ) 
		{
			_rect = new Rectangle( width / 2.0, height / 2.0, width, height );
			this.addEventListener(Event.ADDED_TO_STAGE, onCameraAddedToStage );
			
			Broadcaster.instance.addAppListener( GET_CAMERA, this, getCamera );
		}
		
		/*
		 * Public methods
		 */ 
		public function follow( worldX:Number, worldY:Number, bounds:Rectangle = null ):void
		{
			this.x = worldX;
			this.y = worldY;
			
			if ( bounds )
			{
				lockBounds( bounds );	
			}
		}
		public function adjustForScreen( object:IRenderable ):void
		{
			object.x = int( _rect.x + ( object.worldX - this.x ) );
			object.y = int( _rect.y + ( object.worldY - this.y ) );
		}
		public function lockBounds( zone:Rectangle ):void
		{
			if ( this.x - _rect.x < zone.x )
			{
				this.x = _rect.x;
			}
			else if (  this.x + _rect.x > zone.width )
			{
				this.x = zone.width - _rect.x;
			}
			if ( this.y - _rect.y < zone.y )
			{
				this.y = _rect.y;
			}
			else if (  this.y + _rect.y > zone.height )
			{
				this.y = zone.height - _rect.y;
			}
		}
		
		/*
		 * Private methods
		 */ 
		private function onCameraAddedToStage(e:Event):void
		{
			throw new Error( "[Camera] Cannot add a Camera object to the stage." ); 
		}
		private function getCamera():Camera
		{
			return this;
		}
	}
}