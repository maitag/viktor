package;

import haxe.ds.Vector;

/**
	This datastructure is to store positive integer values mapped by a integer key.
	The value `-1` indicates that the key not exists.
	Its optimized for fast add/delete operations by the key.
	Operations like remove(), indexOf() or iteration over key/values is slow instead.
**/
class ViktorInt {

	/**
		The value to determine that it not exists.
	**/
	public static inline var NULL:Int = -1;

	var list:Vector<Int>;
	var pos:Int = 0;
	var posFree:Int;

	/**
		Maximum number of values what can be stored inside.
	**/
	public var size(get, never):Int;
	inline function get_size():Int return list.length>>1;

	/**
		How many values are actually stored.
	**/
	public var length(get, never):Int;
	inline function get_length():Int return pos - (posFree-size + 1);

	/**
		Creates a new ViktorInt instance.
		@param size maximum size (greatest key will be size-1)
	**/
	public inline function new(size:Int) {
		posFree = size - 1;
		list = new Vector(size<<1);
	}

	/**
		Adds a value and returns the corresponding new key.
		@param value value of type `T`
	**/
	public inline function add(value:Int):Int {
		#if viktor_safe
		if (value == NULL) throw('Values in ViktorInt can not be "$NULL", use ViktoriaInt instead');	
		#end
		if (posFree < size) {
			#if viktor_safe
			if (pos == size) throw("No free key avail.");
			#end
			list.set(pos, value);
			return pos++;
		}
		else {
			var key = list.get(posFree--);
			list.set(key, value);
			return key;
		}
	}

	/**
		Get the value to a key or returns `-1` if not found.
		@param key existing key of type `Int`
	**/
	public inline function get(key:Int):Int {
		#if viktor_safe
		if (key < 0 || key >= size) throw("Key out of range.");
		#end
		return (key < pos) ? list.get(key) : -1;
	}

	/**
		Sets the value to a existing key.
		If the key does not exist, this leads to an unpredictable result. Use the `viktor_safe` compiler flag to catch this.
		@param key existing key of type `Int`
		@param value value of type `Int`
	**/
	public inline function set(key:Int, value:Int) {
		#if viktor_safe
		if (value == NULL) throw('values in ViktorInt can not be "$NULL", use ViktoriaInt instead');	
		if (!exist(key)) throw("The key must already exist to set a new value.");
		#end
		list.set(key, value);
	}

	/**
		Deletes the value by setting it to `-1` and releases the key for reuse.
		If the key does not exist, this leads to an unpredictable result. Use the `viktor_safe` compiler flag to catch this.
		@param key existing key of type `Int`
	**/
	public inline function del(key:Int) {
		#if viktor_safe
		if (!exist(key)) throw("The key must already exist to delete it.");
		#end
		_del(key);
	}

	public inline function _del(key:Int) {
		if (key == pos-1) pos--;
		else {
			list.set(key, NULL);
			list.set(++posFree, key);
		}
	}
	
	/**
		Deletes a value and returns its key or `-1` if it is not found.
		If the value exists multiple times, the one with the lowest key is deleted.
		@param value value of type `Int`
	**/
	public inline function remove(value:Int):Int {
		var i:Int = key(value);
		if (i >= 0) _del(i);
		return i;
	}

	/**
		Returns the key of the first value found, or `-1` instead.
		@param value value of type `Int`
	**/
	public inline function key(value:Int):Int {
		#if viktor_safe
		if (value == NULL) throw('Values in ViktorInt can not be "$NULL", use ViktoriaInt instead');	
		#end
		var i:Int = 0;		
		while ( i < pos && get(i) != value) i++;
		return (i<pos) ? i : -1;
	}

	/**
		Returns true if a key exists.
		@param key key of type `Int`
	**/
	public inline function exist(key:Int):Bool {
		#if viktor_safe
		if (key < 0 || key >= size) throw("Key out of range.");
		#end 
		return (key < pos && get(key) != NULL);
	}

	/**
		Adds a new key and value. This function is very slow and should only be used for debugging purposes.
		If the key already exists, the value for that key will be replaced.
		@param key key of type `Int`
		@param value value of type `Int`
	**/
	public inline function addKeyValue(key:Int, value:Int) {
		if (value == NULL) throw('values in ViktorInt can not be "$NULL", use ViktoriaInt instead');	
		if (!exist(key)) {
			if (key == pos) pos++;
			else if (key > pos) {
				do { // fill up new free keys until not reaching the new one
					list.set(pos, NULL);
					list.set(++posFree, pos);
					pos++;
				} while (pos < key);
				pos++;
			}
			else { // check inside freeKeys and remove it if found
				var i:Int = size;
				while (i <= posFree && list.get(i) != key) i++;
				if (i <= posFree) {
					if (i < posFree) list.set(i, list.get(posFree)); // replace it with the last free key
					posFree--;
				}
			}
		}
		list.set(key, value);
	}

	/**
		Returns all key/value pairs as string representation.
	**/
	public inline function toString():String {
		return "[" + [for (k=>v in this) '$k=>$v'].join(",") + "]";
	}


	// ------------------- ITERATORS ---------------------

	/**
		Returns a new ViktorIntIterator to use in `for (value in viktorInt)` loops.
	**/	
	public inline function iterator():ViktorIntIterator {
		return new ViktorIntIterator(this, 0, pos);
	}

	/**
		Returns a new ViktorIntKeyValueIterator to use in `for (value in viktorInt)` loops.
	**/	
	public inline function keyValueIterator():ViktorIntKeyValueIterator {
		return new ViktorIntKeyValueIterator(this, 0, pos);
	}

}


// ---------------------------------------------------
// ------------------- ITERATORS ---------------------
// ---------------------------------------------------

class ViktorIntIterator {

	var viktorInt:ViktorInt;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktorIntIterator` instance.
		@param viktorInt viktorInt reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktorInt:ViktorInt, from:Int, to:Int) {
		#if viktor_safe
		if (from < 0 || from > to || to > viktorInt.size) throw("Iterator out of bounds");
		#end
		this.viktorInt = viktorInt;
		i = from;
		this.to = to;
	}

	public inline function next():Int {
		var v:Int = viktorInt.get(i++);
		while ( v == ViktorInt.NULL) v = viktorInt.get(i++);
		return v;
	}

	@:access(ViktorInt)
	public inline function hasNext():Bool return (i < to && viktorInt.posFree < viktorInt.list.length);
}

class ViktorIntKeyValueIterator {

	var viktorInt:ViktorInt;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktorIntKeyValueIterator` instance.
		@param viktorInt viktorInt reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktorInt:ViktorInt, from:Int, to:Int) {
		#if viktor_safe
		if (from < 0 || from > to || to > viktorInt.size) throw("Iterator out of bounds");
		#end
		this.viktorInt = viktorInt;
		i = from;
		this.to = to;
	}

	public inline function next():{key:Int, value:Int} {
		var v:Int = viktorInt.get(i++);
		while ( v == ViktorInt.NULL) v = viktorInt.get(i++);
		return {key:i-1, value:v};
	}

	@:access(ViktorInt)
	public inline function hasNext():Bool return (i < to && viktorInt.posFree < viktorInt.list.length);
}
