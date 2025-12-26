package;

import haxe.ds.Vector; // Viktors little friend .)

/**
	This datastructure is to store values mapped by a integer key.
	Its optimized for fast add/delete operations by the key.
	Operations like remove(), indexOf() or iteration over key/values is slow instead.
**/
class Viktor<T> {

	var list:Vector<T>;
	var pos:Int = 0;
	
	var freeKeys:Vector<Int>;
	var posFree:Int = -1;

	/**
		Maximum number of values what can be stored inside.
	**/
	public var size(get, never):Int;
	inline function get_size():Int return freeKeys.length;

	/**
		How many values are actually stored.
	**/
	public var length(get, never):Int;
	inline function get_length():Int return pos - (posFree + 1);

	/**
		Creates a new Viktor instance.
		@param size maximum size (greatest key will be size-1)
	**/
	public inline function new(size:Int) {
		list = new Vector(size);
		freeKeys = new Vector(size);
	}

	/**
		Get the value to a key or returns `null` if not found.
		@param key integer key
	**/
	public inline function get(key:Int):T {
		return list.get(key);
	}

	/**
		Sets the value to a key.
		@param key integer key
		@param key value
		@param checkValidKey true by default, disable this for an unsafe operation, e.g. to fast replace a value
	**/
	public inline function set(key:Int, value:T, checkValidKey:Bool = true) {
		if (checkValidKey) {
			if (key < 0 || key > pos || pos == size) throw("OutOfRange");
			if (key == pos) pos++;
			else if (posFree >= 0) { // check if it is inside freeKeys and remove it there
				var i:Int = 0;
				while (i <= posFree && freeKeys.get(i) != key) i++;
				if (i <= posFree) {
					if (i < posFree) freeKeys.set( i, freeKeys.get(posFree) );
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
	public inline function add(value:T):Int {
		if (posFree == -1) {
			if (pos == size) throw("Overflow");
			list.set(pos, value);
			return pos++;
		}
		else {
			var key = freeKeys.get(posFree--);
			list.set(key, value);
			return key;
		}
	}

	/**
		Returns true if a value to the key exists.
		@param key integer key
	**/
	public inline function exist(key:Int):Bool {
		return (get(key) != null);
	}

	/**
		Deletes the value by its key (frees the key for re-usage).
		@param key integer key
	**/
	public inline function del(key:Int) {
		// if (key < 0 || key >= pos) throw("OutOfRange");
		list.set(key, null);

		if (key == pos-1) {
			pos--;
		}
		else {
			// if (posFree >= freeKeys.length) throw("'del' freeKeys OVERFLOW");
			freeKeys.set(++posFree, key);
		}
	}
	
	/**
		Deletes a value if found and returns its key.
		If more then one of same values exists it returs the one with the higher key value.
		@param value value to delete
	**/
	public inline function remove(value:T):Int {
		var i:Int = key(value);
		if (i >= 0) del(i);
		return i;
	}

	/**
		Returns the key of the first value what is found or `-1` instead.
		@param value value to get key for
	**/
	public inline function key(value:T):Int {
		var i:Int = 0;		
		while ( i < pos && get(i) != value) i++;
		return (i<pos) ? i : -1;
	}


	// ------------------- ITERATORS ---------------------

	/**
		Returns a new ViktorIterator to use in `for (value in viktor)` loops.
	**/
	public inline function iterator():ViktorIterator<T> {
		return new ViktorIterator<T>(this, 0, pos);
	}

	/**
		Returns a new ViktorKeyValueIterator to use in `for (value in viktor)` loops.
	**/
	public inline function keyValueIterator():ViktorKeyValueIterator<T> {
		return new ViktorKeyValueIterator<T>(this, 0, pos);
	}

}


// ---------------------------------------------------
// ------------------- ITERATORS ---------------------
// ---------------------------------------------------

class ViktorIterator<T> {

	var viktor:Viktor<T>;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktorIterator<T>` instance.
		@param viktor viktor reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktor:Viktor<T>, from:Int, to:Int) {
		if (from < 0 || from >= to || to > viktor.size) throw("Iterator out of bounds");
		this.viktor = viktor;
		i = from;
		this.to = to;
	}

	public inline function next():T {
		var v:T = viktor.get(i++);
		while ( v == null) v = viktor.get(i++);
		return v;
	}

	@:access(Viktor)
	public inline function hasNext():Bool return (i < to && viktor.posFree < viktor.size);
}

class ViktorKeyValueIterator<T> {

	var viktor:Viktor<T>;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktorKeyValueIterator<T>` instance.
		@param viktor viktor reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktor:Viktor<T>, from:Int, to:Int) {
		if (from < 0 || from >= to || to > viktor.size) throw("Iterator out of bounds");
		this.viktor = viktor;
		i = from;
		this.to = to;
	}

	public inline function next():{key:Int, value:T} {
		var v:T = viktor.get(i++);
		while ( v == null) v = viktor.get(i++);
		return {key:i-1, value:v};
	}

	@:access(Viktor)
	public inline function hasNext():Bool return (i < to && viktor.posFree < viktor.size);
}