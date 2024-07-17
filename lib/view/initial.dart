import 'package:flutter/material.dart';

class Initial extends StatefulWidget {
  const Initial({Key? key}) : super(key: key);

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Games Tracker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 99, 179, 99),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Bem-vindo ao Games Tracker!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: Color.fromARGB(255, 186, 208, 169),
              child: Text(
                'Este aplicativo permite que você acompanhe seus jogos favoritos e suas avaliações.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCard(
                  'Faça login para acessar sua conta.',
                  'Logar',
                  '/login',
                ),
                SizedBox(height: 20),
                _buildCard(
                  'Registre um novo usuário.',
                  'Cadastrar Novo Usuário',
                  '/register',
                ),
                SizedBox(height: 20),
                _buildCard(
                  'Explore como visitante sem cadastro.',
                  'Entrar',
                  '/guest',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String message, String buttonText, String route) {
    return Container(
      width: 300,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 99, 179, 99),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
