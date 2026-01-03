# Viktor
is a haxe datastructure that maps positive integer keys to values stored in a normal `Vector`.  
It is optimised for quickly adding values, returning a free key and quickly deleting those immediately.  
The free keys are stored separately and are used as a priority when adding new keys/values.  
  
So only some _optimizationTHING(^_^)_ ~~^^

  
The data structure is available in two variants, each with two sub-variants,  
one of which is optimised for integer value types only.
```
    Viktor<T>          &        Viktoria<T>
	/       \                    /      \
ViktorT<T>  ViktorInt     ViktoriaT<T>  ViktoriaInt
```
  
`Viktor` and `Viktoria` are macros and wraps around like this:
```hx
Viktor<Int>    ->  ViktorInt
Viktor<UInt>   ->  ViktorInt
Viktor<Bool>   ->  ViktorT<Null<Bool>>
Viktor<Float>  ->  ViktorT<Null<Float>>
```
```hx
Viktoria<Int>   ->  ViktoriaInt
Viktoria<UInt>  ->  ViktoriaInt
```
All other parameter types become corresponding `ViktorT<T>` or `ViktoriaT<T>`.
  
While Viktor uses special values (`null` or `-1`) to mark deleted entries,  
Viktoria does not have these restrictions, but differs slightly in performance.


|               | Viktor | Viktoria |
|---------------|--------|----------|
| add(value)    | fast   | fast     |
| get(key)      | fast   | fast     |
| set(key)      | fast   | fast     |
| del(key)      | fast   | faster   |
| remove(value) | slow   | slower   |
| key(value)    | slow   | slower   |
| exist(key)    | fast   | slow     |
| Iteration     | slow   | slower   |


  
## Installation
```
haxelib git viktor https://github.com/maitag/viktor.git
```

## Synopsis

### Creating Viktor(ia)
```hx
var viktor = Viktor<String>(10);

// how many values it can contain at max
trace(viktor.size); // -> 10 (so the greatest possible key is `9`)
```

### fast add and del Operations
```hx
// add values
var keyA:Int = viktor.add("A"); // keyA is 0
var keyB:Int = viktor.add("B"); // keyB is 1
var keyC:Int = viktor.add("C"); // keyC is 2
var keyD:Int = viktor.add("D"); // keyD is 3

// how many values it actually contains
trace(viktor.length); // -> 4

// delete values by key
viktor.del(keyA);
viktor.del(keyB);
trace(viktor); // -> [2=>"C", 3=>"D"]

viktor.del(keyD);
trace(viktor); // -> [2=>"C"]

// add a new one
var keyE = viktor.add("E"); // keyE is 1 now!

trace(viktor); // -> [1=>"E", 2=>"C"]
trace(viktor.length); // -> 2
```


  
## Todo

- more into synapsis
- more unit tests and benchmarks
- using Bytes and target specific backends instead of the Vector

  
