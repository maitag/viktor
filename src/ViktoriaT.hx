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
		Adds a value and returns the corresponding new key.
		@param value value of type `T`
	**/
	public inline function add(value:T):Int {
		if (posFree == -1) {
			#if !viktor_unsafe
			if (pos == size) throw("No free key avail.");
			#end 
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
		Returns the value to a key. If the key does not exist it will lead to an unpredictable result.
		Use `exist(key)` to check this before!
		@param key existing key of type `Int`
	**/
	public inline function get(key:Int):T {
		#if !viktor_unsafe
		if (key < 0 || key >= size) throw("Key out of range.");
		#end
		return list.get(key);
	}

	/**
		Sets the value to a existing key.
		If the compiler flag `viktor_unsafe` is set and the key does not exist, this leads to an unpredictable result; otherwise, an error is thrown.
		@param key existing key of type `Int`
		@param value value of type `T`
	**/
	public inline function set(key:Int, value:T) {
		#if !viktor_unsafe
		if (!exist(key)) throw("The key must already exist to set a new value.");
		#end
		list.set(key, value);
	}

	/**
		Deletes the value and releases the key for reuse.
		If the compiler flag `viktor_unsafe` is set and the key does not exist, this leads to an unpredictable result; otherwise, an error is thrown.
		@param key existing key of type `Int`
	**/
	public inline function del(key:Int) {
		#if viktor_unsafe
		if (!exist(key)) throw("The key must already exist to delete it.");
		#end
		if (key == pos-1) pos--;
		else freeKeys.set(++posFree, key);
	}
	
	/**
		Deletes a value and returns its key or `-1` if it is not found.
		If the value exists multiple times, the one with the lowest key is deleted.
		@param value value of type `T`
	**/
	public inline function remove(value:T):Int {
		var i:Int = key(value);
		if (i >= 0) del(i);
		return i;
	}

	/**
		Returns the key of the first value what is found or `-1` instead.
		@param value value of type `T`
	**/
	public inline function key(value:T):Int {
		var i:Int = 0;		
		while ( i < pos && !( get(i) == value && exist(i) ) ) i++;
		return (i<pos) ? i : -1;
	}

	/**
		Returns true if a key exists.
		@param key key of type `Int`
	**/
	public inline function exist(key:Int):Bool {
		#if !viktor_unsafe
		if (key < 0 || key >= size) throw("Key out of range.");
		#end 
		if (key >= pos) return false;
		var i=0;
		while (i <= posFree && freeKeys.get(i) != key) i++;
		if (i <= posFree) return false;
		return true;
	}

	/**
		Adds a new key and value. This function is very slow and should only be used for debugging purposes.
		If the key already exists, the value for that key will be replaced.
		@param key key of type `Int`
		@param value value of type `T`
	**/
	public inline function addKeyValue(key:Int, value:T) {
		if (!exist(key)) {
			if (key == pos) pos++;
			else if (key > pos) {
				do { // fill up new free keys until not reaching the new one
					freeKeys.set(++posFree, pos);
					pos++;
				} while (pos < key);
				pos++;
			}
			else { // check inside freeKeys and remove it if found
				var i:Int = 0;
				while (i <= posFree && freeKeys.get(i) != key) i++;
				if (i <= posFree) {
					if (i < posFree) freeKeys.set(i, freeKeys.get(posFree)); // replace it with the last free key
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