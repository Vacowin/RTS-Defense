package  
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import Interfaces.IRenderable;
	/**
	 * ...
	 * @author nguyen
	 */
	public class Steering 
	{
		public static const SLOWING_RADIUS	:Number = 200;
		public static const CIRCLE_DISTANCE :Number = 6;
		public static const CIRCLE_RADIUS :Number = 8;
		public static const ANGLE_CHANGE :Number = 1;
		
		private var max_force:Number;
		private var max_velocity:Number;
		
		private var position:Vector3D;
		private var _velocity:Vector3D;
		private var _target:Vector3D;
		private var desired:Vector3D;
		private var steering:Vector3D;
		private var mass:Number;
		private var _rotation:Number;
		public var wanderAngle	:Number;
		
		private var object:IRenderable;
		
		public function Steering(o:IRenderable,maxforce:Number,maxvelocity:Number,mass:Number) 
		{
			object = o;
			max_force = maxforce;
			max_velocity = maxvelocity;
			this.mass = mass;
			
			position = new Vector3D(object.worldX, object.worldY);
			velocity = new Vector3D(0, 0);
			target	 = new Vector3D(0, 0);
			desired	 = new Vector3D(0, 0); 
			steering = new Vector3D(0, 0);
			
			wanderAngle = 0; 
		}
		
		private function truncate(vector :Vector3D, max :Number) :void {
			var i :Number;

			i = max / vector.length;
			i = i < 1.0 ? 1.0 : i;
			
			vector.scaleBy(i);
		}
		
		private function seek1(target :Vector3D) :Vector3D {
			var force :Vector3D;
			
			desired = target.subtract(position);
			desired.normalize();
			desired.scaleBy(max_velocity);
			
			force = desired.subtract(velocity);
			
			return force;
			//return new Vector3D(-force.x, -force.y);;
		}
		
		public function seek(target :Vector3D) :Vector3D
		{
			var force :Vector3D;
			var distance :Number, slowingRadius :Number = SLOWING_RADIUS;
			
			desired = target.subtract(position);
			
			distance = desired.length;
			desired.normalize();
			
			if (distance <= slowingRadius) {
				desired.scaleBy(max_velocity * distance / slowingRadius);
			} else {
				desired.scaleBy(max_velocity);
			}
			
			force = desired.subtract(velocity);
			
			return force;
		}
		
		private function wander() :Vector3D {
			var wanderForce :Vector3D, circleCenter:Vector3D, displacement:Vector3D;
			
			circleCenter = velocity.clone();
			circleCenter.normalize();
			circleCenter.scaleBy(CIRCLE_DISTANCE);
			
			displacement = new Vector3D(0, -1);
			displacement.scaleBy(CIRCLE_RADIUS);
			
			setAngle(displacement, wanderAngle);
			wanderAngle += Math.random() * ANGLE_CHANGE - ANGLE_CHANGE * .5;
			
			wanderForce = circleCenter.add(displacement);
			
			return wanderForce;
		}
		
		public function setAngle(vector :Vector3D, value:Number):void {
			var len :Number = vector.length;
			vector.x = Math.cos(value) * len;
			vector.y = Math.sin(value) * len;
		}
		
		public function getAngle(vector :Vector3D) :Number {
			return Math.atan2(vector.y, vector.x);
		}
		
		public function update(delta:Number):void {
			position = new Vector3D(object.worldX, object.worldY);
			//steering = seek(target);
			steering = wander();
			
			truncate(steering, max_force);
			steering.scaleBy(1 / mass);
			steering.scaleBy(delta);
			velocity = velocity.add(steering);
			//velocity = new Vector3D(velocity.x * delta, velocity.y * delta);
			truncate(velocity, max_velocity);
			
			var p:Point = new Point(object.worldX, object.worldY);
			
			position = position.add(velocity);

			object.worldX = position.x;
			object.worldY = position.y;
					
			rotation = Math.atan2( velocity.y, velocity.x );
		}
		
		public function get target():Vector3D 
		{
			return _target;
		}
		
		public function set target(value:Vector3D):void 
		{
			_target = value;
		}
		
		public function get velocity():Vector3D 
		{
			return _velocity;
		}
		
		public function set velocity(value:Vector3D):void 
		{
			_velocity = value;
		}
		
		public function get rotation():Number 
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			_rotation = value;
		}
	}

}