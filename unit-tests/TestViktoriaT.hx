@:access(ViktoriaT)
class TestViktoriaT extends haxe.unit.TestCase
{
	public function testViktoriaT() {

		var v = new ViktoriaT<String> (5);

		assertEquals( v.add("a"), 0 );
		assertEquals( v.add("b"), 1 );
		assertEquals( v.add("c"), 2 );
		assertEquals( v.add("d"), 3 );
		assertEquals( v.add("e"), 4 );

		assertEquals( v.toString(), "[0=>a,1=>b,2=>c,3=>d,4=>e]" );
		assertEquals( v.length, 5 );
		assertEquals( v.pos, 5 );
		assertEquals( v.posFree, -1 );

		#if viktor_safe
		// error: full
		assertTrue( try { v.add("f"); false; } catch (e:Dynamic) true );
		#end

		v.del(4);
		assertEquals( v.toString(), "[0=>a,1=>b,2=>c,3=>d]" );
		assertEquals( v.length, 4 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, -1 );

		#if viktor_safe
		// error: key not exist
		assertTrue( try { v.del(4); false; } catch (e:Dynamic) true );
		#end

		v.del(2);
		assertEquals( v.toString(), "[0=>a,1=>b,3=>d]" );
		assertEquals( v.length, 3 );
		assertEquals( v.posFree, 0 );
		assertEquals( v.pos, 4 );

		#if viktor_safe
		// error: key not exist
		assertTrue( try { v.set(-1,"x"); false; } catch (e:Dynamic) true );
		assertTrue( try { v.set(2,"x"); false; } catch (e:Dynamic) true );
		assertTrue( try { v.set(4,"x"); false; } catch (e:Dynamic) true );
		assertTrue( try { v.set(5,"x"); false; } catch (e:Dynamic) true );
		#end

		assertEquals( v.key("a"), 0 );
		assertEquals( v.key("b"), 1 );
		assertEquals( v.key("c"), -1 );
		assertEquals( v.key("d"), 3 );
		assertEquals( v.key("e"), -1 );

		assertEquals( v.get(0), "a" );
		assertEquals( v.get(1), "b" );
		assertEquals( v.get(2), "c" );// still is c
		assertEquals( v.get(3), "d" );
		assertEquals( v.get(4), "e" );// still is e


		assertEquals( v.add("e"), 2 );
		assertEquals( v.toString(), "[0=>a,1=>b,2=>e,3=>d]" );
		assertEquals( v.length, 4 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, -1 );

		assertEquals( v.add("c"), 4 );
		assertEquals( v.toString(), "[0=>a,1=>b,2=>e,3=>d,4=>c]" );
		assertEquals( v.length, 5 );
		assertEquals( v.pos, 5 );
		assertEquals( v.posFree, -1 );

		assertEquals( v.get(0), "a" );
		assertEquals( v.get(1), "b" );
		assertEquals( v.get(2), "e" );
		assertEquals( v.get(3), "d" );
		assertEquals( v.get(4), "c" );

		#if viktor_safe
		// error: key out of range
		assertTrue( try { v.get(-1); false; } catch (e:Dynamic) true );
		assertTrue( try { v.get(5); false; } catch (e:Dynamic) true );
		#end

		v.set(2,"c");
		v.set(4,"e");
		assertEquals( v.toString(), "[0=>a,1=>b,2=>c,3=>d,4=>e]" );


		assertEquals( v.remove("e"), 4);
		assertEquals( v.remove("e"), -1);
		assertEquals( v.length, 4 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, -1 );
		assertEquals( v.remove("a"), 0);
		assertEquals( v.remove("a"), -1);
		assertEquals( v.length, 3 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, 0 );
		assertEquals( v.toString(), "[1=>b,2=>c,3=>d]" );


		assertEquals( v.exist(0), false );
		assertEquals( v.exist(1), true );
		assertEquals( v.exist(2), true );
		assertEquals( v.exist(3), true );
		assertEquals( v.exist(4), false );


		#if viktor_safe
		// error: key out of range
		assertTrue( try { v.exist(-1); false; } catch (e:Dynamic) true );
		assertTrue( try { v.exist(5); false; } catch (e:Dynamic) true );
		#end

		v.del(1);
		v.del(2);
		assertEquals( v.length, 1 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, 2 );

		v.del(3);
		assertEquals( v.length, 0 );
		assertEquals( v.pos, 3 );
		assertEquals( v.posFree, 2 );

		assertEquals( v.add(null), 2 );  // null as value should work now
		assertEquals( v.add("b"), 1 );
		assertEquals( v.add("c"), 0 );
		assertEquals( v.length, 3 );
		assertEquals( v.pos, 3 );
		assertEquals( v.posFree, -1 );
		assertEquals( v.toString(), "[0=>c,1=>b,2=>null]" );

		v.del(2);v.del(1);v.del(0);
		assertEquals( v.length, 0 );
		assertEquals( v.pos, 0 );
		assertEquals( v.posFree, -1 );
		assertEquals( v.toString(), "[]" );
	}


   
}
