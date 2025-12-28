package;

import haxe.ds.Vector; // Viktors little friend .)

/**
	This datastructure is to store values of type <T> mapped by a integer key.
	The value `null` indicates that the key not exists.
	Its optimized for fast add/delete operations by the key.
	Operations like remove(), indexOf() or iteration over key/values is slow instead.
**/
class ViktorT<T> {

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
		Creates a new ViktorT instance.
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
		If the key does not exist and `checkValidKey` is false (default) it will lead to an unpredictable result.
		If `checkValidKey` is enabled it automatically adds a new key into this case.
		@param key integer key
		@param value value of type T
		@param checkValidKey false by default, enable this for an slower but safe operation if the case occurs where the key does not exist
	**/
	public inline function set(key:Int, value:T, checkValidKey:Bool = false) {
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
		if (value == null) throw("values in ViktorT can not be 'null', use ViktoriaT instead"); // TODO: by compiler define!
		if (posFree == -1) {
			if (pos == size) throw("Overflow"); // TODO: by compiler define!
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
		return (key >= 0 && key < pos && get(key) != null);
	}

	/**
		Deletes the value by its key (frees the key for re-usage).
		By default it does not check that the key exists and can be unsafe,
		so set the `checkValidKey` to true to throw and error into this case!
		@param key integer key
		@param checkValidKey false by default, enable this for an safe operation
	**/
	public inline function del(key:Int, checkValidKey:Bool = false) {
		if (checkValidKey && !exist(key)) throw("key not exists");

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
		Deletes a value if found and returns its key or `-1` if not found.
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
		Returns a new ViktorTIterator to use in `for (value in viktor)` loops.
	**/
	public inline function iterator():ViktorTIterator<T> {
		return new ViktorTIterator<T>(this, 0, pos);
	}

	/**
		Returns a new ViktorTKeyValueIterator to use in `for (value in viktor)` loops.
	**/
	public inline function keyValueIterator():ViktorTKeyValueIterator<T> {
		return new ViktorTKeyValueIterator<T>(this, 0, pos);
	}

}


// ---------------------------------------------------
// ------------------- ITERATORS ---------------------
// ---------------------------------------------------

class ViktorTIterator<T> {

	var viktor:ViktorT<T>;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktorTIterator<T>` instance.
		@param viktor viktor reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktor:ViktorT<T>, from:Int, to:Int) {
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

	@:access(ViktorT)
	public inline function hasNext():Bool return (i < to && viktor.posFree < viktor.size);
}

class ViktorTKeyValueIterator<T> {

	var viktor:ViktorT<T>;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktorTKeyValueIterator<T>` instance.
		@param viktor viktor reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktor:ViktorT<T>, from:Int, to:Int) {
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

	@:access(ViktorT)
	public inline function hasNext():Bool return (i < to && viktor.posFree < viktor.size);
}