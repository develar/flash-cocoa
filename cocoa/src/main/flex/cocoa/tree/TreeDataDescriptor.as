package cocoa.tree
{
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.controls.treeClasses.DefaultDataDescriptor;

public class TreeDataDescriptor extends DefaultDataDescriptor
{
	override public function getChildren(node:Object, model:Object = null):ICollectionView
	{
		var children:IList = IList(node.children);
		if (children is ICollectionView)
        {
            return ICollectionView(children);
        }
		else
		{
			return new ListCollectionView(children);
		}
	}

	override public function hasChildren(node:Object, model:Object = null):Boolean
    {
		return "children" in node && node.children != null && IList(node.children).length > 0;
	}

	override public function isBranch(node:Object, model:Object = null):Boolean
    {
		return "children" in node;
	}
}
}