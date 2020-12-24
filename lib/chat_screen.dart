import 'dart:io';

import 'package:chat_flutter/text_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _usuarioLogado;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((usuario) {
      setState(() {
        _usuarioLogado = usuario;
      });
    });
  }

  Future<FirebaseUser> _getAuth() async {
    if (_usuarioLogado != null) return _usuarioLogado;

    try {
      final GoogleSignInAccount signInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication signInAuthentication =
          await signInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: signInAuthentication.idToken,
          accessToken: signInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void _enviarMensagem({String text, File imagem}) async {
    final FirebaseUser user = await _getAuth();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possivel fazer o login tente novamente"),
          backgroundColor: Colors.green,
        ),
      );
    }

    Map<String, dynamic> map = {
      "usuario": user.uid,
      "usuarioMensagem": user.displayName,
      "foto": user.photoUrl,
      "dataHora": Timestamp.now(),
    };

    if (imagem != null) {
      String id = FirebaseDatabase.instance.reference().push().key;
      StorageUploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("imagens")
          .child(id)
          .putFile(imagem);

      setState(() {
        _carregando = true;
      });

      StorageTaskSnapshot task = await uploadTask.onComplete;
      String url = await task.ref.getDownloadURL();
      map["urlImagem"] = url;

      setState(() {
        _carregando = false;
      });
    }

    if (text != null) map["texto"] = text;

    Firestore.instance.collection("mensagem").add(map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(_usuarioLogado != null
            ? "Olá " + _usuarioLogado.displayName
            : "GRUPO"),
        centerTitle: true,
        elevation: 5,
        actions: <Widget>[
          _usuarioLogado != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scaffoldKey.currentState.showSnackBar(
                        SnackBar(content: Text("Deslogado com sucesso!")));
                  })
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("mensagem")
                      .orderBy("dataHora")
                      .snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        List<DocumentSnapshot> lista =
                            snapshot.data.documents.reversed.toList();

                        return ListView.builder(
                            itemCount: lista.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return ChatMessage(
                                  lista[index].data,
                                  lista[index].data["uid"] ==
                                      _usuarioLogado?.uid);
                            });
                    }
                  })),
          _carregando ? LinearProgressIndicator() : Container(),
          TextContainer(_enviarMensagem),
        ],
      ),
    );
  }
}
