class Vector {
	/**
	 * @param {number?} x
	 * @param {number?} y
	 * @param {number?} z
	 */
	constructor(x, y, z) {
		this.x = x || 0;
		this.y = y || 0;
		this.z = z || 0;
		this.isVector = true;
	};
	/**
	 * @param {Array<number>} array
	 * @returns {Vector}
	 */
	static fromArray(array) {
		switch (array != null ? array.length : 0) {
			case 2:
				return new Vector(array[0], array[1], 0);
			case 3:
				return new Vector(array[0], array[1], array[2]);
			default:
				return new Vector(0, 0, 0);
		};
	};
	/**
	 * @param {number} angle
	 * @returns {Vector}
	 */
	static Angle2Vector(angle) {
		return new Vector(Math.cos(angle), Math.sin(angle), 0);
	};
	/**
	 * @returns {Vector}
	 */
	static RandomVector() {
		return new Vector(Math.randomInt(0, 1000), Math.randomInt(0, 1000), Math.randomInt(0, 1000));
	};
	/**
	 * @returns {string}
	 */
	toString() {
		return "Vector(" + this.x + ", " + this.y + ", " + this.z + ")";
	};
	/**
	 * @returns {Array<number>}
	 */
	toArray() {
		return [this.x, this.y, this.z];
	};
	/**
	 * @param {Vector} vec2
	 * @returns {boolean}
	 */
	equals(vec2) {
		return this.x == vec2.x && this.y == vec2.y && this.z == vec2.z;
	};
	/**
	 * @returns {number}
	 */
	length() {
		return Math.sqrt(Math.pow(this.x, 2) + Math.pow(this.y, 2) + Math.pow(this.z, 2));
	};
	/**
	 * @param {Vector} v2
	 * @returns {number}
	 */
	distanceTo(v2) {
		return Math.abs(Math.sqrt((v2.x - this.x) * (v2.x - this.x) + (v2.y - this.y) * (v2.y - this.y) + (v2.z - this.z) * (v2.z - this.z)));
	};
	/**
	 * @param {Vector} v2
	 * @returns {Vector}
	 */
	minus(v2) {
		return new Vector(this.x - v2.x, this.y - v2.y, this.z - v2.z);
	};
	/**
	 * @param {Vector} v2
	 * @returns {Vector}
	 */
	add(v2) {
		return new Vector(this.x + v2.x, this.y + v2.y, this.z + v2.z);
	};
	/**
	 * @param {number} s
	 * @returns {Vector}
	 */
	scale(s) {
		return new Vector(this.x * s, this.y * s, this.z * s);
	};
	/**
	 * @param {number} s
	 * @returns {Vector}
	 */
	divide(s) {
		return new Vector(this.x / s, this.y / s, this.z / s);
	};
	/**
	 * @param {number} s
	 * @returns {Vector}
	 */
	scaleTo(s) {
		if (this.length() == 0) {
			return new Vector(0, 0, 0);
		} else {
			return this.scale(s / this.length());
		};
	};
	/**
	 * @returns {Vector}
	 */
	normalize() {
		return new Vector(this.x / this.length(), this.y / this.length(), this.z / this.length());
	};
	/**
	 * @param {Vector} v2
	 * @returns {number}
	 */
	dot(v2) {
		return this.x * v2.x + this.y * v2.y + this.z * v2.z;
	};
	/**
	 * @param {Vector} v1
	 * @param {Vector} v2
	 * @param {number?} tolerance
	 * @returns {boolean}
	 */
	isIn(v1, v2, tolerance) {
		tolerance = tolerance || 50;
		if (this.x >= Math.max(v1.x, v2.x) + tolerance || this.x <= Math.min(v1.x, v2.x) - tolerance || this.y <= Math.min(v1.y, v2.y) - tolerance || this.y >= Math.max(v1.y, v2.y) + tolerance) {
			return false;
		} else if (v1.x == v2.x) {
			return Math.abs(v1.x - this.x) < tolerance;
		} else if (v1.y == v2.y) {
			return Math.abs(v1.y - this.y) < tolerance;
		};
		return Math.abs(((v2.x - v1.x) * (v1.y - this.y)) - ((v1.x - this.x) * (v2.y - v1.y))) / Math.sqrt((v2.x - v1.x) * (v2.x - v1.x) + (v2.y - v1.y) * (v2.y - v1.y)) < tolerance;
	};
	/**
	 * @param {Vector} v2
	 * @returns {Vector}
	 */
	cross(v2) {
		return new Vector(this.y * v2.z - this.z * v2.y, this.z * v2.x - this.x * v2.z, this.x * v2.y - this.y * v2.x);
	};
	/**
	 * @param {Vector} rotation
	 * @param {number} units
	 * @returns {Vector}
	 */
	VectorRotation(rotation, units) {
		return new Vector(this.x + rotation.x * units, this.y + rotation.y * units, this.z + rotation.z * units);
	};
	/**
	 * @param {Vector} vec2
	 * @returns {number}
	 */
	AngleBetweenTwoVectors(vec2) {
		return Math.atan2(this.y - vec2.y, this.x - vec2.x);
	};
	/**
	 * @returns {Vector}
	 */
	copy() {
		return new Vector(this.x, this.y, this.z);
	};
};
Array.prototype.isVector = false;
/**
 * @returns {Vector}
 */
Array.prototype.toVector = function() {
	return Vector.fromArray(this);
};