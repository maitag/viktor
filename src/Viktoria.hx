package;

#if !macro
/**
	Switches between ViktoriaInt and ViktoriaT<T>:
		Viktoria<Int>  -> ViktoriaInt
		Viktoria<UInt> -> ViktoriaInt
	all others will become ViktoriaT<T>!
**/
@:genericBuild(Viktoria.ViktoriaMacro.build())
class Viktoria<T> {}

#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class ViktoriaMacro
{
	static public function build()
	{	
		// trace(Context.getLocalType());
		switch (Context.getLocalType())
		{
			case TInst(_, typeParams):

				if (typeParams.length > 1) Context.error("Only one Type parameter expected", Context.currentPos());
				var type = typeParams[0];

				switch (type) 
				{
					case TAbstract(n,[]):
						
						var name = n.get().name;
						if ( name == "Int" || name == "UInt")
						{	
							// trace("using ViktoriaInt");
							return TPath({ pack:[], name:"ViktoriaInt", params:[] });
						}

					default:
				}
				
				// trace('using Viktoria<T>');
				return TPath({ pack:[], name:"ViktoriaT", params:[TPType(TypeTools.toComplexType(type))] });
			
			default: Context.error("Type parameter expected", Context.currentPos());
		}
		return null;
	}

}
#end