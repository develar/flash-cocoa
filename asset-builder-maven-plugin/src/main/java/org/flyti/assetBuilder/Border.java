package org.flyti.assetBuilder;

import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.Element;

public class Border
{
	@Attribute
	public String key;
	@Attribute
	public String type;

	@Element
	public Insets insets;
}