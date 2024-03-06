import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/ClassObj/MessObj.dart';

class ViewMessageAdmin extends StatefulWidget {
  final String username;
  final List<MessObj> messages;

  const ViewMessageAdmin({Key? key, required this.username, required this.messages}) : super(key: key);

  @override
  _ViewMessageAdminState createState() => _ViewMessageAdminState();
}

class _ViewMessageAdminState extends State<ViewMessageAdmin> {
  TextEditingController textEditingController = TextEditingController();

  void sendMessage() async {
    if (textEditingController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('messages').add({
        'admin': true,
        'user': widget.username,
        'text': textEditingController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation avec ${widget.username}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('user', isEqualTo: widget.username)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var message = snapshot.data!.docs[index];
                      bool isAdmin = message['admin'];
                      return Align(
                        alignment: isAdmin ? Alignment.topLeft : Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.blue : Colors.grey,
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
