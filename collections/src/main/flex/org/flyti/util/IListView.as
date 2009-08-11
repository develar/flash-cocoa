package org.flyti.util
{
import mx.collections.ICollectionView;
import mx.collections.IList;

public interface IListView extends org.flyti.util.IList, ICollectionView
{
	function addAll(addList:mx.collections.IList):void
}
}