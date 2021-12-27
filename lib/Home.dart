// ignore_for_file: file_names, prefer_const_constructors, prefer_final_fields, avoid_print, prefer_typing_uninitialized_variables

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço avançado"),
      ),
      body: FutureBuilder<List<Post>>(
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
              print("Conexão done");
              if (snapshot.hasError) {
                print("lista: Erro ao carregar");
              } else {
                //recuperar os dados (snapshot.data)
                print("lista: carregou");
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
    );
  }
}
