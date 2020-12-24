import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextContainer extends StatefulWidget {
  final Function({String text, File imagem}) enviarMensagem;

  TextContainer(this.enviarMensagem);

  @override
  _TextContainerState createState() => _TextContainerState();
}

class _TextContainerState extends State<TextContainer> {
  @override
  bool _isComposing = false;

  final TextEditingController _controller = new TextEditingController();

  void limpar() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final File imagemFile =
                  await ImagePicker.pickImage(source: ImageSource.gallery);

              if (imagemFile == null) return;
              widget.enviarMensagem(imagem: imagemFile);
            },
          ),
          Expanded(
              child: TextField(
            controller: _controller,
            decoration:
                InputDecoration.collapsed(hintText: "Escreva uma mensagem"),
            onChanged: (text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              widget.enviarMensagem(text: text);
              limpar();
            },
          )),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.green,
            ),
            onPressed: _isComposing
                ? () {
                    widget.enviarMensagem(text: _controller.text);
                    limpar();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
