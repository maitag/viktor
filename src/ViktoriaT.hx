package;

import haxe.ds.Vector;

/**
	This datastructure is to store values of type <T> mapped by a integer key.
	The value can be also `null` (instead of the values in ViktorT).
	Its optimized for fast add/delete operations by the key.
	Operations like remove(), indexOf() or iteration over key/values is much slower instead.
**/
class ViktoriaT<T> {

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
		Creates a new ViktoriaT instance.
		@param size maximum size (greatest key will be size-1)
	**/
	public inline function new(size:Int) {
		list = new Vector(size);
		freeKeys = new Vector(size);
	}

	/**
		Get the value to a key or returns `null` if not found.
		Take care, the value of Viktoria can also be `null`!
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
		if (key < 0 || key >= pos) return false;
		var i=0;
		while (i <= posFree && freeKeys.get(i) != key) i++;
		if (i <= posFree) return false;
		return true;
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
		Returns a new ViktoriaTIterator to use in `for (value in viktoria)` loops.
	**/
	public inline function iterator():ViktoriaTIterator<T> {
		return new ViktoriaTIterator<T>(this, 0, pos);
	}

	/**
		Returns a new ViktorKeyValueIterator to use in `for (value in viktoria)` loops.
	**/
	public inline function keyValueIterator():ViktoriaTKeyValueIterator<T> {
		return new ViktoriaTKeyValueIterator<T>(this, 0, pos);
	}

}


// ---------------------------------------------------
// ------------------- ITERATORS ---------------------
// ---------------------------------------------------

class ViktoriaTIterator<T> {

	var viktoria:ViktoriaT<T>;
	var i:Int;
	var to:Int;

	// todo: optimize iteration by sorting the freeList vector at the beginning
	// var posFreeStart:Int = 0;

	/**
		Creates a new `ViktorIterator<T>` instance.
		@param viktoria viktoria reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktoria:ViktoriaT<T>, from:Int, to:Int) {
		if (from < 0 || from >= to || to > viktoria.size) throw("Iterator out of bounds");
		this.viktoria = viktoria;
		i = from;
		this.to = to;
	}

	public inline function next():T return viktoria.get(i++);

	@:access(ViktoriaT)
	public inline function hasNext():Bool {
		if (viktoria.posFree >= viktoria.size) return false;
		while (i < to && !viktoria.exist(i)) i++;
		if (i < to) return true else return false;
	}
}

class ViktoriaTKeyValueIterator<T> {

	var viktoria:ViktoriaT<T>;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktoriaTKeyValueIterator<T>` instance.
		@param viktoria viktoria reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktoria:ViktoriaT<T>, from:Int, to:Int) {
		if (from < 0 || from >= to || to > viktoria.size) throw("Iterator out of bounds");
		this.viktoria = viktoria;
		i = from;
		this.to = to;
	}

	public inline function next():{key:Int, value:T} return {key:i, value:viktoria.get(i++)};

	@:access(ViktoriaT)
	public inline function hasNext():Bool {
		if (viktoria.posFree >= viktoria.size) return false;
		while (i < to && !viktoria.exist(i)) i++;
		if (i < to) return true else return false;
	}
}