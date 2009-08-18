package org.flyti.util
{
public class KeyNotPresentError extends Error
{
	public function KeyNotPresentError(key:Object)
	{
		super("key " + key + " is not present");
	}
}
}