package org.flyti.aqua
{
internal class RowInfo
{
	public var top:Number;
	public var width:Number;
	public var height:Number;

	public var border:AbstractBorder;

	public function RowInfo(border:AbstractBorder, width:Number = 50, height:Number = 30)
	{
		this.width = width;
		this.height = height;

		this.border = border;
	}
}
}