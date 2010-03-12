package cocoa.graphics
{
/**
 * iWeb like image fill modes
 */
public final class BitmapFillType
{
	/**
	 * scales the image up so it fills into the specified shape bounds,
	 * but often leaves margins
	 */
	public static const SCALE_TO_FIT:String = "scaleToFit";

	/**
	 * resizes the image to fill, cropping off the extra bits of images.
	 */
	public static const SCALE_TO_FILL:String = "scaleToFill";

	/**
	 * changes the height or width of an image
	 * to make it fit the shape size, changing its look.
	 */
	public static const STRETCH:String = "stretch";

	 /**
	  * includes the image at its original size,
	  * and will add borders if the image is larger or smaller than the shape size.
	  */
	public static const CENTER:String = "center";

	/**
	 * repeats the image at a small size
	 */
	public static const TILE:String = "tile";

	/**
	 * the same as ORIGINAL_IMAGE but if the image is larger than the shape size it turns to SCALE_TO_FIT
	 */
	public static const IMAGE_PREVIEW:String = "imagePreview";
}
}