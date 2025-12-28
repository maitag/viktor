package;

import haxe.ds.Vector;

/**
	This datastructure is to store integer values mapped by a integer key.
	Its optimized for fast add/delete operations by the key.
	Operations like remove(), indexOf() or iteration over key/values is slow instead.
**/
class ViktoriaInt {

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
		Creates a new ViktoriaInt instance.
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
		If the key does not exist and `checkValidKey` is false (default) it will lead to an unpredictable result.
		If `checkValidKey` is enabled it automatically adds a new key into this case.
		@param key integer key
		@param value integer value
		@param checkValidKey false by default, enable this for an slower but safe operation if the case occurs where the key does not exist
	**/
	public inline function set(key:Int, value:Int, checkValidKey:Bool = false) {
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
			if (pos == size) throw("Overflow"); // TODO: by compiler define!
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
		if (key < 0 || key >= pos) return false;
		var i=size;
		while (i <= posFree && list.get(i) != key) i++;
		if (i <= posFree) return false;
		return true;
	}

	/**
		Deletes the value by its key (frees the key for re-usage).
		By default it not check key existence and can be unsafe,
		so set the `checkValidKey` to true for debugging!
		@param key integer key
		@param checkValidKey false by default, enable this for an safe operation
	**/
	public inline function del(key:Int, checkValidKey:Bool = false) {
		if (checkValidKey && !exist(key)) throw("key not exists");
		if (key == pos-1) {
			pos--;
		}
		else {
			// if (posFree >= list.length) throw("'del' freeKeys OVERFLOW");
			list.set(++posFree, key);
		}
	}
	
	/**
		Deletes a value if found and returns its key or `-1` if not found.
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
		Returns a new ViktoriaIntIterator to use in `for (value in viktoriaInt)` loops.
	**/	
	public inline function iterator():ViktoriaIntIterator {
		return new ViktoriaIntIterator(this, 0, pos);
	}

	/**
		Returns a new ViktoriaIntKeyValueIterator to use in `for (value in viktoriaInt)` loops.
	**/	
	public inline function keyValueIterator():ViktoriaIntKeyValueIterator {
		return new ViktoriaIntKeyValueIterator(this, 0, pos);
	}

}


// ---------------------------------------------------
// ------------------- ITERATORS ---------------------
// ---------------------------------------------------

class ViktoriaIntIterator {

	var viktoriaInt:ViktoriaInt;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktoriaIntIterator` instance.
		@param viktoriaInt viktoriaInt reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktoriaInt:ViktoriaInt, from:Int, to:Int) {
		if (from < 0 || from >= to || to > viktoriaInt.size) throw("Iterator out of bounds");
		this.viktoriaInt = viktoriaInt;
		i = from;
		this.to = to;
	}

	public inline function next():Int return viktoriaInt.get(i++);

	@:access(ViktoriaInt)
	public inline function hasNext():Bool {
		if (viktoriaInt.posFree >= viktoriaInt.list.length) return false;
		while (i < to && !viktoriaInt.exist(i)) i++;
		if (i < to) return true else return false;
	}
}

class ViktoriaIntKeyValueIterator {

	var viktoriaInt:ViktoriaInt;
	var i:Int;
	var to:Int;

	/**
		Creates a new `ViktoriaIntKeyValueIterator` instance.
		@param viktoriaInt viktoriaInt reference
		@param from iteration start value
		@param to iteration end value
	**/
	public inline function new(viktoriaInt:ViktoriaInt, from:Int, to:Int) {
		if (from < 0 || from >= to || to > viktoriaInt.size) throw("Iterator out of bounds");
		this.viktoriaInt = viktoriaInt;
		i = from;
		this.to = to;
	}

	public inline function next():{key:Int, value:Int} return {key:i, value:viktoriaInt.get(i++)};

	@:access(ViktoriaInt)
	public inline function hasNext():Bool {
		if (viktoriaInt.posFree >= viktoriaInt.list.length) return false;
		while (i < to && !viktoriaInt.exist(i)) i++;
		if (i < to) return true else return false;
	}
}
