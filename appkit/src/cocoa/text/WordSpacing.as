package cocoa.text {
public class WordSpacing {
  public var optimumSpacing:Number;
  public var minimumSpacing:Number;
  public var maximumSpacing:Number;

  public function WordSpacing(optimumSpacing:Number = 100, minimumSpacing:Number = 50, maximumSpacing:Number = 150) {
    this.optimumSpacing = optimumSpacing;
    this.minimumSpacing = minimumSpacing;
    this.maximumSpacing = maximumSpacing;
  }
}
}
