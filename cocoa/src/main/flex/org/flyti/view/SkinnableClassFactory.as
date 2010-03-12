package org.flyti.view
{
import mx.core.IFactory;
import mx.styles.IStyleClient;

public class SkinnableClassFactory implements IFactory
{
	private var clazz:Class;
	private var skinClass:Class;

	public function SkinnableClassFactory(clazz:Class, skinClass:Class)
	{
		this.clazz = clazz;
		this.skinClass = skinClass;
	}

	public function newInstance():*
	{
		var instance:IStyleClient = new clazz();
		instance.setStyle("skinClass", skinClass);
		return instance;
	}
}
}