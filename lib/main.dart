import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:admob_flutter/admob_flutter.dart';
//remove admob from pubspec.yaml,then admob container and all admob related code in main.lib to test 
GoogleMapController mapController;
MapType _currentMapType = MapType.hybrid;
dynamic position;
String _latt,_longitude;  
void main() async  {
  Admob.initialize("appid");
    await assignPosition();
    runApp( 
      new MaterialApp(
      debugShowCheckedModeBanner: false,
    theme: new ThemeData(
      primarySwatch: Colors.blue
    ),
    home: new MyApp()    
  )
);
  
}
class MyApp extends StatefulWidget {

  
  MyApp();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  _MyAppState();
  @override
  Widget build(BuildContext context) {    

        Marker marker = Marker(
          markerId: MarkerId('ISSMARKER'),
          position: LatLng(double.parse(_latt),double.parse(_longitude)),
          infoWindow: InfoWindow(
            title: "ISS LOCATION",
            snippet: 'Current ISS Location',
          ),
        );
     Set<Marker> _markers = {marker};
 return Scaffold(
  appBar: new AppBar(
     backgroundColor: Colors.blue,
     title: new Text('ISS TRACKER',
     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35,color: Colors.white )
   ),),
   body:Stack(
  children: <Widget>[
    Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        print("map created");
        },
      
          
          initialCameraPosition: CameraPosition(
          target: LatLng(double.parse(_latt),double.parse(_longitude)),
          
          
          ),
  
          mapType: _currentMapType ,
          markers: _markers,
        
      ),
    ),
         Container(
           margin : EdgeInsets.only(top: 10,left: 5),
       alignment: Alignment(0, -1),
  child: AdmobBanner(

  adUnitId: "addunitid",
  adSize: AdmobBannerSize.SMART_BANNER,
  listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('Admob banner loaded!');
        break;

      case AdmobAdEvent.opened:
        print('Admob banner opened!');
        break;

      case AdmobAdEvent.closed:
        print('Admob banner closed!');
        break;

      case AdmobAdEvent.failedToLoad:
        print('Admob banner failed to load. Error code: ${args['errorCode']}');
        break;
        default :

    }
  })
    
  ),
   Card(
     color: Colors.green,
     margin: EdgeInsets.only(top: 80,left: 5),
     child: 
     Text("latt:"+_latt ,style: TextStyle(
       color: Colors.pink,fontSize: 16,fontWeight: FontWeight.bold
     ),),
   ),
   Card(
     color: Colors.green,
     margin: EdgeInsets.only(top: 110,left: 5),
     child: 
   Text("long:"+_longitude,style: TextStyle(
    color: Colors.purple,fontSize: 16 ,fontWeight: FontWeight.bold
   ),
   )),
Container(
  alignment: Alignment(1, 0),
  child:
Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children : <Widget>[
    Container(
      margin: EdgeInsets.only(right: 5 ,bottom:10),
      child:
      Builder(
        builder: (context)=>
 FloatingActionButton(onPressed: ()  {
    
 setState(()  {
   assignPosition();   
   mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(double.parse(_latt),double.parse(_longitude),),
            zoom: 5
      ),
    ));
    final snackBar = SnackBar(content: Text('refreshed'),duration: Duration(milliseconds: 500));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
Scaffold.of(context).showSnackBar(snackBar);

print(_latt + " " + _longitude);
print("\nrefresh clicked");
 });
 },
   child: new Icon(Icons.refresh))),
    ),  

   Container(
     margin: EdgeInsets.only(right: 5 ,bottom: 10),
child:

 FloatingActionButton(onPressed: ()  {
   setState(() { //map change logic
           _currentMapType = _currentMapType == MapType.normal
          ? MapType.hybrid
          : (_currentMapType == MapType.hybrid
          ? MapType.terrain:
            (_currentMapType == MapType.terrain
          ? MapType.satellite: MapType.normal));
          print(_currentMapType);
     
   });

 },
   child: new Icon(Icons.map)),
  )
  ]

  )  ),
 
  ],
  
  )
  );
    }
}






Future<dynamic> getPosition() async {
  String apiUrl = 'http://api.open-notify.org/iss-now';
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}

void assignPosition() async{
position = await getPosition();
 _latt= position['iss_position']['latitude'];
  _longitude = position['iss_position']['longitude'];
  print(_latt + " " + _longitude);
}
