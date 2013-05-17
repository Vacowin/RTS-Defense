package  
{
	
	public class Vector2D 
	{
		private var _x: Number;
		private var _y: Number;
		
		public static const DEGRAD: Number = Math.PI / 180;
		
		public function Vector2D(x:Number=0, y:Number=0) 
		{
			_x = x;
			_y = y;
		}
		
		public function clone():Vector2D
		{
			return new Vector2D(_x, _y);
		}
		
		public function add(v2 : Vector2D): Vector2D
		{
			return new Vector2D(_x + v2.x,  _y + v2.y);			
		}
		
		public function subtract(v2 : Vector2D): Vector2D
		{
			return new Vector2D(_x - v2.x, _y - v2.y);			
		}
		
		public function multiply(num : Number): Vector2D
		{
			return new Vector2D(_x * num,  _y * num);			
		}
		
		public function divide(num : Number): Vector2D
		{
			return new Vector2D(_x / num,  _y / num);			
		}
		
		public  function distance(v2 : Vector2D): Number
		{
			var deltaX:Number = _x - v2.x;
			var deltaY:Number = _y - v2.y;
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		}
		
		public function distanceSqr(v2 : Vector2D): Number
		{
			var deltaX:Number = _x - v2.x;
			var deltaY:Number = _y - v2.y;
			return (deltaX * deltaX + deltaY * deltaY);
		}	
		
		public function magnitude( ) : Number
		{
			return Math.sqrt(_x * _x + _y * _y);
		}
		
		public function magnitudeSqr( ) : Number
		{
			return (_x * _x + _y * _y);
		}
		
		public function normalize( ) : void
		{
			var mag : Number = Math.sqrt(_x * _x + _y * _y);
			if (mag == 0)
			{
				_x = 0;
				_y = 0;
			}
			else
			{
				_x = _x / mag;
				_y = _y / mag;
			}
		}
		
		public function getNormalize( ) : Vector2D
		{
			var v:Vector2D = new Vector2D();
			var mag : Number = Math.sqrt(_x * _x + _y * _y);
			if (mag == 0)
			{
				v.x = 0;
				v.y = 0;
			}
			else
			{
				v.x = _x / mag;
				v.y = _y / mag;
			}
			return v;
		}
		
		
		public function dot(v2 : Vector2D): Number
		{
			return (_x * v2.x + _y * v2.y);
		}
		
		
		public function zero():void 
		{
			x = 0.0; 
			y = 0.0;
		}
		
		public function sign(v2:Vector2D):int
		{
			if (_y * v2.x > _x * v2.y)
				return -1;
			else
				return 1;
				
		}
		
		public function perp(): Vector2D
		{
			return new Vector2D(-_y, _x);
		}
		
		public function truncate(max:Number):void
		{
			if (magnitude() > max)
			{
				this.normalize();
				this.multiply(max);
			}
		}
		
		public function reverse():Vector2D
		{
			return new Vector2D( -_x, -_y);
		}
		
		
		// rotates this vector by deg degrees
		public function rotate( deg: Number): void
		{
			var rad:Number = deg * DEGRAD;
			var cos:Number = Math.cos(rad);
			var sin:Number = Math.sin(rad);
			_x = _x * cos -  _y * sin;
			_y = _y  * cos +  _x * sin;
		}
		
		// returns angle of this vector in degrees
		public function get angle( ) : Number
		{
			return Math.atan2(_y, _x) * 180 / Math.PI;
		}
		
		// returns a unit vector in direction angle supplied in degrees
		public static function degToVec(deg: Number): Vector2D
		{
			var rad:Number = deg * DEGRAD;
			return new Vector2D(Math.cos(rad), Math.sin(rad));
		}
		
		// returns a unit vector in direction angle supplied in radians
		public static function radToVec(rad: Number): Vector2D
		{
			return new Vector2D(Math.sin(rad), Math.cos(rad));
		}
		
		public function toString( ): String
		{
			return("x:" + int(_x*100)/100 + ",\ty:" + int(_y*100)/100);
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
		}
		
	}

}