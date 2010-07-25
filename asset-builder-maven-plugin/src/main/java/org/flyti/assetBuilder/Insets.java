package org.flyti.assetBuilder;

import org.simpleframework.xml.Attribute;

public class Insets
{
	@Attribute(name = "left")
	public final int left;
	@Attribute(name = "top", required = false)
	public final int top;
	@Attribute(name = "right")
	public final int right;
	@Attribute(name = "bottom")
	public final int bottom;

	public Insets(@Attribute(name = "left") int left, @Attribute(name = "top", required = false) int top, @Attribute(name = "right") int right, @Attribute(name = "bottom") int bottom)
	{
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}

	public Insets(@Attribute(name = "left") int left, @Attribute(name = "right") int right, @Attribute(name = "bottom") int bottom)
	{
		this.left = left;
		this.top = 0;
		this.right = right;
		this.bottom = bottom;
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
