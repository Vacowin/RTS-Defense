package  
{
	import Interfaces.IRenderable;
	import com.telosinternational.starlingbasic.Broadcaster;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.RenderTexture;
	/**
	 * ...
	 * @author Aaron Malley
	 */
	public class Background extends Sprite implements IRenderable
	{
		static public const GET_WALKABLE_ZONE:String = "Background_GET_WALKABLE_ZONE";
		
		private var _walkZone:Rectangle;		
		public function get walkZone():Rectangle { return _walkZone; }
		
		private var _totalWidth:int = 0;		
		public function get totalWidth():int { return _totalWidth; }
		
		private var _totalHeight:int = 0;
		public function get totalHeight():int { return _totalHeight; }
		
		//
		// Override so there are no half pixels for the background. This will eliminate seams between the ground chucks.
		override public function set x(value:Number):void { super.x = Math.floor( value ); }
		
		public function Background() 
		{
			Broadcaster.instance.addAppListener( GET_WALKABLE_ZONE, this, function():Rectangle { return _walkZone; } );
		}
		
		/*
		 * Public methods
		 */ 
		public function setChunks( chunks:Vector.<Image> ):void
		{
			for ( var i:int = 0; i < chunks.length; i++ )
			{
				chunks[i].x = this.numChildren == 0 ? 0 : int( this.getChildAt( this.numChildren - 1 ).x + this.getChildAt( this.numChildren - 1 ).width ) - 1;
				chunks[i].y = 0;
				
				this.addChild( chunks[i] );
				
				_totalWidth += chunks[i].width;
				_totalHeight = _totalHeight < chunks[i].height ? chunks[i].height : _totalHeight;
			}
			
			_walkZone = new Rectangle( 0, 380, _totalWidth, _totalHeight - 380 );
		}
		public function destroy():void
		{
			while ( this.numChildren > 0 )
			{
				this.removeChildAt( 0, true );
			}
			_walkZone = null;
		}
		/*
		 * IRendererable implementation
		 */ 
		private var _worldX:Number;		
		public function get worldX():Number { return _worldX; }		
		public function set worldX(value:Number):void { _worldX = value; }
		
		private var _worldY:Number;
		public function get worldY():Number { return _worldY; }		
		public function set worldY(value:Number):void { _worldY = value; }
		
		public function lockBounds( zone:Rectangle ):void { }
	}
}