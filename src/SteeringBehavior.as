package  
{
	import Interfaces.IRenderable;
	/**
	 * ...
	 * @author nguyen
	 */
	public class SteeringBehavior 
	{
		public static const SLOWING_RADIUS	:Number = 150;
		public static const CIRCLE_DISTANCE :Number = 5;
		public static const CIRCLE_RADIUS :Number = 16;
		public static const ANGLE_CHANGE :Number = 1;
		
		
		private var object:IRenderable;
		
		private var position:Vector2D;
		private var velocity:Vector2D;
		private var heading:Vector2D;
		private var side:Vector2D;
		
		private var _target:Vector2D;
		private var desired:Vector2D;
		private var steeringForce:Vector2D;
		
		
		private var mass:Number;
		private var max_velocity:Number;
		private var max_force:Number;
		private var max_turnrate:Number;
		
		public var wanderAngle	:Number;
		
		private var _rotation:Number;
		
		
		public function SteeringBehavior(o:IRenderable,maxforce:Number,maxvelocity:Number,mass:Number)
		{
			object = o;
			max_force = maxforce;
			max_velocity = maxvelocity;
			this.mass = mass;
			
			position = new Vector2D(object.worldX, object.worldY);
			velocity = new Vector2D(20,0);
			steeringForce = new Vector2D();
			
			wanderAngle = 0;
		}
		
		public function seek(target:Vector2D):Vector2D
		{
			var tempV:Vector2D = target.subtract(position);
			tempV.normalize();
			var dediredV:Vector2D = tempV.multiply(max_velocity);
			return dediredV.subtract(velocity);
		}
		
		public function arrive(target :Vector2D,decelararion:Number) :Vector2D
		{
			var force :Vector2D;
			var distance :Number, slowingRadius :Number = SLOWING_RADIUS;
			
			desired = target.subtract(position);
			
			distance = desired.magnitude();
			//desired.normalize();
			
			desired.normalize();
			
			if (distance < SLOWING_RADIUS)
			{
				var decelerationTweaker:Number =0.3;
				var speed:Number = distance / (decelararion*decelerationTweaker);
				//speed = speed > max_velocity? max_velocity:speed;
				//desired.normalize();
				desired = desired.multiply(speed);
				
			}
			else
			{
			
				desired = desired.multiply(max_velocity);
			}
			return desired.subtract(velocity);
			//return new Vector2D();
		}
		
		
		private function wander() :Vector2D {
			var wanderForce :Vector2D, circleCenter:Vector2D, displacement:Vector2D;
			
			circleCenter = velocity.clone();
			circleCenter.normalize();
			circleCenter = circleCenter.multiply(CIRCLE_DISTANCE);
			
			displacement = new Vector2D(0, -1);
			displacement = displacement.multiply(CIRCLE_RADIUS);
			
			setAngle(displacement, wanderAngle);
			wanderAngle += Math.random() * ANGLE_CHANGE - ANGLE_CHANGE * .5;
			
			wanderForce = circleCenter.add(displacement);
			
			return wanderForce;
		}
		
		public function setAngle(vector :Vector2D, value:Number):void {
			var len :Number = vector.magnitude();
			vector.x = Math.cos(value) * len;
			vector.y = Math.sin(value) * len;
		}
		
		public function getAngle(vector :Vector2D) :Number {
			return Math.atan2(vector.y, vector.x);
		}
		
		public function update(delta:Number):void 
		{
			position = new Vector2D(object.worldX, object.worldY);
			steeringForce.zero();
			
			//steeringForce = seek(_target);
			//steeringForce = arrive(_target,1);
			steeringForce = wander();
			
			var acceleration:Vector2D = steeringForce.divide(mass);
			velocity = velocity.add( acceleration);
			velocity.truncate(max_velocity);
			
			position = position.add(velocity.multiply(delta));
			
			//if (velocity.magnitudeSqr() > 0.00001)
			//{
				//heading = m
			//}
			
			object.worldX = position.x;
			object.worldY = position.y;
					
			rotation = Math.atan2( velocity.y, velocity.x );
		}
		
		public function get rotation():Number 
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			_rotation = value;
		}
		
		public function get target():Vector2D 
		{
			return _target;
		}
		
		public function set target(value:Vector2D):void 
		{
			_target = value;
		}
		
	}

}