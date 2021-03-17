import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/*
  A classe não herda de nenhuma outra, por isso não precisamos passar o "extends"
*/

/*
  Definindo os nomes da nossa coluna para facilitar a escrita e evitar que pos-
  samos errar quando começarmos a manipular os dados.
*/

final String contactTable = "contactTable"; //Nome da tabela
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  /*
    Pelo fato de querermos que essa classe tenha um único objeto, utilizaremos o 
    padrão singleton, que específica que cada classe realiza uma única coisa.

    O static será uma variável da classe e não do objeto inteiro
  */
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  /*
    A classe faz o seguinte, qundo eu delcaro minha classe eu estou criando um 
    objeto dela mesmo(_instance). Chamo um construtor interno que não pode ser 
    chamado de fora da minha classe.

    Quando quisermos obter o objeto de qualquer parte do código, devemos colocar
    "ContactHelper.instance()" e assim conseguiremos acessar o objeto.
  */

  // Declarando o banco de dados

  Database _db;

  // Inicializando o banco de dados

  Future<Database> get db async {
    // Se não for nulo, pegamos o banco de dados. Se for nulo, iniciamos o bd
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  // Inicializa o banco de dados caso ele não tenha sido inicializado
  // Retorna um future pois se trata de uma coisa assincrona e o tipo é data-
  // base
  Future<Database> initDb() async {
    //Pegando o local onde o banco de dados é armazenado
    final databasesPath = await getDatabasesPath();
    // Pegando o arquivo do banco de dados
    final path = join(databasesPath, "contactsnewbd.db");
    /*
        Pega o caminho da pasta onde está sendo armazenado o banco de dados e 
        estamos juntando com o nome do banco de dados e retornando o caminho dis-
        so. 
      */

    /* 
        Abrindo o bd, precisamos informar o local, a versão(int) e uma função 
        para criar o bd quando iniciarmos pela primeira vez.
      */

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      // Comandos SQL
      // Cria todos os dados da tabela desejada
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  //Salvando o contato no banco de dados
  Future<Contact> saveContact(Contact contact) async {
    /*
      O dbContact obtem a mesma informção que a classe get db, por isso ela se 
      torna uma função assíncrona
    */
    Database dbContact = await db;
    /*
      Inserindo dados na tabela com o "insert()". O contactTable é o nome da 
      tabela e o valor e value será o contact transformando em map com o "toMap".

      Detalhe importante, quando os dados são salvos dentro do banco de dados, 
      ele gera um id e por isso devemos armazernar no id para não perdemos esse 
      dado.
    */
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    // Após ser salvo, ele retorna o contact
    return contact;
  }

  Future<Contact> getContact(int id) async {
    // Recebe o id pois estamos fazendo uma busca e queremos o nosso contato
    // único
    // Acessando o bd
    Database dbContact = await db;

    // Retorna numa lista de map, onde cada map é um contato, depois é feito uma
    // query
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    /*
        Uma query recebe: Nome da tabela como primeiro parâmetro e depois recebe
        o parâmetro "column" do próprio dart, ondeessa column é uma lista onde 
        iremos dizer quais campos seremos selecionados, seguido do where(regra
        para obter os dados.). ex.: dbContact.query(
        nomeTabela, column: [colunasQueQueremosSelecionar], where: regra para 
        selecionar os dados, 
        whereArgs: argumentos que serão utilizados)
      */
    /*
      Verifica se foi retornado um contato, esse retorno gera um inteiro. Como o
      interable não permite acessar posições map[0], então utiliza-se o 
      "map.first" para o primeiro elemento e "map.last" para o último elemento.
    */
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Deletando contao, recebe o id do contato. seguido do where e whereArgs
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    // Passando o id que queremos deletar. parâmetros, nomeTabela, id. Retorna
    // um inteiro informando se ele foi deletado ou não
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  // ignore: missing_return
  Future<int> updateContact(Contact contact) async {
    // Pegando o banco de dados
    // Ele recebe como parâmetro o contact, pois é ele quem queremos atualizar
    Database dbContact = await db;
    // Pegando o contato
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
    /* 
      No update de um contato, devemo passar: nome da tabela, transformar o 
      contact em map,where: o id da coluna, whereArgs: [o id do contato que 
      queremos alterar.] 
    */
  }

  Future<List> getAllContact() async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Selecionando tudo
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    /* 
      Transformando uma lista de maps em uma de contato, isso se deve apenas 
      pelo tipo de retorno que foi especírficado, onde a primeira é uma lista de 
      map e a segund de contact.

      OBS.: Se o tipo não for específicado, o tipo será dinâmico, por isso de-
      vemos específicar o tipo para não ocorrer erros.
    */
    List<Contact> listContact = <Contact>[];
    /*  
      Antigamente para converter uma lista de map para uma de contato colocava-
      -se "List();", mas como foi depreciado, agora para realizar essa conversão
      devemos utilizar. "<NomeObjeto>[];" e a conversão é feita.
    */
    for (Map m in listMap) {
      // Adicionando o map à lista de contato
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  // obtendo a quantidade total de contatos
  Future<int> getNumber() async {
    // Obtendo o banco de dados
    Database dbContact = await db;
    // Contando os elementos da tabela
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  // fecha o banco de dados
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

/* 
  Salvando o contato no banco de dados, como isso não acontece instântaneamente, 
  se tora uma função async
*/

// Definindo o molde para o contato

// id   name    email   phone   img
// 0    Adson   ads@df  455     /images/

class Contact {
  /*
    Os dados são em forma de string, por isso é colocado o String antes dos da-
    dos. Já o id é o inteiro gerado de forma única para cada contato e o próprio
    banco de dados define esse "id".
  */

  int id;
  String name;
  String email;
  String phone;
  String img;

  // Construtor vazio
  Contact();

  // Transformando os dados em map
  Contact.fromMap(Map map) {
    // Pegando os dados através do map
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  // pegando o contato que vai transformar
  // ignore: missing_return
  Map toMap() {
    /* 
      O Map indica o tipo. <string(nome dos campos), dynamic (dados)>,
      Não colocamos o id porque quando criamos um contato o própio banco de da-
      dos faz essa atribuição. Esse id pode ser nulo ou não.

      Devemos verificar se o id é nulo ou não para podermos pegar essa informa-
      ção
    */
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      // Armazena o map do id somente se não for NULO
      map[idColumn] = id;
    }
    // Retornando o map
    return map;

    /*
      Sempre que vamos mostrar algum dado e queremos que ele tenha um formato 
      específico, devemos reescrever o método toString() e assim fazer com que a
      nossa leitura seja fácil.
    */
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, : $phone, img: $img)";
  }
}
