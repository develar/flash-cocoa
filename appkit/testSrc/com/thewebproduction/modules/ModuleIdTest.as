package cocoa.modules
{
import org.flexunit.Assert;

public class ModuleIdTest
{
	[Test]
	public function parseNameWithIdAndSnapshotVersion():void
	{
		const artifactId:String = "twp";
		const version:String = "1.0-SNAPSHOT";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version);
		Assert.assertEquals(null, id.groupId);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(null, id.classifier);
	}

	[Test]
	public function parseNameWithIdAndVersion():void
	{
		const artifactId:String = "twp";
		const version:String = "1.0";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version);
		Assert.assertEquals(null, id.groupId);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(null, id.classifier);
	}

	[Test]
	public function parseNameWithIdAndVersionAndClassifier():void
	{
		const artifactId:String = "editor";
		const version:String = "3.0";
		const classifier:String = "en_US";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version + "-" + classifier);
		Assert.assertEquals(null, id.groupId);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(classifier, id.classifier);
	}

	[Test]
	public function parseNameWithIdAndSnapshotVersionAndClassifier():void
	{
		const groupId:String = "com.xpressPages.themes.animals";
		const artifactId:String = "d101";
		const version:String = "3.0-rc1-SNAPSHOT";
		const classifier:String = "web";
		var id:ArtifactCoordinate = new ArtifactCoordinate(groupId + "-" + artifactId + "-" + version + "-" + classifier);
		Assert.assertEquals(groupId, id.groupId);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(classifier, id.classifier);
	}

	[Test]
	public function parseNameWithIdAndDeficeContainedSnapshotVersionAndClassifier():void
	{
		const artifactId:String = "editor";
		const version:String = "3.0-rc1-SNAPHOT";
		const classifier:String = "en_US";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version + "-" + classifier);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(classifier, id.classifier);
	}

	[Test]
	public function equalWithClassifier():void
	{
		const artifactId:String = "editor";
		const version:String = "3.0-SNAPHOT";
		const classifier:String = "en_US";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version + "-" + classifier);
		var id2:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version + "-" + classifier);
		Assert.assertTrue(id.equals(id2));
		Assert.assertTrue(id2.equals(id));

		id2.version = "33";
		Assert.assertFalse(id2.equals(id));
	}

	[Test]
	public function equalWithoutClassifier():void
	{
		const artifactId:String = "editor";
		const version:String = "3.0-SNAPHOT";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version);
		var id2:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version);
		Assert.assertTrue(id.equals(id2));
		Assert.assertTrue(id2.equals(id));
	}

	[Test]
	public function equalWithGroupId():void
	{
		const groupId:String = "com.xpressPages.plugins.elements.core";
		const artifactId:String = "editor";
		const version:String = "3.0-SNAPHOT";
		const classifier:String = "en_US";
		var id:ArtifactCoordinate = new ArtifactCoordinate(groupId + "-" + artifactId + "-" + version + "-" + classifier);
		Assert.assertEquals(groupId, id.groupId);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(classifier, id.classifier);
	}

	[Test]
	public function equalWithoutGroupId():void
	{
		const artifactId:String = "editor";
		const version:String = "3.0-SNAPHOT";
		const classifier:String = "en_US";
		var id:ArtifactCoordinate = new ArtifactCoordinate(artifactId + "-" + version + "-" + classifier);
		Assert.assertEquals(artifactId, id.artifactId);
		Assert.assertEquals(version, id.version);
		Assert.assertEquals(classifier, id.classifier);
	}
}
}