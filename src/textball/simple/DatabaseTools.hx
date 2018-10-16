package textball.simple;

import haxe.ds.Option;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import org.msgpack.MsgPack;
import resdb.adapter.IntConverter;
import resdb.Database;


typedef PluralFormulaDataStruct = {
    numForms:Int,
    formula:String
};


class DatabaseTools {
    public static function stringGet(database:Database, namespace:String, key:String)
            :Option<Bytes> {
        return database.get(Bytes.ofString('$namespace:$key'));
    }

    public static function stringGetString(database:Database, namespace:String,
            key:String):Option<String> {
        switch stringGet(database, namespace, key) {
            case Some(bytes):
                return Some(decodeString(bytes));
            case None:
                return None;
        }
    }

    public static function stringGetArray(database:Database, namespace:String,
            key:String):Option<Array<String>> {
        switch stringGet(database, namespace, key) {
            case Some(bytes):
                return Some(decodeArray(bytes));
            case None:
                return None;
        }
    }

    public static function intGet(database:Database, namespace:String, key:Int)
            :Option<Bytes> {
        var buffer = new BytesBuffer();
        buffer.addString(namespace);
        buffer.addString(":");
        buffer.add(IntConverter.intToBytes(key));
        var key = buffer.getBytes();
        return database.get(key);
    }

    public static function intGetString(database:Database, namespace:String,
            key:Int):Option<String> {
        switch intGet(database, namespace, key) {
            case Some(bytes):
                return Some(decodeString(bytes));
            case None:
                return None;
        }
    }

    public static function intGetArray(database:Database, namespace:String,
            key:Int):Option<Array<String>> {
        switch intGet(database, namespace, key) {
            case Some(bytes):
                return Some(decodeArray(bytes));
            case None:
                return None;
        }
    }

    public static function getIntString(database:Database, namespace:String,
            key:Int, value:String):Option<String> {
        var buffer = new BytesBuffer();
        buffer.addString(namespace);
        buffer.addString(":");
        buffer.add(IntConverter.intToBytes(key));
        var key = buffer.getBytes();

        switch database.get(key) {
            case Some(bytes):
                return Some(bytes.toString());
            case None:
                return None;
        }
    }

    static function decodeArray(bytes:Bytes):Array<String> {
        var result:Any = MsgPack.decode(bytes);

        if (Std.is(result, Array)) {
            return result;
        } else if (Std.is(result, String)) {
            return [result];
        } else {
            throw new Exception("Not an array or string");
        }
    }

    static function decodeString(bytes:Bytes):String {
        var result:Any = MsgPack.decode(bytes);

        if (Std.is(result, String)) {
            return result;
        } else if (Std.is(result, Array)) {
            var array:Array<String> = result;

            if (array.length > 0) {
                return array[0];
            } else {
                throw new Exception("Array empty");
            }
        } else {
            throw new Exception("Not an array or string");
        }
    }
}
