@:access(ViktoriaInt)
class TestViktoriaInt extends haxe.unit.TestCase
{
	public function testViktoriaInt() {

		var v = new ViktoriaInt(5);

		assertEquals( v.add(111), 0 );
		assertEquals( v.add(222), 1 );
		assertEquals( v.add(333), 2 );
		assertEquals( v.add(444), 3 );
		assertEquals( v.add(555), 4 );

		assertEquals( v.toString(), "[0=>111,1=>222,2=>333,3=>444,4=>555]" );
		assertEquals( v.length, 5 );
		assertEquals( v.pos, 5 );
		assertEquals( v.posFree, v.size - 1 );

		#if viktor_safe
		// error: full
		assertTrue( try { v.add(42); false; } catch (e:Dynamic) true );
		#end

		v.del(4);
		assertEquals( v.toString(), "[0=>111,1=>222,2=>333,3=>444]" );
		assertEquals( v.length, 4 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, v.size - 1 );

		#if viktor_safe
		// error: key not exist
		assertTrue( try { v.del(4); false; } catch (e:Dynamic) true );
		#end

		v.del(2);
		assertEquals( v.toString(), "[0=>111,1=>222,3=>444]" );
		assertEquals( v.length, 3 );
		assertEquals( v.posFree, v.size + 0 );
		assertEquals( v.pos, 4 );

		#if viktor_safe
		// error: key not exist
		assertTrue( try { v.set(-1,42); false; } catch (e:Dynamic) true );
		assertTrue( try { v.set(2,42); false; } catch (e:Dynamic) true );
		assertTrue( try { v.set(4,42); false; } catch (e:Dynamic) true );
		assertTrue( try { v.set(5,42); false; } catch (e:Dynamic) true );
		#end

		assertEquals( v.key(111), 0 );
		assertEquals( v.key(222), 1 );
		assertEquals( v.key(333), -1 );
		assertEquals( v.key(444), 3 );
		assertEquals( v.key(555), -1 );

		assertEquals( v.get(0), 111 );
		assertEquals( v.get(1), 222 );
		assertEquals( v.get(2), 333 );
		assertEquals( v.get(3), 444 );
		assertEquals( v.get(4), 555 );


		assertEquals( v.add(555), 2 );
		assertEquals( v.toString(), "[0=>111,1=>222,2=>555,3=>444]" );
		assertEquals( v.length, 4 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, v.size - 1 );

		assertEquals( v.add(333), 4 );
		assertEquals( v.toString(), "[0=>111,1=>222,2=>555,3=>444,4=>333]" );
		assertEquals( v.length, 5 );
		assertEquals( v.pos, 5 );
		assertEquals( v.posFree, v.size - 1 );

		assertEquals( v.get(0), 111 );
		assertEquals( v.get(1), 222 );
		assertEquals( v.get(2), 555 );
		assertEquals( v.get(3), 444 );
		assertEquals( v.get(4), 333 );

		#if viktor_safe
		// error: key out of range
		assertTrue( try { v.get(-1); false; } catch (e:Dynamic) true );
		assertTrue( try { v.get(5); false; } catch (e:Dynamic) true );
		#end

		v.set(2,333);
		v.set(4,555);
		assertEquals( v.toString(), "[0=>111,1=>222,2=>333,3=>444,4=>555]" );


		assertEquals( v.remove(555), 4);
		assertEquals( v.remove(555), -1);
		assertEquals( v.length, 4 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, v.size - 1 );
		assertEquals( v.remove(111), 0);
		assertEquals( v.remove(111), -1);
		assertEquals( v.length, 3 );
		assertEquals( v.pos, 4 );
		assertEquals( v.posFree, v.size + 0 );
		assertEquals( v.toString(), "[1=>222,2=>333,3=>444]" );


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
		assertEquals( v.posFree, v.size + 2 );

		v.del(3);
		assertEquals( v.length, 0 );
		assertEquals( v.pos, 3 );
		assertEquals( v.posFree, v.size + 2 );

		assertEquals( v.add(-1), 2 ); // -1 as value should work now
		assertEquals( v.add(222), 1 );
		assertEquals( v.add(333), 0 );
		assertEquals( v.length, 3 );
		assertEquals( v.pos, 3 );
		assertEquals( v.posFree, v.size -1 );
		assertEquals( v.toString(), "[0=>333,1=>222,2=>-1]" );

		v.del(2);v.del(1);v.del(0);
		assertEquals( v.length, 0 );
		assertEquals( v.pos, 0 );
		assertEquals( v.posFree, v.size - 1 );
		assertEquals( v.toString(), "[]" );
	}


   
}
