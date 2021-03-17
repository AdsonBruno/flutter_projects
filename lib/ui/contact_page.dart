import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:agenda_contatos/helpers/contact_help.dart';
import 'package:image_picker/image_picker.dart';

/* 
  O primeiro passo é criar um widget responsável por mostrar as informações mais 
  detalhadas
*/

class ContactPage extends StatefulWidget {
  /* 
    Construtor do contato:
      - Esse construtor vai servir para quando abrir a página do contato, ele
      já abrir no contato com todas as informações que desejamos editar daque-
      le contato.

  */
  // Variável responsável pelo contato, ela não muda e por isso será um final
  final Contact contact;

  ContactPage(
      {this.contact}); // Ao colocar um parâmetro entre chaves, ele se torna opcional

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  /* 
    Três controladores para podermos pegar os campos de textos e atualizarmos
    os contatos
  */
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  /* 
    Como a nova versão da API do ImagePicker não depende mais de métodos
    estáticos, agora devemos instânciar o ImagePicker onde quisermos que 
    ele seja utilizado. 
  */
  // Instânciando o ImagePicker
  // File _image;
  final _picker = ImagePicker();

  /* 
    Basicamente, se não passarmos o nome, quando tentarmos salvar, o foco do 
    texto volta para o campo que informamos, nesse caso o campo do nome. Então
    o focus serve para focar em algo ou o cursor voltar para algum campo caso
    a condição não seja satisfeita.
  */
  final _nameFocus = FocusNode();
  /* 
    Verificação inicial será false, caso o user comece a mexer nos campos, então
    o onChanged() será ativado.
  */
  bool _userEdited = false;

  Contact _editedContact;

  // Função chamada quando a página iniciar

  @override
  void initState() {
    super.initState();
    /* 
      Acessando objetos que estão em classes diferentes:
        - Podemos acessar utilizando o "widget", onde o widget é o nosso objeto(a classe) "ContactPage".
        - Após acessar a classe com o widget, devemos acessar o atributo "contact", ficando da seguinte forma: Ex.: widget.contact
    */
    if (widget.contact == null) {
      /*
       Se não for passado um contato para ser editado, então será criado um novo contato com a variável _editedContact 
      */
      _editedContact = Contact();
    } else {
      /* 
        Transformando o contato passado em um map, e pegando e criando um novo contato através do map. É basicamente uma duplicação do contato no _editedContact
      */
      _editedContact = Contact.fromMap(widget.contact.toMap());
    }

    /* 
      Os controladores nessa parte são responsáveis por quando abrirmos nossa tela no contato, os dados dos contatos serem carregados no nosso campo do formulário.
    */
    _nameController.text = _editedContact.name;
    _emailController.text = _editedContact.email;
    _phoneController.text = _editedContact.phone;
  }

  @override
  Widget build(BuildContext context) {
    /*  
      WillPopScope faz com que antes dele sair da tela, ele chame uma função.
      Essa função irá perguntar se o usuário tem certeza que deseja cancelar 
      os dados que não foram salvos. 
    */

    return WillPopScope(
      // onWllPop tenta vetar as tentativas do usuário de dispensar o modal
      // Se o retorno for um Future que seja falso, a rota não é mostrado
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          // Senão tiver um nome de contato, então aparecerá o nome "Novo contato" e se tiver, aparecerá o nome do contato
          title: Text(_editedContact.name ?? 'Novo Contato'),
          centerTitle: true,
        ),
        // Botaõ flutuante
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Verificação de campo de usuário(simple)
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              // Retornando o contato salvo caso não esteja vazio
              //Remove tela e volta para a anterior com o contato editado
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        // Adicionando o SingleChildScrollView para o tclado não sobreescrever informação
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              // adicionando o gesture detector para poder cliclar na nossa imagem
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  // Adicionando o circulo
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      // Se não tiver imagem adicionada, será pego o asset
                      image: _editedContact.img != null
                          ? FileImage(File(_editedContact.img))
                          : AssetImage("images/person.png"),
                    ),
                  ),
                ),
                onTap: () {
                  // getImageCamera();
                  // getImageGallery();
                  // showModalBottomSheet(context: context)
                  _showOptionCameraOrGallery(context);
                },
              ),
              // Adicionando os campos de textos
              TextField(
                  // Adicionando controlador
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: 'None'),
                  onChanged: (text) {
                    // Ativando caso o contato comece a ser executado
                    _userEdited = true;
                    // Mostrando na tela o que foi alterado
                    setState(() {
                      _editedContact.name = text;
                    });
                  }),
              TextField(
                // Adicionando o controlador para pegar o campo de texto
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (text) {
                  /* 
                  Como não precisamos ficar verificando para atualizar a página, então não precisa do onChanged 
                */
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                // Adicionando o controller para o telefone
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    // Verifica se o usuário edtou algum campo, caso tenha sido editado, per-
    // guntaremos se deseja salvar as alterações.
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            // Caixa que aparecerá quando tentar sair sem salvar
            return AlertDialog(
              title: Text('Descartar Alterações?'),
              content: Text('Se sair as alterações serão perdidas.'),
              actions: <Widget>[
                // Botões para as ações
                /*
                Como o "FlatButton" se tornou obsoleto, devemos implementar os
                "TextButton" no lugar deles. Devemos se atentar ao fato de que
                eles podem se misturar com outros elementos, no caso das lis-
                tas e por isso deve ser evitado em listas.
              */
                TextButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      // Se for cancelado, darei um pop para voltar uma tela na pilha

                      //O context identifica onde estamos na árvore de widget e podemos acessar outros widgets.
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: Text('Sim'),
                  onPressed: () {
                    // Nesse caso precisamos desempilhar dois widgets, logo 2 pops
                    Navigator.pop(context); //Remove o dialog
                    Navigator.pop(
                        context); //Remove o contactpage(volta a pag inicial)
                  },
                ),
              ],
            );
          });
      // Se  modificou algo, ele não poderá sair automaticamente da tela
      return Future.value(false);
    } else {
      // Informando ao WillPopScope que o usuário pode sair da tela se for true
      return Future.value(true);
    }
  }

  // Testando função para pegar imagem da câmera com a função

  Future getImageCamera() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.camera);
      final file = File(pickedFile.path);
      setState(() {
        if (pickedFile != null) {
          _editedContact.img = file.path;
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      // print('Error');
      _editedContact.img;
    }
  }

  Future getImageGallery() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      final file = File(pickedFile.path);
      setState(() {
        if (pickedFile != null) {
          _editedContact.img = file.path;
        } else {
          return _editedContact.img;
        }
      });
    } catch (e) {
      return _editedContact.img;
    }
  }

  // Função para escolher entre foto da câmera ou da galeria
  void _showOptionCameraOrGallery(BuildContext contex) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Padding para o botão de foto da câmera
              Padding(
                padding: EdgeInsets.only(right: 36),
                child: TextButton(
                    child: Icon(Icons.camera_alt_outlined,
                        color: Colors.redAccent, size: 40.0),
                    onPressed: () {
                      getImageCamera();
                    }),
              ),

              // Padding para o botão de pegar imagem da galeria
              Padding(
                padding: EdgeInsets.only(left: 36),
                child: TextButton(
                  child: Icon(Icons.image_search_sharp,
                      color: Colors.blueAccent, size: 40.0),
                  onPressed: () {
                    getImageGallery();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
