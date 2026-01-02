class Test {
	
	static function main(){
		var r = new haxe.unit.TestRunner();
		
		r.add(new TestViktor());
		
		// run the tests
		r.run();
	}
}
