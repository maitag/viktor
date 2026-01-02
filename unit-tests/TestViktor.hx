// @:access(ViktorT)
class TestViktor extends haxe.unit.TestCase
{
	public function testViktorT() {

		var v = new ViktorT<String> (5);

		assertEquals( v.add("a"), 0 );
		assertEquals( v.add("b"), 1 );
		assertEquals( v.add("c"), 2 );
		assertEquals( v.add("d"), 3 );
		assertEquals( v.add("e"), 4 );

		#if !viktor_unsafe
		//safe mode
		#end

		// errors
		assertTrue( try { assertEquals( v.add("f"), 0 ); false; } catch (e:Dynamic) true );



		// TODO !!!!!
	}


   
}
