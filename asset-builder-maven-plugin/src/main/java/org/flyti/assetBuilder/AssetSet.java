package org.flyti.assetBuilder;

import org.simpleframework.xml.ElementList;
import org.simpleframework.xml.Root;

import java.util.List;

@Root(name="assets")
public class AssetSet
{
	@ElementList(entry="border")
	public List<Border> borders;
}
