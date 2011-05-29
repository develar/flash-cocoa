package cocoa.plaf.aqua.demo {
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableViewDataSource;

import flash.errors.IllegalOperationError;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

public class DemoTableViewDataSource implements TableViewDataSource {
  private var data:XML = <records>	<record>
		<a>Pico Rivera</a>
		<b>Elaine</b>
	</record>
	<record>
		<a>Little Falls</a>
		<b>Celeste</b>
	</record>
	<record>
		<a>Orlando</a>
		<b>Glenna</b>
	</record>
	<record>
		<a>York</a>
		<b>Lysandra</b>
	</record>
	<record>
		<a>Lynwood</a>
		<b>Erasmus</b>
	</record>
	<record>
		<a>Honolulu</a>
		<b>Mallory</b>
	</record>
	<record>
		<a>Spartanburg</a>
		<b>Garth</b>
	</record>
	<record>
		<a>Passaic</a>
		<b>Mikayla</b>
	</record>
	<record>
		<a>Laughlin</a>
		<b>Stacy</b>
	</record>
	<record>
		<a>Weymouth</a>
		<b>Theodore</b>
	</record>
	<record>
		<a>Seward</a>
		<b>Chase</b>
	</record>
	<record>
		<a>Bay City</a>
		<b>Rudyard</b>
	</record>
	<record>
		<a>Henderson</a>
		<b>Emery</b>
	</record>
	<record>
		<a>Lansing</a>
		<b>Tobias</b>
	</record>
	<record>
		<a>Fontana</a>
		<b>Peter</b>
	</record>
	<record>
		<a>McKeesport</a>
		<b>Zorita</b>
	</record>
	<record>
		<a>Aspen</a>
		<b>Amber</b>
	</record>
	<record>
		<a>Claremore</a>
		<b>Nichole</b>
	</record>
	<record>
		<a>Houston</a>
		<b>Cassandra</b>
	</record>
	<record>
		<a>Gainesville</a>
		<b>Uma</b>
	</record>
	<record>
		<a>Laguna Niguel</a>
		<b>Nolan</b>
	</record>
	<record>
		<a>Mesa</a>
		<b>Flavia</b>
	</record>
	<record>
		<a>Barre</a>
		<b>Daquan</b>
	</record>
	<record>
		<a>Ypsilanti</a>
		<b>Kessie</b>
	</record>
	<record>
		<a>Brockton</a>
		<b>Wynne</b>
	</record>
	<record>
		<a>Kennewick</a>
		<b>Veronica</b>
	</record>
	<record>
		<a>Charleston</a>
		<b>Kameko</b>
	</record>
	<record>
		<a>Rochester</a>
		<b>Kellie</b>
	</record>
	<record>
		<a>Santa Monica</a>
		<b>Dana</b>
	</record>
	<record>
		<a>Kearney</a>
		<b>Blaze</b>
	</record>
	<record>
		<a>Woonsocket</a>
		<b>Zachery</b>
	</record>
	<record>
		<a>Bremerton</a>
		<b>Alec</b>
	</record>
	<record>
		<a>Ardmore</a>
		<b>Eaton</b>
	</record>
	<record>
		<a>Pullman</a>
		<b>Ina</b>
	</record>
	<record>
		<a>Kettering</a>
		<b>Amir</b>
	</record>
	<record>
		<a>Green Bay</a>
		<b>Urielle</b>
	</record>
	<record>
		<a>Rolling Hills</a>
		<b>Theodore</b>
	</record>
	<record>
		<a>Durango</a>
		<b>Rudyard</b>
	</record>
	<record>
		<a>Centennial</a>
		<b>Darrel</b>
	</record>
	<record>
		<a>Hagerstown</a>
		<b>Denise</b>
	</record>
	<record>
		<a>Cranston</a>
		<b>Robin</b>
	</record>
	<record>
		<a>Concord</a>
		<b>Gloria</b>
	</record>
	<record>
		<a>Gallup</a>
		<b>Warren</b>
	</record>
	<record>
		<a>Thomasville</a>
		<b>Brooke</b>
	</record>
	<record>
		<a>College Station</a>
		<b>Fulton</b>
	</record>
	<record>
		<a>Duarte</a>
		<b>Castor</b>
	</record>
	<record>
		<a>Gaithersburg</a>
		<b>George</b>
	</record>
	<record>
		<a>Coral Springs</a>
		<b>Geraldine</b>
	</record>
	<record>
		<a>Niagara Falls</a>
		<b>Ursa</b>
	</record>
	<record>
		<a>Salinas</a>
		<b>Avye</b>
	</record>
	<record>
		<a>Wilkes-Barre</a>
		<b>Brooke</b>
	</record>
	<record>
		<a>Akron</a>
		<b>Oscar</b>
	</record>
	<record>
		<a>Aspen</a>
		<b>Deirdre</b>
	</record>
	<record>
		<a>Mesa</a>
		<b>Charde</b>
	</record>
	<record>
		<a>Lincoln</a>
		<b>Ulla</b>
	</record>
	<record>
		<a>Kansas City</a>
		<b>Nigel</b>
	</record>
	<record>
		<a>Pullman</a>
		<b>Mara</b>
	</record>
	<record>
		<a>Bayamon</a>
		<b>Anastasia</b>
	</record>
	<record>
		<a>Moraga</a>
		<b>William</b>
	</record>
	<record>
		<a>Cohoes</a>
		<b>Quinn</b>
	</record>
	<record>
		<a>Farmer City</a>
		<b>Iliana</b>
	</record>
	<record>
		<a>Waterbury</a>
		<b>Luke</b>
	</record>
	<record>
		<a>Saint Albans</a>
		<b>Buffy</b>
	</record>
	<record>
		<a>West Valley City</a>
		<b>Hilel</b>
	</record>
	<record>
		<a>Battle Creek</a>
		<b>Pascale</b>
	</record>
	<record>
		<a>Laurel</a>
		<b>Allen</b>
	</record>
	<record>
		<a>Superior</a>
		<b>Jordan</b>
	</record>
	<record>
		<a>Saginaw</a>
		<b>Todd</b>
	</record>
	<record>
		<a>Rialto</a>
		<b>Forrest</b>
	</record>
	<record>
		<a>Bossier City</a>
		<b>David</b>
	</record>
	<record>
		<a>Dunkirk</a>
		<b>Kennan</b>
	</record>
	<record>
		<a>West Covina</a>
		<b>Yael</b>
	</record>
	<record>
		<a>Claremont</a>
		<b>Aileen</b>
	</record>
	<record>
		<a>Ansonia</a>
		<b>Porter</b>
	</record>
	<record>
		<a>Wilkes-Barre</a>
		<b>Clio</b>
	</record>
	<record>
		<a>Mandan</a>
		<b>Desiree</b>
	</record>
	<record>
		<a>Nome</a>
		<b>Jasper</b>
	</record>
	<record>
		<a>Sunnyvale</a>
		<b>Hiroko</b>
	</record>
	<record>
		<a>Natchez</a>
		<b>Sawyer</b>
	</record>
	<record>
		<a>Santa Rosa</a>
		<b>Merritt</b>
	</record>
	<record>
		<a>Monrovia</a>
		<b>Emery</b>
	</record>
	<record>
		<a>Plainfield</a>
		<b>Jackson</b>
	</record>
	<record>
		<a>San Gabriel</a>
		<b>Jeremy</b>
	</record>
	<record>
		<a>Half Moon Bay</a>
		<b>Kenneth</b>
	</record>
	<record>
		<a>Santa Clara</a>
		<b>Jamal</b>
	</record>
	<record>
		<a>San Clemente</a>
		<b>Amos</b>
	</record>
	<record>
		<a>Ypsilanti</a>
		<b>Paki</b>
	</record>
	<record>
		<a>Ann Arbor</a>
		<b>Cassandra</b>
	</record>
	<record>
		<a>Rock Island</a>
		<b>Amos</b>
	</record>
	<record>
		<a>Villa Park</a>
		<b>Omar</b>
	</record>
	<record>
		<a>Edina</a>
		<b>Jael</b>
	</record>
	<record>
		<a>Yazoo City</a>
		<b>Tanner</b>
	</record>
	<record>
		<a>Vernon</a>
		<b>Solomon</b>
	</record>
	<record>
		<a>Fontana</a>
		<b>Keith</b>
	</record>
	<record>
		<a>Pine Bluff</a>
		<b>Blythe</b>
	</record>
	<record>
		<a>Cortland</a>
		<b>Driscoll</b>
	</record>
	<record>
		<a>Idabel</a>
		<b>Theodore</b>
	</record>
	<record>
		<a>Quincy</a>
		<b>Christine</b>
	</record>
	<record>
		<a>Hermosa Beach</a>
		<b>Baxter</b>
	</record>
	<record>
		<a>Rawlins</a>
		<b>Charlotte</b>
	</record>
	<record>
		<a>Merced</a>
		<b>Kay</b>
	</record>
	<record>
		<a>Douglas</a>
		<b>Kieran</b>
	</record>
	<record>
		<a>El Cerrito</a>
		<b>Desirae</b>
	</record>
	<record>
		<a>Portland</a>
		<b>Akeem</b>
	</record>
	<record>
		<a>Frederick</a>
		<b>Martena</b>
	</record>
	<record>
		<a>Rhinelander</a>
		<b>Lana</b>
	</record>
	<record>
		<a>Bozeman</a>
		<b>Palmer</b>
	</record>
	<record>
		<a>La Mirada</a>
		<b>Alexis</b>
	</record>
	<record>
		<a>Nashua</a>
		<b>Quail</b>
	</record>
	<record>
		<a>Miami Gardens</a>
		<b>Erich</b>
	</record>
	<record>
		<a>Sunbury</a>
		<b>Preston</b>
	</record>
	<record>
		<a>Montpelier</a>
		<b>Dylan</b>
	</record>
	<record>
		<a>Oro Valley</a>
		<b>Ezra</b>
	</record>
	<record>
		<a>Lander</a>
		<b>Amos</b>
	</record>
	<record>
		<a>Huntington Park</a>
		<b>Colt</b>
	</record>
	<record>
		<a>Douglas</a>
		<b>William</b>
	</record>
	<record>
		<a>Redondo Beach</a>
		<b>Jenna</b>
	</record>
	<record>
		<a>Lockport</a>
		<b>Abra</b>
	</record>
	<record>
		<a>Rancho Santa Margarita</a>
		<b>Cora</b>
	</record>
	<record>
		<a>Ann Arbor</a>
		<b>Amethyst</b>
	</record>
	<record>
		<a>Sturgis</a>
		<b>Quon</b>
	</record>
	<record>
		<a>New Iberia</a>
		<b>Xenos</b>
	</record>
	<record>
		<a>Los Angeles</a>
		<b>Autumn</b>
	</record>
	<record>
		<a>Yuma</a>
		<b>Branden</b>
	</record>
	<record>
		<a>Somerville</a>
		<b>Kuame</b>
	</record>
	<record>
		<a>Ithaca</a>
		<b>Nora</b>
	</record>
	<record>
		<a>Gainesville</a>
		<b>Abdul</b>
	</record>
	<record>
		<a>Ypsilanti</a>
		<b>Zachery</b>
	</record>
	<record>
		<a>Fremont</a>
		<b>Jeremy</b>
	</record>
	<record>
		<a>Aspen</a>
		<b>Ocean</b>
	</record>
	<record>
		<a>Perth Amboy</a>
		<b>Dorothy</b>
	</record>
	<record>
		<a>Palm Springs</a>
		<b>Ingrid</b>
	</record>
	<record>
		<a>Richland</a>
		<b>Chanda</b>
	</record>
	<record>
		<a>Kalispell</a>
		<b>Jocelyn</b>
	</record>
	<record>
		<a>Hudson</a>
		<b>Janna</b>
	</record>
	<record>
		<a>Marietta</a>
		<b>Donna</b>
	</record>
	<record>
		<a>Dothan</a>
		<b>Cally</b>
	</record>
	<record>
		<a>DuBois</a>
		<b>Paula</b>
	</record>
	<record>
		<a>Des Moines</a>
		<b>Daquan</b>
	</record>
	<record>
		<a>Starkville</a>
		<b>Aubrey</b>
	</record>
	<record>
		<a>Sandy</a>
		<b>Eagan</b>
	</record>
	<record>
		<a>San Gabriel</a>
		<b>Brenden</b>
	</record>
	<record>
		<a>Fairfield</a>
		<b>Raymond</b>
	</record>
	<record>
		<a>Brea</a>
		<b>Liberty</b>
	</record>
	<record>
		<a>El Monte</a>
		<b>Cailin</b>
	</record>
	<record>
		<a>Frisco</a>
		<b>Wilma</b>
	</record>
	<record>
		<a>Isle of Palms</a>
		<b>Zena</b>
	</record>
	<record>
		<a>Holyoke</a>
		<b>Casey</b>
	</record>
	<record>
		<a>Cincinnati</a>
		<b>Sasha</b>
	</record>
	<record>
		<a>Oil City</a>
		<b>Lane</b>
	</record>
	<record>
		<a>Flint</a>
		<b>Charlotte</b>
	</record>
	<record>
		<a>Somerville</a>
		<b>Kellie</b>
	</record>
	<record>
		<a>Glendora</a>
		<b>Ayanna</b>
	</record>
	<record>
		<a>Evansville</a>
		<b>Laith</b>
	</record>
	<record>
		<a>Gardena</a>
		<b>Cade</b>
	</record>
	<record>
		<a>North Pole</a>
		<b>Brianna</b>
	</record>
	<record>
		<a>Jacksonville</a>
		<b>Inez</b>
	</record>
	<record>
		<a>Duncan</a>
		<b>Nina</b>
	</record>
	<record>
		<a>Dayton</a>
		<b>Germaine</b>
	</record>
	<record>
		<a>Fort Lauderdale</a>
		<b>Jocelyn</b>
	</record>
	<record>
		<a>Lexington</a>
		<b>Macon</b>
	</record>
	<record>
		<a>Kearns</a>
		<b>Troy</b>
	</record>
	<record>
		<a>New Albany</a>
		<b>Scarlett</b>
	</record>
	<record>
		<a>Bethlehem</a>
		<b>Ramona</b>
	</record>
	<record>
		<a>Overland Park</a>
		<b>Paki</b>
	</record>
	<record>
		<a>Greensboro</a>
		<b>Xandra</b>
	</record>
	<record>
		<a>Vernon</a>
		<b>Christen</b>
	</record>
	<record>
		<a>Little Falls</a>
		<b>Devin</b>
	</record>
	<record>
		<a>Everett</a>
		<b>Ralph</b>
	</record>
	<record>
		<a>Shreveport</a>
		<b>Louis</b>
	</record>
	<record>
		<a>Valparaiso</a>
		<b>Jennifer</b>
	</record>
	<record>
		<a>Raleigh</a>
		<b>Gavin</b>
	</record>
	<record>
		<a>Two Rivers</a>
		<b>Yen</b>
	</record>
	<record>
		<a>Bakersfield</a>
		<b>Brooke</b>
	</record>
	<record>
		<a>Gary</a>
		<b>Gillian</b>
	</record>
	<record>
		<a>New Kensington</a>
		<b>Rylee</b>
	</record>
	<record>
		<a>Williamsport</a>
		<b>Arden</b>
	</record>
	<record>
		<a>Rawlins</a>
		<b>Leila</b>
	</record>
	<record>
		<a>Torrance</a>
		<b>Ryan</b>
	</record>
	<record>
		<a>Hanahan</a>
		<b>Lael</b>
	</record>
	<record>
		<a>Miami Gardens</a>
		<b>Octavius</b>
	</record>
	<record>
		<a>Marquette</a>
		<b>Jocelyn</b>
	</record>
	<record>
		<a>Valdez</a>
		<b>Alisa</b>
	</record>
	<record>
		<a>Richland</a>
		<b>Christine</b>
	</record>
	<record>
		<a>Sault Ste. Marie</a>
		<b>Leandra</b>
	</record>
	<record>
		<a>Santa Clara</a>
		<b>Orli</b>
	</record>
	<record>
		<a>Bartlesville</a>
		<b>Kendall</b>
	</record>
	<record>
		<a>Benton Harbor</a>
		<b>Xanthus</b>
	</record>
	<record>
		<a>Lowell</a>
		<b>Britanni</b>
	</record>
	<record>
		<a>Boulder Junction</a>
		<b>Serina</b>
	</record>
	<record>
		<a>Las Cruces</a>
		<b>Nyssa</b>
	</record>
	<record>
		<a>Orlando</a>
		<b>Jakeem</b>
	</record>
	<record>
		<a>Salem</a>
		<b>Hillary</b>
	</record>
	<record>
		<a>Auburn</a>
		<b>Moana</b>
	</record>
	<record>
		<a>Del Rio</a>
		<b>Hop</b>
	</record>
	<record>
		<a>Dunkirk</a>
		<b>Ray</b>
	</record>
	<record>
		<a>Canandaigua</a>
		<b>Ralph</b>
	</record>
	<record>
		<a>Enid</a>
		<b>Amir</b>
	</record>
	<record>
		<a>Savannah</a>
		<b>Alana</b>
	</record>
	<record>
		<a>Duquesne</a>
		<b>Maggie</b>
	</record>
</records>
    ;

  public function get rowCount():int {
    return data.record.length();
  }

  public function getObjectValue(column:TableColumn, rowIndex:int):Object {
    throw new IllegalOperationError();
  }

  public function getStringValue(column:TableColumn, rowIndex:int):String {
    return data.record[rowIndex][column.dataField];
  }

  private var resetSignal:ISignal = new Signal();
  public function get reset():ISignal {
    return resetSignal;
  }
}
}

class TestItem {
  public var a:String;
  public var b:String;

  public function TestItem(a:String, b:String) {
    this.a = a;
    this.b = b;
  }
}