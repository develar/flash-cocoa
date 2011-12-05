package cocoa.util {
import flash.data.SQLStatement;
import flash.utils.Dictionary;

public class SqlBuilder {
  public static const FIELD:String = 'field';
  public static const JOIN:String = 'join';
  public static const LEFT_JOIN:String = 'left join';
  public static const WHERE:String = 'where';
  public static const GROUP_BY:String = 'group by';
  public static const HAVING:String = 'having';
  public static const ORDER_BY:String = 'order by';

  /**
   * Устанавливать имя перед выражением
   */
  private static const CONFIGURATION:Object =
  {
    field: {glue: ', ', prefix: false},
    where: {glue: ' and ', prefix: true},
    having: {glue: ' and ', prefix: true},
    join: {glue: ' join ', prefix: false},
    'left join': {glue: ' left join ', prefix: false},
    'group by': {glue: ', ', prefix: true},
    'order by': {glue: ', ', prefix: true}
  };

  private var sql:Dictionary = new Dictionary();

  private var _statement:SQLStatement = new SQLStatement();
  public function get statement():SQLStatement {
    return _statement;
  }

  public function add(name:String, ...values):void {
    if (!(name in sql)) {
      sql[name] = new Array();
    }
    for each (var value:String in values) {
      sql[name].push(value);
    }
  }

  public function get(name:String, setPrefix:Object/* Boolean */ = null, exludeValue:String = null):String {
    if (name in sql) {
      var prefix:String = '';
      if (setPrefix || (setPrefix === null && CONFIGURATION[name].prefix)) {
        prefix = name + ' ';
      }
      var values:Array = sql[name];
      if (exludeValue != null) {
        values = values.filter(function(value:String):Boolean {
          return value != exludeValue;
        });
      }
      return prefix + values.join(CONFIGURATION[name].glue);
    }
    else {
      return '';
    }
  }

  public function build():void {
    statement.text = 'select ' + get(FIELD) + ' from ' + get(JOIN) + get(LEFT_JOIN) + ' ' + get(WHERE) + ' ' + get(GROUP_BY) + ' ' + get(HAVING) + ' ' + get(ORDER_BY);
    //trace('\n' + statement.text);
  }
}
}