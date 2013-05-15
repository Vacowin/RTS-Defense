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
		static public const GET_CAMERA:String = "GET_CAMERA";
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
		
		private var _scrollSpeed:int = 10;
		private var _keysDown:Vector.<uint>;
		private var _leftDown:Boolean = false;
		private var _rightDown:Boolean = false;
		private var _upDown:Boolean = false;
		private var _downDown:Boolean = false;
		private var _xDir:Number = 0;
		private var _yDir:Number = 0;		
		
		private var _assetManager:AssetManager;
		public function get assetManager():AssetManager { return _assetManager; }
		
		private var turret:Turret;
		private var arrayTurret:Vector.<Turret>;
		
		public function init():void
		{
    
			_assetManager = new AssetManager( 1 );
			_assetManager.enqueue( "assets/imgs/background/spaceBackground.png" );
			_assetManager.enqueue( "assets/imgs/ship/ship1.png" );
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
			Broadcaster.instance.addAppListener( GET_CAMERA, this, function():Camera { return _camera;} );
			
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
			
			_keysDown = new Vector.<uint>();
			
			turret = new Turret(_background.width / 2, _background.height / 2);
			_spriteContainer.addChild(turret);
			
			arrayTurret = new Vector.<Turret>();
			for (var i:int = 0; i < 0; i++)
			{
				var t:Turret = new Turret(Math.random() * 800, Math.random() * 600);
				_spriteContainer.addChild(t);
				arrayTurret.push(t);
			}
			
			//this.addEventListener( TouchEvent.TOUCH, onTouch );
			this.stage.addEventListener( Event.ENTER_FRAME, onUpdate );
			this.stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			this.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
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
			handleKeys();
			
			//_camera.x += _virtualJoystick.stickX * 5;
			//_camera.y += _virtualJoystick.stickY * 5;;
			_camera.x += _xDir * _scrollSpeed;
			_camera.y += _yDir * _scrollSpeed;
		
			//
			// RENDER
			//
			_camera.follow( _camera.x, _camera.y, new Rectangle( 0, 0, _background.totalWidth, _background.totalHeight ) );		
			_camera.adjustForScreen( _background );
			
			for (var i:int = 0; i < arrayTurret.length; i++)
			{
				_camera.adjustForScreen((Turret)(arrayTurret[i]));
			}
			_camera.adjustForScreen(turret);
			//trace(_background.x + "    " + _background.y + "          "+_camera.x+"  "+_camera.y+ "          "+_background.width+"  "+_background.height);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if ( _keysDown.indexOf( e.keyCode ) < 0 )
			{
				_keysDown.push( e.keyCode );
			}
		}
		
		private function onKeyUp(e:KeyboardEvent = null):void 
		{
			if ( _keysDown.indexOf( e.keyCode ) >= 0 )
			{
				_keysDown.splice( _keysDown.indexOf( e.keyCode ), 1 );
			}
		}
		
		private function handleKeys():void
		{
			_leftDown = false;
			_rightDown = false;
			_upDown = false;
			_downDown = false;
			_xDir = 0;
			_yDir = 0;
			
			for each ( var keyCode:uint in _keysDown )
			{			
				switch ( keyCode )
				{
					case 37:
						_leftDown = true;
						_xDir = -1;
						break;
					case 38:
						_upDown = true;
						_yDir = -1;
						break;
					case 39:
						_rightDown = true;
						_xDir = 1;
						break;
					case 40:
						_downDown = true;
						_yDir = 1
						break;
					
				}
			}
		}
		
		public function Game() 
		{
			init();
		}
		
	}

}