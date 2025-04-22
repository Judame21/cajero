import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _saldo = 0.0;
  final _anadirController = TextEditingController();
  final _sacarController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _userStream = _firestore.collection('users').doc(_user!.uid).snapshots();
    }
  }

  Future<void> _actualizarSaldo(double nuevoSaldo) async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).update({'saldo': nuevoSaldo});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el saldo: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoAnadir() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anadir Dinero'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Cuánto dinero deseas anadir?'),
                TextField(
                  controller: _anadirController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                _anadirController.clear();
              },
            ),
            TextButton(
              child: Text('Anadir'),
              onPressed: () {
                if (_anadirController.text.isNotEmpty) {
                  final cantidad = double.tryParse(_anadirController.text);
                  if (cantidad != null && cantidad > 0) {
                    final nuevoSaldo = _saldo + cantidad;
                    _actualizarSaldo(nuevoSaldo).then((_) {
                      Navigator.of(context).pop();
                      _anadirController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Se anadieron \$${cantidad.toStringAsFixed(2)} al saldo.')),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor, ingresa una cantidad válida mayor que 0.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, ingresa una cantidad.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoSacar() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sacar Dinero'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Cuánto dinero deseas sacar?'),
                TextField(
                  controller: _sacarController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.money_off),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                _sacarController.clear();
              },
            ),
            TextButton(
              child: Text('Sacar'),
              onPressed: () {
                if (_sacarController.text.isNotEmpty) {
                  final cantidad = double.tryParse(_sacarController.text);
                  if (cantidad != null && cantidad > 0) {
                    if (cantidad <= _saldo) {
                      final nuevoSaldo = _saldo - cantidad;
                      _actualizarSaldo(nuevoSaldo).then((_) {
                        Navigator.of(context).pop();
                        _sacarController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Se retiraron \$${cantidad.toStringAsFixed(2)} del saldo.')),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saldo insuficiente.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor, ingresa una cantidad válida mayor que 0.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, ingresa una cantidad.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cajero Automático'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData = snapshot.data!.data();
                  final userName = userData?['displayName'] as String? ?? ''; // Obtén el nombre
                  _saldo = userData?['saldo']?.toDouble() ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido, $userName', // Muestra el nombre
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Card(
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Tu Saldo',
                                style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '\$ ${_saldo.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.green[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error al cargar la información del usuario', style: TextStyle(color: Colors.red));
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Column(
                    children: [
                      Text('Bienvenido'), // Mensaje genérico si no hay datos
                      SizedBox(height: 8.0),
                      Card(
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Tu Saldo',
                                style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '\$ 0.00',
                                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _mostrarDialogoAnadir();
                    },
                    icon: Icon(Icons.add, size: 32.0),
                    label: Text('Anadir', style: TextStyle(fontSize: 18.0)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _mostrarDialogoSacar();
                    },
                    icon: Icon(Icons.remove, size: 32.0),
                    label: Text('Sacar', style: TextStyle(fontSize: 18.0)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.red[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),
              ],
            ),
            // Más funcionalidades aquí
          ],
        ),
      ),
    );
  }
}