import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_help.dart';
import 'package:agenda_contatos/ui/Contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

/* 
  Declarando um enumerador:
    - Enumerador é um conjunto de constantes
    - Podemos atrav´s de um enumerador ordenar uma lista
    - A declaração se dá através de "{}"
    - Cada valor do enum terá um índice
    - Nesse caso, ele só terá apenas dois enumeradores
  
*/
enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*
    Se fosse qualquer outra classe o ContactHelper() e fizessemos com que ele
    tivesse duas variáveis diferente, ex. ContactHelper helper1 e ContactHelper()
    helper2, esse teria dois objetos diferentes, ou seja, dois banco de dados.
    Mas como implementamos com o padrão "singleton" dizemos que temos apenas um
    único objeto dentro da classe.

    Se tentar colocar o helper1 e helper2, ele continuará com um único banco de
    dados, ou sej, duas variáveis com o mesmo banco de dados.
  */

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = <Contact>[];

  /*
    Quando o app for iniciado, iremos arregar todos os contatos salvos, para isso iremos Reescrver o método do initState e depois pegar todos os contatos com getAllContact
  */
  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        // Atribuindo ações a appBar
        actions: <Widget>[
          /* 
            PopupMenuButton:
              - Exibe um menú quando é selecionado
              - chama uma função(onSelected) ele descarta um item pq ese foi selecionado
              - O valor passado para onSelecet é o valor do item de menu selecionado
              - Como filho, poderá ser chamado um filho ou um ícone, MAS não ambos
              - Se o ícone for selecionado, ele se comportará como úm IconButton
          */
          PopupMenuButton<OrderOptions>(
            // Declarando o itemBuilder que é solicitado, e retorna um popup menu entry
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              // Botão de ordenar A-Z
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de A-Z'),
                value: OrderOptions.orderaz,
              ),
              // Botão de Z-A
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      // Cor do fundo do app
      backgroundColor: Colors.white,
      /*
        O floatingActionButton adiciona um botão flutuante e dentro desse botão podemos passar um ícone e uma cor de fundo. Além disso temos também a função onPressed, responsável por fazer com que o uma ação seja executada ao ser pressionado o botão. O ícone deve ser passado dentro de um child.
      */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Não passa nenhum contato pois aperta no botão, pois cria um novo contato
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      // Corpo do app
      body: ListView.builder(
        /*
         Dica: Sempre em que um widget não tem a propriedade "padding", é recomanedadocolocá-lo dentro de um container e assim daremos o padding.
        */
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          // Retornando o card
          return _contactCard(context, index);
        },
      ),
    );
  }

  // Função responsável por criar um card, e ao tocar, será aberto mais infor-
  // mações

  Widget _contactCard(BuildContext context, int index) {
    /*
      BuildContext context:
        - São passados como parâmetros de função do tipo Widget buil, ou seja, aquelas responsáveis por construir algo.
        - O BuildContext serve para identificar o widget na árvore de widget.
        - Cada Widget tem seu próprio BuildContext que se torna pai da função retornado pela classe statelessWidget

      int index:
        - Serve para o card saber qual o contato que está sendo passado para a função
        - Poderia ser passado no lugar de "int index" o "Contact contact", o código alteraria pouca coisa em relação ao int index
   */

    /*
      Será retornado primeior o GestureDetector pelo fato de que o card não possui a funcionalidade de toque, então envolvemos o card dentro de um Widget que detectar os gestos.
    */
    return GestureDetector(
      child: Card(
        // Recebe como filho o padding poi o card não possui essa opção
        child: Padding(
          padding: EdgeInsets.all(10.0),
          // Então dentro do padding começaremos a colocar nosso conteúdo
          child: Row(
            /*
              containner e depois iremos específicar para que ele fique redonda
            */
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  // Esse box é responsável em deixar a imagem redonda
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    // Passando uma imagem default caso nenhuma seja passada
                    image: contacts[index].img != null
                        ? FileImage(File(contacts[index].img))
                        : AssetImage("images/person.png"),
                    /*
                      Se a imagem do contato for diferetne de null, então pegamos a imagem salva no banco de dados. Caso contrário, pegaremos a imagem do assets na pasta imagem
                    */
                  ),
                ),
              ),

              // Dano o espaçamento entre a imagem e o outro ícone
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                // Passaremos uma coluna como filho pois nossos dados são mostrados um em cima do outro.
                child: Column(
                  // Alinhando o texto à esquerda para não ficar centralizado
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Agora como filho de nossa coluna, serão passados três campos de textos
                  children: <Widget>[
                    // Pegando as informações do banco de dados e colocando em cada campo
                    Text(contacts[index].name ?? "",
                        // Exibe o txt vázio se o nome do contato for vazio
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(contacts[index].email ?? "",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    Text(contacts[index].phone ?? "",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      /* 
        Como vamos editar ao clicar no contato, então iremos passar ele mesmo 
        como contato        
      */
      onTap: () {
        // Ao clicar, aparecerão opções de editar, ligar e apagar
        _showOptions(context, index);
      },
    );
  }

// Função responsável por criar um box de opção na parte inferio da tela
  void _showOptions(BuildContext context, int index) {
    /*
          O BottomSheet serve para criar uma caixa no final da tela e
          dentro dela podemos passar várias opções. Existem dois tipos
          de BottomSheet o Persistent e o Modal:
          
          Persistent: Folha inferior aparece para complementar o aplica-
          tivo, mesmo com essa tela funcionando é possível mexer em ou-
          tras partes do app. As folhas inferiores podem ser mostradas 
          pela função ScaffoldState.showBottomSheet ou específicando o cons-
          trutor Scaffold.bottomSheet

          Modal: Uma folha inferior em alternativa a um menú, com o modal o
          usuário não pode interagir com o resto do app. Ela pode ser criada
          com a função showModalBottomSheet

          Persistent                VS                   Modal
           - Usuário pode continuar                      -Usuário não interage 
           a interagindo com o app                       - Alternativa a um menú
                                                         - Criada pelo showModal-
           -Criada e mostrada pelo                        BottomSheet
           construtor Scaffold.bottom-
           Sheet       
        */
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            //Função chamada quando ele está fechando a folha
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  // Delimitando o limite que a coluna irá ocupar
                  mainAxisSize: MainAxisSize.min, // Ocupa o minimo
                  // Filhos da coluna com os botoões
                  children: <Widget>[
                    // FlatButtom foi depreciado, agora é utilizado o TextButto
                    //Colocando todos em um padding para o melhor espaçamento
                    // Ligar
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        child: Text(
                          'Ligar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          /*
                           Devemos passar o launch seguido do queremos a-
                            brir, no caso queremos o telehone então uti-
                            lizaremo o tel: seguido do contato
                          */
                          launch('tel:${contacts[index].phone}');
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // editar
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        child: Text(
                          'Editar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),

                    // Excluir
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          // Colocando o código no setState para atualizar a
                          // view
                          setState(() {
                            // Removendo da lista
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  /* 
    Função responsável por realizar a troca de tela quando clicarmos sobre o 
    contato.

    Pelo fato de chamar o contato tanto no botão de adicionar como no botão de
    salvar, é recomendado agruar o código dentro de uma função.
  */

  // Entre chaves se torna parâmetro opcional
  void _showContactPage({Contact contact}) async {
    /* 
      Navigator:
        - O Navigator funciona como se fosse uma pilha, onde ele fica no topo 
        de um Widget e é responsável por chamar os widget que estão acima da
        hierarquia de um outro Widget.
        - Também pode ser usado para mostrar um pop-up que esteja acima de um
        outro Widget.
        É possível gerenciar a pilha de Widget(telas) com a API do flutter de
        duas maneiras: API DECLARATIVA(Navigator.page) ou a API IMPERATIVA(Na-
        vigator.push e Navigator.pop)
        - Quando o usuário precisa realizar a navegação de volta para a página
        anterior, ou seja, voltar a uma página na pilha, o Navigator é apropriado.
    */

    // Pegando os dados da tela e irá retorna o dado que a tela de contato enviar
    final recContact = await Navigator.push(
        //Recebe o contato
        context,
        // Retorna a tela que queremos mostrar
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )
            /* Quando for chamado a função do botão, não passarei o contato, mas quando for do contato, então chamarei o contato. */
            ));
    // Verificando se o contato é nulo ou não
    if (recContact != null) {
      // Verificando se é um contato novo ou que foi enviado
      if (contact != null) {
        await helper.updateContact(recContact); //Atualiza o contato
        // Cerragando todos os contatos
      } else {
        // Salvando novo contato
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  // Função para ordenação
  void _orderList(OrderOptions result) {
    // O switch é muito bom de ser utrilizado quando se tem constantes
    switch (result) {
      case OrderOptions.orderaz:
        // Ordenando a lista com a função sort do próprio dart
        contacts.sort((a, b) {
          // Pegando o nome e colocando em minúscula para poder ordenar
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
