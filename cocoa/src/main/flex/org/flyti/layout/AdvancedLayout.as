package org.flyti.layout
{
import mx.core.ILayoutElement;

public interface AdvancedLayout
{
	function childCanSkipMeasurement(element:ILayoutElement):Boolean;
}
}