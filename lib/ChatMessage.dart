import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool minhaMensagem;

  ChatMessage(this.data, this.minhaMensagem);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: <Widget>[
          !minhaMensagem
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["foto"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: minhaMensagem
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                data["urlImagem"] != null
                    ? Image.network(
                        data["urlImagem"],
                        width: 200,
                      )
                    : Text(
                        data["texto"],
                        textAlign:
                            minhaMensagem ? TextAlign.end : TextAlign.start,
                        style: TextStyle(fontSize: 16.0),
                      ),
                Text(
                  data["usuarioMensagem"],
                  style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.green),
                ),
              ],
            ),
          ),
          minhaMensagem
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["foto"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
