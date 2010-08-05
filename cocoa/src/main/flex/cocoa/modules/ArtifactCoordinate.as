package cocoa.modules
{
import flash.net.registerClassAlias;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

public class ArtifactCoordinate implements IExternalizable
{
	registerClassAlias("org.flyti.modules.ArtifactCoordinateImpl", ArtifactCoordinate);

	private var _groupId:String;
	public function get groupId():String
	{
		return _groupId;
	}

	public function set groupId(value:String):void
	{
		_groupId = value;
		_id = null;
	}

	private var _artifactId:String;
	public function get artifactId():String
	{
		return _artifactId;
	}

	public function set artifactId(value:String):void
	{
		_artifactId = value;
		_id = null;
	}

	private var _version:String;
	public function get version():String
	{
		return _version;
	}

	public function set version(value:String):void
	{
		_version = value;
		_id = null;
	}

	private var _classifier:String;
	public function get classifier():String
	{
		return _classifier;
	}

	public function set classifier(value:String):void
	{
		_classifier = value;
		_id = null;
	}

	public function ArtifactCoordinate(id1:String = null, id2:String = null, version:String = null, classifier:String = null)
	{
		if (id2 == null)
		{
			if (id1 != null)
			{
				parseId(id1);
			}
		}
		else
		{
			this.groupId = id1;
			this.artifactId = id2;
			this.version = version;
			this.classifier = classifier;
		}
	}

	private var _id:String = null;
	public function get id():String
	{
		if (_id === null)
		{
			var newId:String = (groupId == null ? "" : (groupId + "-")) + artifactId;
			if (version != null)
			{
				newId += "-" + version;
			}
			if (classifier != null)
			{
				newId += "-" + classifier;
			}

			_id = newId;
		}
		return _id;
	}

	public function createURI(template:String):String
	{
		return template.replace(/\{groupId\}/g, groupId).replace(/\{artifactId\}/g, artifactId).replace(/\{version\}/g, version).replace(/\{classifier\}/g, classifier);
	}

	public function clone():ArtifactCoordinate
	{
		return new ArtifactCoordinate(groupId, artifactId, version, classifier);
	}

	public function equals(moduleId:ArtifactCoordinate):Boolean
	{
		return id === moduleId.id;
	}

	/**
	 * Парсит finalName (без расширения файла), к примеру, twp-1.0-SNAPSHOT: id: twp, version: 1.0-SNAPSHOT
	 * или с groupId: com.xpressPages.plugins.elements.core-elements-3.0-SNAPSHOT
	 * В id может быть дефис, но он должен быть между буквами, то есть twp-blue допустимо, а twp-23blue нет
	 */
	private function parseId(id:String):void
	{
		var data:Array = id.match(/^((?P<groupId>[a-zA-Z.]+)-)?(?P<artifactId>[a-zA-Z\d]+[a-zA-Z-]*)-(?P<version>[\d.]+(-[a-z\d-]+)?(-[A-Z]+)?)(-(?P<classifier>.+))?$/);
		if (data == null)
		{
			throw new ArgumentError("module name is invalid: " + data);
		}

		if (data.groupId != "")
		{
			groupId = data.groupId;
		}
		artifactId = data.artifactId;
		version = data.version;
		if (data.classifier != "")
		{
			classifier = data.classifier;
		}

		_id = null;
	}

	public function toString():String
	{
		return id;
	}

	public function readExternal(input:IDataInput):void
	{
		groupId = input.readUTF();
		artifactId = input.readUTF();
		version = input.readUTF();
		classifier = input.readUTF();
	}

	public function writeExternal(output:IDataOutput):void
	{
	}
}
}