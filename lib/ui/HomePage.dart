import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:sharegiphy/ui/gif_page.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset=0;


  Future<Map> _getGifs() async{
    http.Response response;
    if(_search == null || _search.isEmpty){
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=34J7GudNeU9QfoqfEShYa0wipkvqtla9&limit=20&rating=G");
    }else{
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=34J7GudNeU9QfoqfEShYa0wipkvqtla9&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquisar",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white,fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _offset = 0;
                  _search = text;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if(snapshot.hasError) {
                      return Container();
                    }else{
                      return _createGifTable(context,snapshot);
                    }
                }

              },
              future: _getGifs(),
            ),
          )
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index){
        if(_search==null || _search.isEmpty || snapshot.data['data'].length > index){
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']['url'],
                height: 300,
                fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GifPage(snapshot.data['data'][index])));
            },
            onLongPress: (){
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        }else{
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add,color: Colors.white,size: 70,),
                  Text("Carregar mais...",style: TextStyle(color: Colors.white, fontSize: 22),)
                ],
              ),
              onTap: (){
                setState(() {
                  _offset+=19;
                });
              },
            ),
          );
        }

      },
      padding: EdgeInsets.all(10),
    );
  }

  int _getCount(List data){
    if(_search == null || _search.isEmpty){
      return data.length;
    }else{
      return data.length+1;
    }
  }
}
