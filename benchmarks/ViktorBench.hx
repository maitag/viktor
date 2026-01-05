import haxe.Timer;

/*
a place to `add` your data references fast inside and get an `index` back
-> to remove it same at fast also later from your `Viktor` \o/
(nothing into your `memory allocation` needs to be `reorganized`.)

some _optimizationTHING(^_^)_ ~~^^

*/

class ViktorBench {

    public static function main() 
	{
		var size = 16384;
		var v = new ViktorT<String>(size);
		
		var time:Float = 0;
		var add_time:Float = 0;
		var del_time:Float = 0;

		var add:Int = 0;
		var del:Int = 0;
		
		for (j in 0...128) {
			
			// fill it fully:
			for (i in 0...size) {
				time = Timer.stamp(); v.add("a"); add_time += Timer.stamp() - time; add++;
			}

			// delete every second key:
			var k:Int = 0;
			while (k < size) {
				time = Timer.stamp(); v.del(k); del_time += Timer.stamp() - time; del++;
				k +=2;
			}

			// fill again:
			for (i in 0...size>>1) {
				time = Timer.stamp(); v.add("b"); add_time += Timer.stamp() - time; add++;
			}

			// delete every second key:
			var k:Int = 1;
			while (k < size) {
				time = Timer.stamp(); v.del(k); del_time += Timer.stamp() - time; del++;
				k +=2;
			}

			// fill again:
			for (i in 0...size>>1) {
				time = Timer.stamp(); v.add("c"); add_time += Timer.stamp() - time; add++;
			}

			// delete all keys:
			for (i in 0...size) {
				time = Timer.stamp(); v.del(i); del_time += Timer.stamp() - time; del++;
			}
			
		}
		
		add_time = Std.int(add_time*1000);
		del_time = Std.int(del_time*1000);

		// output separate times for each operation:
		haxe.Log.trace('$add add:\t${add_time}\tms' , null);
		haxe.Log.trace('$del del:\t${del_time}\tms' , null);
	}
	
}
