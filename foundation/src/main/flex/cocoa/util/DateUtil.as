package cocoa.util {
public class DateUtil {
  /**
   * support ISO8601 extended Z
   */
  public static function fromISO8601(string:String):Date {
    var result:Array = string.match(/^(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})T(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})/);
    var date:Date = new Date();
    date.fullYearUTC = result.year;
    date.monthUTC = result.month - 1;
    date.dateUTC = result.day;
    date.hoursUTC = result.hour;
    date.minutesUTC = result.minute;
    date.secondsUTC = result.second;

    return date;
  }

//	public static function toISO8601(date:Date):String
//	{
//		var dateFormatter:DateFormatter = new DateFormatter();
//		dateFormatter.formatString = 'YYYYMMDDTHHNNSSZ';
//		return dateFormatter.format(date);
//	}
}
}