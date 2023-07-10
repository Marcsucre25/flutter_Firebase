import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SCROLLING INFINITE'),
        backgroundColor: const Color.fromARGB(255, 173, 146, 66),
      ),
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Para guardar en fire
  CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('notas');
  TextEditingController controller = TextEditingController();
  late String currentItem;
  late int currentEdad;
  late String currentDireccion;
  late String currentEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error al obtener los elementos');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<Map<String, dynamic>> documents = (snapshot.data?.docs ?? [])
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.separated(
            itemCount: documents.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              Map<String, dynamic> document = documents[index];

              String item = document['name'];
              //Para obtener el id de cada elemento y poder actualizar o eliminar
              String docId =
                  snapshot.data!.docs[index].id; // Obtener el ID del documento
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(item),
                  onTap: () {
                    currentItem = item;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        controller.text = currentItem;
                        return AlertDialog(
                          title: Text('Editar elemento'),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Nuevo valor',
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Guardar'),
                              onPressed: () {
                                setState(() {
                                  _updateItem(docId, controller.text);
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Eliminar elemento'),
                          content: Text(
                              '¿Estás seguro de que deseas eliminar este elemento?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Eliminar'),
                              onPressed: () {
                                setState(() {
                                  _deleteItem(docId);
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Agregar elemento'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Nombre:',
                      ),
                    ),
                    TextField(
                      onChanged: (value) =>
                          currentEdad = int.tryParse(value) ?? 0,
                      decoration: InputDecoration(
                        labelText: 'Edad:',
                      ),
                    ),
                    TextField(
                      onChanged: (value) => currentDireccion = value,
                      decoration: InputDecoration(
                        labelText: 'Dirección:',
                      ),
                    ),
                    TextField(
                      onChanged: (value) => currentEmail = value,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico:',
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Agregar'),
                    onPressed: () {
                      setState(() {
                        _addItem(
                          controller.text,
                          currentEdad,
                          currentDireccion,
                          currentEmail,
                        );
                        controller.clear();
                        currentEdad = 0;
                        currentDireccion = '';
                        currentEmail = '';
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _addItem(String value, int edad, String direccion, String email) async {
    await itemsCollection.add({
      'name': value,
      'edad': edad,
      'direccion': direccion,
      'email': email,
    });
  }

  void _updateItem(String id, String newValue) async {
    await itemsCollection.doc(id).update({
      'name': newValue,
    });
  }

  void _deleteItem(String id) async {
    await itemsCollection.doc(id).delete();
  }
}
