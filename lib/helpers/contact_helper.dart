import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// nome Columns SQLite
const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

class ContactHelper {
  // Instace contactHelper Constructor
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // SQLite
  late Database _db;

  Future<Database> get db async {
    // Verify not initi db
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  // Init DB
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return await openDatabase(path, version: 1,

        // Cria tabela se nao possui
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)",
      );
    });
  }

  // Insert Contact
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.topMap());
    return contact;
  }

  // Select Contact
  Future? getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Delete contact
  deleteContact(int id) async {
    Database dbContact = await db;
    await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  // Update Contact
  updateContact(Contact contact) async {
    Database dbContact = await db;
    await dbContact.update(contactTable, contact.topMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  // Select all contact
  Future<List> getAllContact() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List.empty();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  // Number Contacts
  getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

// Construtor Contact
class Contact {
  // Variaveis
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  // Get Contact
  Contact.fromMap(map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  // Post and Patch Contact
  Map<String, Object?> topMap() {
    // Map Contact
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    // Verify id not null
    if (id != null) {
      // Insert id on map
      map[idColumn] = id;
    }

    // Return map
    return map;
  }

  // Convert to string
  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
