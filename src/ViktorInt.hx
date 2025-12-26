package;

import haxe.ds.Vector;

/**
	This datastructure is to store positive integer values mapped by a integer key.
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
		Get the value to a key or returns `null` if not found.
		@param key integer key
	**/
	public inline function get(key:Int):Int {
		return list.get(key);
	}

	/**
		Sets the value to a key.
		@param key integer key
		@param key value
		@param checkValidKey true by default, disable this for an unsafe operation, e.g. to fast replace a value
	**/
	public inline function set(key:Int, value:Int, checkValidKey:Bool = true) {
		if (checkValidKey) {
			if (key < 0 || key > pos || pos == size) throw("OutOfRange");
			if (key == pos) pos++;
			else if (posFree >= size) { // check if it is inside freeKeys and remove it there
				var i:Int = size;
				while (i <= posFree && list.get(i) != key) i++;
				if (i <= posFree) {
					if (i < posFree) list.set( i, list.get(posFree) );
					posFree--;
				}
			}
		}
		list.set(key, value);
	}

	/**
		Adds a new value and returns a new available key.
		@param value value to add
		@throws Overflow if there is no more free space
		@returns key where the value is mapped to
	**/
	public inline function add(value:Int):Int {
		if (posFree < size) {
			if (pos == size) throw("Overflow");
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
		Returns true if a value to the key exists.
		@param key integer key
	**/
	public inline function exist(key:Int):Bool {
		return (get(key) != NULL);
	}

	/**
		Deletes the value by its key (frees the key for re-usage).
		@param key integer key
	**/
	public inline function del(key:Int) {
		// if (key < 0 || key >= pos) throw("OutOfRange");
		list.set(key, NULL);

		if (key == pos-1) {
			pos--;
		}
		else {
			// if (posFree >= list.length) throw("'del' freeKeys OVERFLOW");
			list.set(++posFree, key);
		}
	}
	
	/**
		Deletes a value if found and returns its key.
		If more then one of same values exists it returs the one with the higher key value.
		@param value value to delete
	**/
	public inline function remove(value:Int):Int {
		var i:Int = key(value);
		if (i >= 0) del(i);
		return i;
	}

	/**
		Returns the key of the first value what is found or `-1` instead.
		@param value value to get key for
	**/
	public inline function key(value:Int):Int {
		var i:Int = 0;		
		while ( i < pos && get(i) != value) i++;
		return (i<pos) ? i : -1;
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
		if (from < 0 || from >= to || to > viktorInt.size) throw("Iterator out of bounds");
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
		if (from < 0 || from >= to || to > viktorInt.size) throw("Iterator out of bounds");
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
