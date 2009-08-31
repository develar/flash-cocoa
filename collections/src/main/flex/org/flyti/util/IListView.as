package org.flyti.util
{
import mx.collections.ICollectionView;
import mx.collections.IList;

public interface IListView extends org.flyti.util.List, ICollectionView
{
	function addAll(addList:mx.collections.IList):void
}
}