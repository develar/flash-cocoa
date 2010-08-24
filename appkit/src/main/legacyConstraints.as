import cocoa.layout.LayoutMetrics;

protected var _layoutMetrics:LayoutMetrics;

override public function getConstraintValue(constraintName:String):*
{
	if (_layoutMetrics == null)
	{
		return undefined;
	}
	else
	{
		var value:Number = _layoutMetrics[constraintName];
		return isNaN(value) ? undefined : value;
	}
}

override public function setConstraintValue(constraintName:String, value:*):void
{
	if (_layoutMetrics == null)
	{
		_layoutMetrics = new LayoutMetrics();
	}

	_layoutMetrics[constraintName] = value;
}