package org.flyti.assetBuilder;

import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.Element;

public class Border
{
	@Attribute
	public String key;
	@Attribute(required = false)
	public String subkey;

	@Attribute
	public String type;

	@Element(required = false)
	public Insets contentInsets;

	@Element(required = false)
	public Insets frameInsets;
}