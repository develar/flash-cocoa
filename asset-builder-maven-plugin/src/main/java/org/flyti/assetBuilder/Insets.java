package org.flyti.assetBuilder;

import org.simpleframework.xml.Attribute;

public class Insets
{
	@Attribute(required = false)
	public int left;
	@Attribute(required = false)
	public int top;
	@Attribute(required = false)
	public int right;
	@Attribute(required = false)
	public int bottom;

	@Attribute(required = false)
	public byte truncatedTailMargin = -1;

	public Insets(int left, int top, int right, int bottom)
	{
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}

	@SuppressWarnings({"UnusedDeclaration"})
	public Insets()
	{
	}

	public int getWidth()
	{
		return left + right;
	}

	public int getHeight()
	{
		return top + bottom;
	}
}