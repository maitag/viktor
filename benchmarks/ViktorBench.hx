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
		var v = new ViktorT<String>(1024);
		
		var time = Timer.stamp();
		
		// TODO !!!!!
		// test deparate add, get, del and exist
		
		time = Std.int((Timer.stamp() - time)*1000);
		#if viktor_safe
		haxe.Log.trace("safe mode");
		#end

		// output separate times for each operation:
		// haxe.Log.trace('add:\t${time}\tms' , #if (haxe_ver >= "4.0.0") null #else {fileName:"",lineNumber:0,className:"",methodName:"",customParams:[]} #end);
	}
	
}
