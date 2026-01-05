class Test {
	
	static function main(){
		var r = new haxe.unit.TestRunner();
		
		r.add(new TestViktorT());
		r.add(new TestViktorInt());

		r.add(new TestViktoriaT());
		r.add(new TestViktoriaInt());
		
		// run the tests
		r.run();
	}
}
