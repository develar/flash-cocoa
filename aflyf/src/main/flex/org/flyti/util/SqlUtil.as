package org.flyti.util
{
import flash.data.SQLConnection;
import flash.data.SQLStatement;

public final class SqlUtil
{
	public static function execute(sql:String, connection:SQLConnection):void
	{
		var sqlStatement:SQLStatement = new SQLStatement();
		sqlStatement.sqlConnection = connection;
		sqlStatement.text = sql;
		sqlStatement.execute();
	}
}
}