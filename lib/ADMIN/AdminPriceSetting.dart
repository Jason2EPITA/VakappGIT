import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminPriceSetting extends StatefulWidget {
  @override
  _AdminPriceSettingState createState() => _AdminPriceSettingState();
}

class _AdminPriceSettingState extends State<AdminPriceSetting> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  double? _price;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Price Setting'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Sélecteur de date de début
              ListTile(
                title: Text(_startDate == null ? 'Select Start Date' : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _startDate) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
              // Sélecteur de date de fin
              ListTile(
                title: Text(_endDate == null ? 'Select End Date' : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _endDate) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
              ),
              // Champ de prix
              TextFormField(
                decoration: InputDecoration(labelText: 'Price (€)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _price = double.tryParse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePrice,

                child: Text('Save Price'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePrice() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      CollectionReference newprice = FirebaseFirestore.instance
          .collection('priceDate');
      try {
        DocumentReference docRef = await newprice.add({
          'startDate': _startDate,
          'endDate': _endDate,
          'price': _price,
          'approved': 0
        });
      }
      catch (e) {
        print('Erreur lors de l\'ajout d\'un prix pour une plage de dates à Firestore: $e');
      }
      Navigator.of(context).pop();    }
  }
}
