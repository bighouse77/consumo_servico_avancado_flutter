// ignore_for_file: file_names, prefer_const_constructors, prefer_final_fields, avoid_print, prefer_typing_uninitialized_variables, deprecated_member_use, avoid_unnecessary_containers



/*
  ****************************** OBSERVAÇÃO ************************************
  Sobre API's: sempre deve-se consultar a documentação da API, pois o que é 
  exigido no cabeçalho ou o body, pode variar de API para API. Isso pode ser ou 
  não, muito complexo.
  
  A lógica, a estrutura basica para consumir qualquer API, sejá enviando dados 
  ou recuperando, é a mesma.
*/



import 'package:consumo_servico_avancado_flutter/Post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _urlBase = "https://jsonplaceholder.typicode.com";

  Future<List<Post>> _recuperarPostagens() async {
    http.Response response = await http.get(Uri.parse(_urlBase + "/posts"));
    var dadosJson = json.decode(response.body);
    /*
      Para retornar, precisamos converter 'dadosJson' que é um Map, em List
      pois: Future<List<Post>>
      Convertendo Map em List:
    */
    List<Post> postagens = [];

    // varrendo o Map
    for (var post in dadosJson) {
      print("post: " + post["title"]);

      // criando o objeto
      Post p = Post(
        post["userId"],
        post["id"],
        post["title"],
        post["body"],
      );

      // populando a lista com o objeto
      postagens.add(p);
    }

    // retornando a List
    return postagens;
  }

  // POST, PUT, PATCH, DELETE
  // envia dados
  _post() async {
    Post post = Post(120, 0, "Titulo", "Corpo da postagem",);

    // encode transforma objeto json em String
    var corpo = json.encode(post.toJson());

    http.Response response = await http.post(Uri.parse(_urlBase + "/posts"),
        
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: corpo);

    print("resposta: ${response.statusCode}");
    print("resposta: ${response.body}");
  }

  // atualiza dados (tem que enviar tudo)
  _put() async {
    Post post = Post(120, 0, "Titulo", "Corpo da postagem",);

    var corpo = json.encode(post.toJson());

    http.Response response = await http.put(Uri.parse(_urlBase + "/posts/2"),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: corpo);

    print("resposta: ${response.statusCode}");
    print("resposta: ${response.body}");
  }

  // atualiza dados (só os necessários)
  _patch() async {
    Post post = Post(120, 0, "Titulo", "Corpo da postagem",);

    var corpo = json.encode(post.toJson());

    http.Response response = await http.patch(Uri.parse(_urlBase + "/posts/2"),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: corpo);

    print("resposta: ${response.statusCode}");
    print("resposta: ${response.body}");
  }

  // deleta
  _delete() async {
    http.Response response =
        await http.delete(Uri.parse(_urlBase + "/posts/2"));

    if (response.statusCode == 200) {
      //sucesso
    } else {}

    print("resposta: ${response.statusCode}");
    print("resposta: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço avançado"),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                RaisedButton(child: Text("Salvar"), onPressed: _post),
                RaisedButton(child: Text("Atualizar"), onPressed: _patch),
                RaisedButton(child: Text("Deletar"), onPressed: _delete),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Post>>(
                future: _recuperarPostagens(),

                // snapshot: você trata praticamente o que quiser durante a requisição
                builder: (context, snapshot) {
                  var retorno;

                  switch (snapshot.connectionState) {
                    // aguardando conexão
                    case ConnectionState.waiting:
                      // icone de carregamento (CircularProgressIndicator)
                      retorno = Center(child: CircularProgressIndicator());
                      break;

                    // requisição concluída
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        print("Erro");
                      } else {
                        //recuperar os dados (snapshot.data)
                        retorno = ListView.builder(
                            itemCount: snapshot.data?.length,
                            // index vamos usar para recuperar os dados
                            itemBuilder: (context, index) {
                              List<Post>? lista = snapshot.data;
                              Post post = lista![index];
                              // esboçando a lista que recebe o objeto post
                              return ListTile(
                                title: Text(post.title),
                                subtitle: Text(post.id.toString()),
                              );
                            });
                      }
                      break;

                    // mais utilizado em serviços de streaming
                    case ConnectionState.active:
                      break;
                    case ConnectionState.none:
                      // ignore: todo
                      // TODO: Handle this case.
                      break;
                  }

                  return retorno;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
