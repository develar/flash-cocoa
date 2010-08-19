package cocoa.util {
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Rectangle;
import flash.geom.Utils3D;
import flash.geom.Vector3D;

public final class LayoutUtil {
  /**
   * Calculates 2D bounds of 3D object projection
   */
  public static function projectBounds(bounds:Rectangle, matrix:Matrix3D, projection:PerspectiveProjection):Rectangle {
    // Setup the matrix
    var centerX:Number = projection.projectionCenter.x;
    var centerY:Number = projection.projectionCenter.y;
    matrix.appendTranslation(-centerX, -centerY, projection.focalLength);
    matrix.append(projection.toMatrix3D());

    // Project the corner points
    var pt1:Vector3D = new Vector3D(bounds.left, bounds.top, 0);
    var pt2:Vector3D = new Vector3D(bounds.right, bounds.top, 0);
    var pt3:Vector3D = new Vector3D(bounds.left, bounds.bottom, 0);
    var pt4:Vector3D = new Vector3D(bounds.right, bounds.bottom, 0);
    pt1 = Utils3D.projectVector(matrix, pt1);
    pt2 = Utils3D.projectVector(matrix, pt2);
    pt3 = Utils3D.projectVector(matrix, pt3);
    pt4 = Utils3D.projectVector(matrix, pt4);

    // Find the bounding box in 2D
    var maxX:Number = Math.max(Math.max(pt1.x, pt2.x), Math.max(pt3.x, pt4.x));
    var minX:Number = Math.min(Math.min(pt1.x, pt2.x), Math.min(pt3.x, pt4.x));
    var maxY:Number = Math.max(Math.max(pt1.y, pt2.y), Math.max(pt3.y, pt4.y));
    var minY:Number = Math.min(Math.min(pt1.y, pt2.y), Math.min(pt3.y, pt4.y));

    // Add back the projection center
    bounds.x = minX + centerX;
    bounds.y = minY + centerY;
    bounds.width = maxX - minX;
    bounds.height = maxY - minY;
    return bounds;
  }
}
}