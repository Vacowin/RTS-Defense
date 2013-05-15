package  
{
	
	import com.telosinternational.starlingbasic.Broadcaster;
	import com.telosinternational.starlingbasic.StarlingUtils;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.Sprite;
	import starling.display.Image;
	import com.telosinternational.starlingbasic.touch.VirtualJoystick;
	import starling.utils.AssetManager;
	import starling.events.*;
	
	/**
	 * ...
	 * @author nguyen
	 */
	public class Game extends Sprite
	{
		static public const GET_TEXTURE:String = "Game_GET_TEXTURE";
		static public const GET_TEXTURES:String = "Game_GET_TEXTURES";
		
		static public const WIDTH:int = 800;
		static public const HEIGHT:int = 600;
		
		static public const HALF_WIDTH:int = WIDTH / 2.0;
		static public const HALF_HEIGHT:int = HEIGHT / 2.0;
		
		
		private var _background:Background;
		private var _camera:Camera;
		private var _virtualJoystick:VirtualJoystick;
		private var _move:Boolean;
		
		private var _spriteContainer:Sprite;
		
		private var _lastX:int = 0;
		private var _lastY:int = 0;
		
		private var _touchX:int = 0;
		private var _touchY:int = 0;
		
		private var _cameraX:int = 0;
		private var _cameraY:int = 0;
		
		private var _assetManager:AssetManager;
		public function get assetManager():AssetManager { return _assetManager; }
		
		public function init():void
		{
    
			_assetManager = new AssetManager( 1 );
			_assetManager.enqueue( "assets/imgs/background/spaceBackground.png" );
			_assetManager.enqueue( "assets/imgs/joystick/virtualJoystick.png" );
			_assetManager.enqueue( "assets/imgs/joystick/virtualJoystickBase.png" );
		
			_assetManager.loadQueue( onAssetProgress );
		}
		
		public function destroy():void
		{
			this.stage.removeEventListener( Event.ENTER_FRAME, onUpdate );
			this.stage.removeEventListener( TouchEvent.TOUCH, onTouch );
			
			if ( _assetManager )
			{
				_assetManager.dispose();
				_assetManager = null;
			}	
			if ( _virtualJoystick )
			{
				_virtualJoystick.destroy();
				_virtualJoystick = null;
			}
			if ( _camera )
			{
				_camera = null;
			}
			if ( _background )
			{
				_background.removeFromParent();
				_background = null;
			}
		}
		
		private function onAssetProgress( ratio:Number ):void
		{
			trace( "[Game] Load progress - " + ratio.toString() );
			
			if ( ratio == 1 )
			{
				startGame();
			}
		}
		
		private function startGame():void
		{
			Broadcaster.instance.addAppListener( GET_TEXTURE, _assetManager, _assetManager.getTexture );
			Broadcaster.instance.addAppListener( GET_TEXTURES, _assetManager, _assetManager.getTextures );
			
			_spriteContainer = new Sprite();
			
			_virtualJoystick = new VirtualJoystick( 50, _assetManager.getTexture( "virtualJoystick" ), _assetManager.getTexture( "virtualJoystickBase" ) );
			
			var bgChucks:Vector.<Image> = new Vector.<Image>();
			bgChucks.push( new Image( _assetManager.getTexture( "spaceBackground" ) ) );
			
			_background = new Background();
			_background.worldX = 0;
			_background.worldY = 0;
			_background.setChunks( bgChucks ); 
			_spriteContainer.addChild( _background );
			
			this.addChild( _spriteContainer );
			this.addChild( _virtualJoystick );
			_camera = new Camera( Game.WIDTH, Game.HEIGHT );
			_camera.x = _background.width / 2;
			_camera.y = _background.height / 2;
			
			this.addEventListener( TouchEvent.TOUCH, onTouch );
			this.stage.addEventListener( Event.ENTER_FRAME, onUpdate );
			this.stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var leftStart:Touch = e.getTouch( this, TouchPhase.BEGAN );
			var leftMove:Touch = e.getTouch( this, TouchPhase.MOVED );
			var leftEnd:Touch = e.getTouch( this, TouchPhase.ENDED );
		
			//
			// LEFT INPUT
			if ( leftStart )
			{
				_touchX = leftStart.globalX;
				_touchY = leftStart.globalY;
				
				_virtualJoystick.activate( new Point( _touchX, _touchY ) );
			}
			if ( leftMove )
			{
				_move = true;
				_touchX = leftMove.globalX;
				_touchY = leftMove.globalY;
				
				_virtualJoystick.updateJoystick( _touchX, _touchY );
			}
			if ( leftEnd )
			{
				_move = false;
				_virtualJoystick.deactivate();
			}
		}
		
		private function onUpdate(e:Event):void 
		{
			_camera.x += _virtualJoystick.stickX * 5;
			_camera.y += _virtualJoystick.stickY * 5;;
		
			//
			// RENDER
			//
			_camera.follow( _camera.x, _camera.y, new Rectangle( 0, 0, _background.totalWidth, _background.totalHeight ) );		
			_camera.adjustForScreen( _background );
			//trace(_background.x + "    " + _background.y + "          "+_camera.x+"  "+_camera.y+ "          "+_background.width+"  "+_background.height);
		}
		private function onKeyUp(e:KeyboardEvent = null):void 
		{
			
		}
		
		public function Game() 
		{
			init();
		}
		
	}

}