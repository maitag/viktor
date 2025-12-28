package;

#if !macro
/**
	Switches between ViktorInt, ViktorT<Null<T>> and ViktorT<T>:
		Viktor<Int>  -> ViktorInt
		Viktor<UInt> -> ViktorInt
		Viktor<Bool> -> ViktorT<Null<Bool>>
		Viktor<Float> -> ViktorT<Null<Float>>
	all others will become ViktorT<T>!
**/
@:genericBuild(Viktor.ViktorMacro.build())
class Viktor<T> {}

#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class ViktorMacro
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
							// trace("using ViktorInt");
							return TPath({ pack:[], name:"ViktorInt", params:[] });
						}
						else if (name == "Float" || name == "Bool")
						{	
							// trace('using Viktor<Null<$name>>');
							return TPath({ pack:[], name:"ViktorT", params:[
								TPType( TPath({ pack:[], name:"Null", params:[TPType(TypeTools.toComplexType(type))] }) )
							]});
						}

					default:
				}
				
				// trace('using Viktor<T>');
				return TPath({ pack:[], name:"ViktorT", params:[TPType(TypeTools.toComplexType(type))] });
			
			default: Context.error("Type parameter expected", Context.currentPos());
		}
		return null;
	}

}
#end