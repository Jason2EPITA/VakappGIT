import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class messUserView extends StatefulWidget {
  String googleEmail;
  messUserView({super.key, required this.googleEmail});
  @override
  _messUserViewState createState() => _messUserViewState();
}

class _messUserViewState extends State<messUserView> {
  final TextEditingController textEditingController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Remplacez ceci par le nom d'utilisateur réel obtenu lors de la connexion
  late String username;



  void sendMessage() async {
    if (textEditingController.text.isNotEmpty) {
      await firestore.collection('messages').add({
        'admin' : false,
        'user' : username,
        'text': textEditingController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      textEditingController.clear();
    }
  }
  @override
  void initState() {
    super.initState();
    username = widget.googleEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat avec un Admin'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('user', isEqualTo: username)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var message = snapshot.data!.docs[index];
                      bool isAdmin = message['admin']; // Vérifier si le message vient de l'admin
                      return Align(
                        alignment: isAdmin ? Alignment.topLeft : Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.grey : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message['text'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    onSubmitted: (value) => sendMessage(),
                    decoration: const InputDecoration(hintText: 'Écrivez un message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
