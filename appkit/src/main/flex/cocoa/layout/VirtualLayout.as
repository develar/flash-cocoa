package cocoa.layout {
public interface VirtualLayout {
  /**
   *  The index of the first layout element that is part of the
   *  layout and within the layout target's scroll rectangle, or -1
   *  if nothing has been displayed yet.
   *
   *  <p>"Part of the layout" means that the element is non-null
   *  and that its <code>includeInLayout</code> property is <code>true</code>.</p>
   *
   *  <p>Note that the layout element may only be partially in view.</p>
   */
  function get firstIndexInView():int;

  /**
   *  The index of the last row that's part of the layout and within
   *  the container's scroll rectangle, or -1 if nothing has been displayed yet.
   *
   *  <p>"Part of the layout" means that the child is non-null
   *  and that its <code>includeInLayout</code> property is <code>true</code>.</p>
   *
   *  <p>Note that the row may only be partially in view.</p>
   *
   *  @see firstIndexInView
   *  @see fractionOfElementInView
   */
  function get lastIndexInView():int;
}
}