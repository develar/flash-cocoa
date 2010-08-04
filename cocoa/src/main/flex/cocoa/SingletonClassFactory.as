package cocoa
{
public final class SingletonClassFactory extends ClassFactory
{
	private var instance:Object;

	public function SingletonClassFactory(clazz:Class)
	{
		super(clazz);
	}

	override public function newInstance():*
	{
		if (instance == null)
		{
			instance = super.newInstance();
		}

		return instance;
	}
}
}