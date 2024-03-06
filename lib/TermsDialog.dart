import 'package:flutter/material.dart';

class TermsDialog extends StatelessWidget {
  final VoidCallback onAccept;

  TermsDialog({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          constraints: BoxConstraints(maxHeight: 400),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "Votre texte de conditions générales et de politique de cookies ici...",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Refuser', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      onAccept();
                      Navigator.of(context).pop();
                    },
                    child: Text('Accepter', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
