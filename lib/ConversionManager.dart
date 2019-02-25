import 'package:converter_pro/ConversionPage.dart';
import 'package:converter_pro/Localization.dart';
import 'package:converter_pro/ReorderPage.dart';
import 'package:converter_pro/SettingsPage.dart';
import 'package:converter_pro/Utils.dart';
import 'package:converter_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

bool isCurrencyLoading=true;

class ConversionManager extends StatefulWidget{
  @override
  _ConversionManager createState() => new _ConversionManager();

}

class _ConversionManager extends State<ConversionManager>{

  static final MAX_CONVERSION_UNITS=17;
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static final List<String> currencyList=["EUR","GBP","INR","CNY","JPY","CHF","SEK","RUB","CAD","KRW","BRL","BTC"];
  static List<double> currencyValue=[0.880365,0.774845,71.362395,6.807703,109.429042,0.99706,9.02914,66.466703,1.33225,1131.44981,3.75085,0.00028]; //aggiornato al 22/01/2019
  static String lastUpdateCurrency="Last update: 22/01/2019";
  static List listaConversioni;
  static List listaColori=[Colors.red,Colors.deepOrange,Colors.amber,Colors.cyan, Colors.indigo,
  Colors.purple,Colors.blueGrey,Colors.green,Colors.pinkAccent,Colors.teal,
  Colors.blue, Colors.yellow.shade700, Colors.brown, Colors.lightGreenAccent, Colors.deepPurple,
  Colors.lightBlue, Colors.lime];
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List listaTitoli;
  static int _currentPage=0;
  static List orderLunghezza=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
  static List orderSuperficie=[0,1,2,3,4,5,6,7,8,9,10];
  static List orderVolume=[0,1,2,3,4,5,6,7,8,9,10,11,12,13];
  static List orderTempo=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14];
  static List orderTemperatura=[0,1,2];
  static List orderVelocita=[0,1,2,3,4];
  static List orderPrefissi=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
  static List orderMassa=[0,1,2,3,4,5,6,7,8,9];
  static List orderPressione=[0,1,2,3,4,5];
  static List orderEnergia=[0,1,2,3];
  static List orderAngoli=[0,1,2,3];
  static List orderValute=[0,1,2,3,4,5,6,7,8,9,10,11,12];
  static List orderScarpe=[0,1,2,3,4,5,6,7,8,9];
  static List orderDati=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26];
  static List orderPotenza=[0,1,2,3,4,5,6];
  static List orderForza=[0,1,2,3,4];
  static List orderTorque=[0,1,2,3,4];
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List listaOrder=[orderLunghezza,orderSuperficie, orderVolume,orderTempo,orderTemperatura,orderVelocita,orderPrefissi,orderMassa,orderPressione,orderEnergia,
  orderAngoli, orderValute, orderScarpe, orderDati, orderPotenza, orderForza, orderTorque];
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List<Widget> listaDrawer=new List(MAX_CONVERSION_UNITS+2);//+2 perchè c'è l'intestazione con il logo e lo spazio finale
  static List<int> listaOrderDrawer=[0,1,2,4,5,6,16,7,10,11,13,3,14,15,12,8,9]; //fino a maxconversionunits-1
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  @override
  void initState() {
    super.initState();
    _getOrders();
    _getCurrency();
  }


  _getCurrency() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    String now = DateFormat("dd/MM/yyyy").format(DateTime.now());
    if(prefs.getString("lastCurrencyUpdate")!=now){                   //se non aggiorno la lista da piú di un giorno allora aggiorno
      bool allResponsePassed=true;
      for(int i=0;i<currencyList.length;i+=2){
        try{
          final response =await http.get('https://free.currencyconverterapi.com/api/v6/convert?q=USD_${currencyList[i]},USD_${currencyList[i+1]}');
          if (response.statusCode == 200) { //if successful
            int index=response.body.indexOf("val")+5;
            String stringaTagliata=response.body.substring(index);
            currencyValue[i]=double.parse(stringaTagliata.split(",")[0]);
            index=stringaTagliata.indexOf("val")+5;
            currencyValue[i+1]=double.parse(stringaTagliata.substring(index).split(",")[0]);
          }
          else{
            allResponsePassed=false;
            //leggi ultimi dati salvati
            List<String> currencyListRead=prefs.getStringList("currencyList");
            currencyValue[i]=double.parse(currencyListRead[i]);
            currencyValue[i+1]=double.parse(currencyListRead[i+1]);
          }
        }catch(e){
          print(e);
          allResponsePassed=false;
          //leggi ultimi dati salvati
          List<String> currencyListRead=prefs.getStringList("currencyList");
          if(currencyListRead!=null){
            currencyValue[i]=double.parse(currencyListRead[i]);
            currencyValue[i+1]=double.parse(currencyListRead[i+1]);
          }
        }
      }
      //se tutte le richieste vanno a buon fine aggiorna la data di ultimo aggiornamento
      if(allResponsePassed){ //aggiorna la data di ultimo aggiornamento
        prefs.setString("lastCurrencyUpdate", now);
        lastUpdateCurrency=MyLocalizations.of(context).trans('ultimo_update_valute')+MyLocalizations.of(context).trans('oggi');
      }
      else{
        String lastUpdateRead=prefs.getString("lastCurrencyUpdate");
        if(lastUpdateRead!=null){
          lastUpdateCurrency=MyLocalizations.of(context).trans('ultimo_update_valute')+lastUpdateRead;
        }
          
      }
      //salvataggio in memoria
      List<String> toSaveList=new List(currencyValue.length);
      for(int i=0;i<currencyValue.length;i++){
        toSaveList[i]=currencyValue[i].toString();
      }
      prefs.setStringList("currencyList", toSaveList);
    }
    else{                                                             //se la lista è aggiornata a oggi allora la leggo dall'ultimo aggiornamento
      List<String> currencyListRead=prefs.getStringList("currencyList");
      lastUpdateCurrency=MyLocalizations.of(context).trans('ultimo_update_valute')+MyLocalizations.of(context).trans('oggi');
      for(int i=0; i<currencyListRead.length; i++){
        currencyValue[i]=double.parse(currencyListRead[i]);
      }
      print("lette dall'ultimo aggiornamento");
    }
    setState(() {
      isCurrencyLoading=false;
    });
  }

  void initializeTiles(){
    listaDrawer[0]=(Stack(
      children: <Widget>[
        DrawerHeader(
          child: Container(
              child:SvgPicture.asset("resources/images/logo.svg",),
          ),
          decoration: BoxDecoration(color: listaColori[_currentPage],),
        ),
        Container(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.reorder,color: Colors.white,),
                onPressed:(){
                  _changeOrderDrawer(context, MyLocalizations.of(context).trans('mio_ordinamento'), listaColori[_currentPage]);
                }
              ),
              IconButton(
                icon:Icon(Icons.settings,color: Colors.white,),
                onPressed: (){
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
          height: 190.0,
          alignment: FractionalOffset.bottomRight,
        )

      ],
      fit: StackFit.passthrough,
    ));
    listaDrawer[listaOrderDrawer[0]+1]=ListTileConversion(listaTitoli[0],"resources/images/lunghezza.svg",listaColori[0],_currentPage==0,(){_onSelectItem(0);});
    listaDrawer[listaOrderDrawer[1]+1]=ListTileConversion(listaTitoli[1],"resources/images/area.svg",listaColori[1],_currentPage==1,(){_onSelectItem(1);});
    listaDrawer[listaOrderDrawer[2]+1]=ListTileConversion(listaTitoli[2],"resources/images/volume.svg",listaColori[2],_currentPage==2,(){_onSelectItem(2);});
    listaDrawer[listaOrderDrawer[3]+1]=ListTileConversion(listaTitoli[3],"resources/images/tempo.svg",listaColori[3],_currentPage==3,(){_onSelectItem(3);});
    listaDrawer[listaOrderDrawer[4]+1]=ListTileConversion(listaTitoli[4],"resources/images/temperatura.svg",listaColori[4],_currentPage==4,(){_onSelectItem(4);});
    listaDrawer[listaOrderDrawer[5]+1]=ListTileConversion(listaTitoli[5],"resources/images/velocita.svg",listaColori[5],_currentPage==5,(){_onSelectItem(5);});
    listaDrawer[listaOrderDrawer[6]+1]=ListTileConversion(listaTitoli[6],"resources/images/prefissi.svg",listaColori[6],_currentPage==6,(){_onSelectItem(6);});
    listaDrawer[listaOrderDrawer[7]+1]=ListTileConversion(listaTitoli[7],"resources/images/massa.svg",listaColori[7],_currentPage==7,(){_onSelectItem(7);});
    listaDrawer[listaOrderDrawer[8]+1]=ListTileConversion(listaTitoli[8],"resources/images/pressione.svg",listaColori[8],_currentPage==8,(){_onSelectItem(8);});
    listaDrawer[listaOrderDrawer[9]+1]=ListTileConversion(listaTitoli[9],"resources/images/energia.svg",listaColori[9],_currentPage==9,(){_onSelectItem(9);});
    listaDrawer[listaOrderDrawer[10]+1]=ListTileConversion(listaTitoli[10],"resources/images/angoli.svg",listaColori[10],_currentPage==10,(){_onSelectItem(10);});
    listaDrawer[listaOrderDrawer[11]+1]=ListTileConversion(listaTitoli[11],"resources/images/valuta.svg",listaColori[11],_currentPage==11,(){_onSelectItem(11);});
    listaDrawer[listaOrderDrawer[12]+1]=ListTileConversion(listaTitoli[12],"resources/images/scarpe.svg",listaColori[12],_currentPage==12,(){_onSelectItem(12);});
    listaDrawer[listaOrderDrawer[13]+1]=ListTileConversion(listaTitoli[13],"resources/images/dati.svg",listaColori[13],_currentPage==13,(){_onSelectItem(13);});
    listaDrawer[listaOrderDrawer[14]+1]=ListTileConversion(listaTitoli[14],"resources/images/potenza.svg",listaColori[14],_currentPage==14,(){_onSelectItem(14);});
    listaDrawer[listaOrderDrawer[15]+1]=ListTileConversion(listaTitoli[15],"resources/images/forza.svg",listaColori[15],_currentPage==15,(){_onSelectItem(15);});
    listaDrawer[listaOrderDrawer[16]+1]=ListTileConversion(listaTitoli[16],"resources/images/torque.svg",listaColori[16],_currentPage==16,(){_onSelectItem(16);});
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    listaDrawer[MAX_CONVERSION_UNITS+1]=SizedBox(height: AD_SIZE,);
  }

  _onSelectItem(int index) {
    if(_currentPage!=index) {
      setState(() {
        _currentPage = index;
        Navigator.of(context).pop();
      });
    }
  }


  _saveOrders() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> toConvertList=new List();
    for(int item in listaOrder[_currentPage])
      toConvertList.add(item.toString());
    prefs.setStringList("conversion_$_currentPage", toConvertList);
  }
  _getOrders() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();

    //aggiorno lista del drawer
    List <String> stringList=prefs.getStringList("orderDrawer");
    setState((){
      if(stringList!=null){
        final int len=stringList.length;
        for(int i=0;i<len;i++){
          listaOrderDrawer[i]=int.parse(stringList[i]);
          if(listaOrderDrawer[i]==0)
             _currentPage=i;
        }
        //risolve il problema di aggiunta di unità dopo un aggiornamento
        for(int i=len;i<MAX_CONVERSION_UNITS;i++){
          listaOrderDrawer[i]=i;
        }
      }
    });


    //aggiorno ordine unità di ogni grandezza fisica
    for(int i=0;i<MAX_CONVERSION_UNITS;i++){
      stringList=prefs.getStringList("conversion_$i");

      if(stringList!=null){
        final int len=stringList.length;
        List intList=new List();
        for(int j=0;j<len;j++){
          intList.add(int.parse(stringList[j]));
        }
        //risolve il problema di aggiunta di unità dopo un aggiornamento
        for(int j=len; j<listaOrder[i].length;j++)     
          intList.add(j);
        
        if(i==_currentPage){
          setState(() {
            listaOrder[i]=intList;
          });
        }
        else
          listaOrder[i]=intList;

      }
    }
  }

  _changeOrderDrawer(BuildContext context,String title, Color color) async{

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    Navigator.of(context).pop();

    List orderedList=new List(MAX_CONVERSION_UNITS);
    for(int i=0;i<MAX_CONVERSION_UNITS;i++){
      orderedList[listaOrderDrawer[i]]=listaTitoli[i];
    }


    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReorderPage(
            title: title,
            listaElementi: orderedList,
            color:color
        ),));

    List arrayCopia=new List(listaOrderDrawer.length);
    for(int i=0;i<listaOrderDrawer.length;i++)
      arrayCopia[i]=listaOrderDrawer[i];
    setState(() {
      for(int i=0;i<listaOrderDrawer.length;i++)
        listaOrderDrawer[i]=result.indexOf(arrayCopia[i]);
    });

    List<String> toConvertList=new List();
    for(int item in listaOrderDrawer)
      toConvertList.add(item.toString());
    prefs.setStringList("orderDrawer", toConvertList);

  }

  _changeOrderUnita(BuildContext context,String title, List listaStringhe, Color color) async{
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReorderPage(
            title: title,
            listaElementi: listaStringhe,
            color:color
        ),));
    List arrayCopia=new List(listaOrder[_currentPage].length);
    for(int i=0;i<listaOrder[_currentPage].length;i++)
      arrayCopia[i]=listaOrder[_currentPage][i];
    setState(() {
      for(int i=0;i<listaOrder[_currentPage].length;i++)
        listaOrder[_currentPage][i]=result.indexOf(arrayCopia[i]);
    });
    _saveOrders();
  }


  @override
  Widget build(BuildContext context) {

    Node metro=Node(name: MyLocalizations.of(context).trans('metro',),order: listaOrder[0][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('centimetro'),order: listaOrder[0][1], leafNodes: [
            Node(isMultiplication: true, coefficientPer: 2.54, name: MyLocalizations.of(context).trans('pollice'),order: listaOrder[0][2], leafNodes: [
              Node(isMultiplication: true, coefficientPer: 12.0, name: MyLocalizations.of(context).trans('piede'),order: listaOrder[0][3]),
            ]),
          ]),
          Node(isMultiplication: true, coefficientPer: 1852.0, name: MyLocalizations.of(context).trans('miglio_marino'),order: listaOrder[0][4],),
          Node(isMultiplication: true, coefficientPer: 0.9144, name: MyLocalizations.of(context).trans('yard'),order: listaOrder[0][5], leafNodes: [
            Node(isMultiplication: true, coefficientPer: 1760.0, name: MyLocalizations.of(context).trans('miglio_terrestre'),order: listaOrder[0][6],),
          ]),
          Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millimetro'),order: listaOrder[0][7],),
          Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('micrometro'), order: listaOrder[0][8],),
          Node(isMultiplication: false, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('nanometro'),order: listaOrder[0][9],),
          Node(isMultiplication: false, coefficientPer: 10000000000.0, name: MyLocalizations.of(context).trans('angstrom'),order: listaOrder[0][10],),
          Node(isMultiplication: false, coefficientPer: 1000000000000.0, name: MyLocalizations.of(context).trans('picometro'),order: listaOrder[0][11],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('chilometro'),order: listaOrder[0][12],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 149597870.7, name: MyLocalizations.of(context).trans('unita_astronomica'),order: listaOrder[0][13],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 63241.1, name: MyLocalizations.of(context).trans('anno_luce'),order: listaOrder[0][14],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 3.26, name: MyLocalizations.of(context).trans('parsec'),order: listaOrder[0][15],),
              ]),
            ]),
          ]),
        ]);

    Node metroq=Node(name: MyLocalizations.of(context).trans('metro_quadrato'),order: listaOrder[1][0],leafNodes: [
      Node(isMultiplication: false, coefficientPer: 10000.0, name: MyLocalizations.of(context).trans('centimetro_quadrato'),order: listaOrder[1][1], leafNodes: [
        Node(isMultiplication: true, coefficientPer: 6.4516, name: MyLocalizations.of(context).trans('pollice_quadrato'),order: listaOrder[1][2], leafNodes: [
          Node(isMultiplication: true, coefficientPer: 144.0, name: MyLocalizations.of(context).trans('piede_quadrato'),order: listaOrder[1][3]),
        ]),
      ]),
      Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('millimetro_quadrato'),order: listaOrder[1][4],),
      Node(isMultiplication: true, coefficientPer: 10000.0, name: MyLocalizations.of(context).trans('ettaro'),order: listaOrder[1][5],),
      Node(isMultiplication: true, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('chilometro_quadrato'),order: listaOrder[1][6],),
      Node(isMultiplication: true, coefficientPer: 0.83612736, name: MyLocalizations.of(context).trans('yard_quadrato'),order: listaOrder[1][7], leafNodes: [
        Node(isMultiplication: true, coefficientPer: 3097600.0, name: MyLocalizations.of(context).trans('miglio_quadrato'),order: listaOrder[1][8]),
        Node(isMultiplication: true, coefficientPer: 4840.0, name: MyLocalizations.of(context).trans('acri'),order: listaOrder[1][9],),
      ]),
      Node(isMultiplication: true, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('ara'),order: listaOrder[1][10],),
    ]);

    Node metroc=Node(name: MyLocalizations.of(context).trans('metro_cubo'),order: listaOrder[2][0],leafNodes: [
      Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('litro'),order: listaOrder[2][1],leafNodes: [
        Node(isMultiplication: true, coefficientPer: 4.54609, name: MyLocalizations.of(context).trans('gallone_imperiale'),order: listaOrder[2][2],),
        Node(isMultiplication: true, coefficientPer: 3.785411784, name: MyLocalizations.of(context).trans('gallone_us'),order: listaOrder[2][3],),
        Node(isMultiplication: true, coefficientPer: 0.56826125, name: MyLocalizations.of(context).trans('pinta_imperiale'),order: listaOrder[2][4],),
        Node(isMultiplication: true, coefficientPer: 0.473176473, name: MyLocalizations.of(context).trans('pinta_us'),order: listaOrder[2][5],),
        Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millilitro'),order: listaOrder[2][6], leafNodes: [
          Node(isMultiplication: true, coefficientPer: 14.8, name: MyLocalizations.of(context).trans('tablespoon_us'),order: listaOrder[2][7],),
          Node(isMultiplication: true, coefficientPer: 20.0, name: MyLocalizations.of(context).trans('tablespoon_australian'),order:listaOrder[2][8],),
          Node(isMultiplication: true, coefficientPer: 240.0, name: MyLocalizations.of(context).trans('cup_us'),order: listaOrder[2][9],),
        ]),
      ]),
      Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('centimetro_cubo'),order: listaOrder[2][10], leafNodes: [
        Node(isMultiplication: true, coefficientPer: 16.387064, name: MyLocalizations.of(context).trans('pollice_cubo'),order: listaOrder[2][11], leafNodes: [
          Node(isMultiplication: true, coefficientPer: 1728.0, name: MyLocalizations.of(context).trans('piede_cubo'),order: listaOrder[2][12],),
        ]),
      ]),
      Node(isMultiplication: false, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('millimetro_cubo'),order: listaOrder[2][13],),
    ]);

    Node secondo=Node(name: MyLocalizations.of(context).trans('secondo'),order: listaOrder[3][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 10.0, name: MyLocalizations.of(context).trans('decimo_secondo'),order: listaOrder[3][1],),
          Node(isMultiplication: false, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('centesimo_secondo'), order: listaOrder[3][2],),
          Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millisecondo'),order: listaOrder[3][3],),
          Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('microsecondo'),order: listaOrder[3][4],),
          Node(isMultiplication: false, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('nanosecondo'),order: listaOrder[3][5],),
          Node(isMultiplication: true, coefficientPer: 60.0, name: MyLocalizations.of(context).trans('minuti'),order: listaOrder[3][6],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 60.0, name: MyLocalizations.of(context).trans('ore'),order: listaOrder[3][7],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 24.0, name: MyLocalizations.of(context).trans('giorni'),order: listaOrder[3][8],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 7.0, name: MyLocalizations.of(context).trans('settimane'),order: listaOrder[3][9],),
                Node(isMultiplication: true, coefficientPer: 365.0, name: MyLocalizations.of(context).trans('anno'),order: listaOrder[3][10],leafNodes: [
                  Node(isMultiplication: true, coefficientPer: 5.0, name: MyLocalizations.of(context).trans('lustro'),order: listaOrder[3][11],),
                  Node(isMultiplication: true, coefficientPer: 10.0, name: MyLocalizations.of(context).trans('decade'),order: listaOrder[3][12],),
                  Node(isMultiplication: true, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('secolo'),order: listaOrder[3][13],),
                  Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millennio'),order: listaOrder[3][14],),
                ]),
              ]),
            ]),
          ]),
        ]);

    Node celsius=Node(name: MyLocalizations.of(context).trans('fahrenheit'),order: listaOrder[4][0],leafNodes:[
      Node(isMultiplication: true, coefficientPer: 1.8, isSum: true, coefficientPlus: 32.0, name: MyLocalizations.of(context).trans('celsius'),order: listaOrder[4][1],leafNodes: [
        Node(isSum: false, coefficientPlus: 273.15, name: MyLocalizations.of(context).trans('kelvin'),order: listaOrder[4][2],),
      ]),
    ]);

    Node metri_secondo=Node(name: MyLocalizations.of(context).trans('metri_secondo'), order: listaOrder[5][0], leafNodes: [
      Node(isMultiplication: false, coefficientPer: 3.6, name: MyLocalizations.of(context).trans('chilometri_ora'),order: listaOrder[5][1], leafNodes:[
        Node(isMultiplication: true, coefficientPer: 1.609344, name: MyLocalizations.of(context).trans('miglia_ora'),order: listaOrder[5][2],),
        Node(isMultiplication: true, coefficientPer: 1.852, name: MyLocalizations.of(context).trans('nodi'),order: listaOrder[5][3],),
      ]),
      Node(isMultiplication: true, coefficientPer: 0.3048, name: MyLocalizations.of(context).trans('piedi_secondo'),order: listaOrder[5][4],),
    ]);

    Node SI=Node(name: "Base [10º]",order: listaOrder[6][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 10.0, name: "Deca [da][10¹]",order: listaOrder[6][1],),
          Node(isMultiplication: true, coefficientPer: 100.0, name: "Hecto [h][10²]",order: listaOrder[6][2],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: "Kilo [k][10³]",order: listaOrder[6][3],),
          Node(isMultiplication: true, coefficientPer: 1000000.0, name: "Mega [M][10⁶]",order: listaOrder[6][4],),
          Node(isMultiplication: true, coefficientPer: 1000000000.0, name: "Giga [G][10⁹]",order: listaOrder[6][5],),
          Node(isMultiplication: true, coefficientPer: 1000000000000.0, name: "Tera [T][10¹²]",order: listaOrder[6][6],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000.0, name: "Peta [P][10¹⁵]",order: listaOrder[6][7],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000.0, name: "Exa [E][10¹⁸]",order: listaOrder[6][8],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000000.0, name: "Zetta [Z][10²¹]",order: listaOrder[6][9],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000000000.0, name: "Yotta [Y][10²⁴]",order: listaOrder[6][10],),
          Node(isMultiplication: false, coefficientPer: 10.0, name: "Deci [d][10⁻¹]",order: listaOrder[6][11],),
          Node(isMultiplication: false, coefficientPer: 100.0, name: "Centi [c][10⁻²]",order: listaOrder[6][12],),
          Node(isMultiplication: false, coefficientPer: 1000.0, name: "Milli [m][10⁻³]",order: listaOrder[6][13],),
          Node(isMultiplication: false, coefficientPer: 1000000.0, name: "Micro [µ][10⁻⁶]",order: listaOrder[6][14],),
          Node(isMultiplication: false, coefficientPer: 1000000000.0, name: "Nano [n][10⁻⁹]",order: listaOrder[6][15],),
          Node(isMultiplication: false, coefficientPer: 1000000000000.0, name: "Pico [p][10⁻¹²]",order: listaOrder[6][16],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000.0, name: "Femto [f][10⁻¹⁵]",order: listaOrder[6][17],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000000.0, name: "Atto  [a][10⁻¹⁸]",order: listaOrder[6][18],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000000000.0, name: "Zepto [z][10⁻²¹]",order: listaOrder[6][19],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000000000000.0, name: "Yocto [y][10⁻²⁴]",order: listaOrder[6][20],),
        ]
    );

    Node grammo=Node(name: MyLocalizations.of(context).trans('grammo'),order: listaOrder[7][0],
      leafNodes: [
      Node(isMultiplication: true, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('ettogrammo'),order: listaOrder[7][1],),
      Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('chilogrammo'),order: listaOrder[7][2],leafNodes:[
        Node(isMultiplication: true, coefficientPer: 0.45359237, name: MyLocalizations.of(context).trans('libbra'),order: listaOrder[7][3],leafNodes: [
          Node(isMultiplication: false, coefficientPer: 16.0, name: MyLocalizations.of(context).trans('oncia'),order: listaOrder[7][4],)
        ]),
      ]),
      Node(isMultiplication: true, coefficientPer: 100000.0, name: MyLocalizations.of(context).trans('quintale'),order: listaOrder[7][5],),
      Node(isMultiplication: true, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('tonnellata'),order: listaOrder[7][6],),
      Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('milligrammo'),order: listaOrder[7][7],),
      Node(isMultiplication: true, coefficientPer: 1.660539e-24, name: MyLocalizations.of(context).trans('uma'),order: listaOrder[7][8],),
      Node(isMultiplication: true, coefficientPer: 0.2, name: MyLocalizations.of(context).trans('carato'),order: listaOrder[7][9],),
    ]);

    Node pascal=Node(name: MyLocalizations.of(context).trans('pascal'),order: listaOrder[8][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 101325.0, name: MyLocalizations.of(context).trans('atmosfere'),order: listaOrder[8][1],leafNodes:[
            Node(isMultiplication: true, coefficientPer: 0.987, name: MyLocalizations.of(context).trans('bar'),order: listaOrder[8][2],leafNodes:[
              Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millibar'),order: listaOrder[8][3],),
            ]),
          ]),
          Node(isMultiplication: true, coefficientPer: 6894.757293168, name: MyLocalizations.of(context).trans('psi'),order: listaOrder[8][4],),
          Node(isMultiplication: true, coefficientPer: 133.322368421, name: MyLocalizations.of(context).trans('torr'),order: listaOrder[8][5],),
    ]);

    Node joule=Node(name: MyLocalizations.of(context).trans('joule'),order: listaOrder[9][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 4.1867999409, name: MyLocalizations.of(context).trans('calorie'),order: listaOrder[9][1]),
          Node(isMultiplication: true, coefficientPer: 3600000.0, name: MyLocalizations.of(context).trans('kilowattora'),order: listaOrder[9][2],),
          Node(isMultiplication: true, coefficientPer: 1.60217646e-19, name: MyLocalizations.of(context).trans('elettronvolt'),order: listaOrder[9][3],),
        ]);
    Node gradi=Node(name:MyLocalizations.of(context).trans('gradi'),order: listaOrder[10][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 60.0, name: MyLocalizations.of(context).trans('primi'),order: listaOrder[10][1]),
          Node(isMultiplication: false, coefficientPer: 3600.0, name: MyLocalizations.of(context).trans('secondi'),order: listaOrder[10][2]),
          Node(isMultiplication: true, coefficientPer: 57.295779513, name: MyLocalizations.of(context).trans('radianti'),order: listaOrder[10][3]),
    ]);

    Node USD=Node(name:MyLocalizations.of(context).trans('USD',),order: listaOrder[11][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: currencyValue[0], name: MyLocalizations.of(context).trans('EUR'),order: listaOrder[11][1]),
          Node(isMultiplication: false, coefficientPer: currencyValue[1], name: MyLocalizations.of(context).trans('GBP'),order: listaOrder[11][2]),
          Node(isMultiplication: false, coefficientPer: currencyValue[2], name: MyLocalizations.of(context).trans('INR'),order: listaOrder[11][3]),
          Node(isMultiplication: false, coefficientPer: currencyValue[3], name: MyLocalizations.of(context).trans('CNY'),order: listaOrder[11][4]),
          Node(isMultiplication: false, coefficientPer: currencyValue[4], name: MyLocalizations.of(context).trans('JPY'),order: listaOrder[11][5]),
          Node(isMultiplication: false, coefficientPer: currencyValue[5], name: MyLocalizations.of(context).trans('CHF'),order: listaOrder[11][6]),
          Node(isMultiplication: false, coefficientPer: currencyValue[6], name: MyLocalizations.of(context).trans('SEK'),order: listaOrder[11][7]),
          Node(isMultiplication: false, coefficientPer: currencyValue[7], name: MyLocalizations.of(context).trans('RUB'),order: listaOrder[11][8]),
          Node(isMultiplication: false, coefficientPer: currencyValue[8], name: MyLocalizations.of(context).trans('CAD'),order: listaOrder[11][9]),
          Node(isMultiplication: false, coefficientPer: currencyValue[9], name: MyLocalizations.of(context).trans('KRW'),order: listaOrder[11][10]),
          Node(isMultiplication: false, coefficientPer: currencyValue[10], name: MyLocalizations.of(context).trans('BRL'),order: listaOrder[11][11]),
          Node(isMultiplication: false, coefficientPer: currencyValue[11], name: MyLocalizations.of(context).trans('BTC'),order: listaOrder[11][12]),
    ]);

    Node centimetri_scarpe=Node(name:MyLocalizations.of(context).trans('centimetro',),order: listaOrder[12][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 1.5, coefficientPlus: 1.5, isSum: false, name: MyLocalizations.of(context).trans('eu_cina'),order: listaOrder[12][1]),
          Node(isMultiplication: true, coefficientPer: 2.54, name: MyLocalizations.of(context).trans('pollice'),order: listaOrder[12][2], 
          leafNodes: [
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 4, isSum: true, name: MyLocalizations.of(context).trans('uk_india_bambino'),order: listaOrder[12][3]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 8.3333333, name: MyLocalizations.of(context).trans('uk_india_uomo'),order: listaOrder[12][4]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 8.5, name: MyLocalizations.of(context).trans('uk_india_donna'),order: listaOrder[12][5]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 3.89, isSum: true, name: MyLocalizations.of(context).trans('usa_canada_bambino'),order: listaOrder[12][6]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 8.0, name: MyLocalizations.of(context).trans('usa_canada_uomo'),order: listaOrder[12][7]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 7.5, name: MyLocalizations.of(context).trans('usa_canada_donna'),order: listaOrder[12][8]),
          ]),
          Node(coefficientPlus: 1.5, isSum: false, name: MyLocalizations.of(context).trans('giappone'),order: listaOrder[12][9]),
          
    ]);

    Node bit=Node(name: "Bit [b]",order: listaOrder[13][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 4.0, name: "Nibble",order: listaOrder[13][2],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: "Kilobit [kb]",order: listaOrder[13][3],),
          Node(isMultiplication: true, coefficientPer: 1000000.0, name: "Megabit [Mb]",order: listaOrder[13][7],),
          Node(isMultiplication: true, coefficientPer: 1000000000.0, name: "Gigabit [Gb]",order: listaOrder[13][11],),
          Node(isMultiplication: true, coefficientPer: 1000000000000.0, name: "Terabit [Tb]",order: listaOrder[13][15],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000.0, name: "Petabit [Pb]",order: listaOrder[13][19],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000.0, name: "Exabit [Eb]",order: listaOrder[13][23],),
          Node(isMultiplication: true, coefficientPer: 1024.0, name: "Kibibit [Kibit]",order: listaOrder[13][5],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 1024.0, name: "Mebibit [Mibit]",order: listaOrder[13][9],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 1024.0, name: "Gibibit [Gibit]",order: listaOrder[13][13],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 1024.0, name: "Tebibit [Tibit]",order: listaOrder[13][17],leafNodes: [
                  Node(isMultiplication: true, coefficientPer: 1024.0, name: "Pebibit [Pibit]",order: listaOrder[13][21],leafNodes: [
                    Node(isMultiplication: true, coefficientPer: 1024.0, name: "Exbibit [Eibit]",order: listaOrder[13][25])
                  ])
                ])
              ])
            ])
          ]),
          Node(isMultiplication: true, coefficientPer: 8.0, name: "Byte [B]",order: listaOrder[13][1],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 1000.0, name: "Kilobyte [kB]",order: listaOrder[13][4],),
            Node(isMultiplication: true, coefficientPer: 1000000.0, name: "Megabyte [MB]",order: listaOrder[13][8],),
            Node(isMultiplication: true, coefficientPer: 1000000000.0, name: "Gigabyte [GB]",order: listaOrder[13][12],),
            Node(isMultiplication: true, coefficientPer: 1000000000000.0, name: "Terabyte [TB]",order: listaOrder[13][16],),
            Node(isMultiplication: true, coefficientPer: 1000000000000000.0, name: "Petabyte [PB]",order: listaOrder[13][20],),
            Node(isMultiplication: true, coefficientPer: 1000000000000000000.0, name: "Exabyte [EB]",order: listaOrder[13][24],),
            Node(isMultiplication: true, coefficientPer: 1024.0, name: "Kibibyte [KiB]",order: listaOrder[13][6],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 1024.0, name: "Mebibyte [MiB]",order: listaOrder[13][10],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 1024.0, name: "Gibibyte [GiB]",order: listaOrder[13][14],leafNodes: [
                  Node(isMultiplication: true, coefficientPer: 1024.0, name: "Tebibyte [TiB]",order: listaOrder[13][18],leafNodes: [
                    Node(isMultiplication: true, coefficientPer: 1024.0, name: "Pebibyte [PiB]",order: listaOrder[13][22],leafNodes: [
                      Node(isMultiplication: true, coefficientPer: 1024.0, name: "Exbibyte [EiB]",order: listaOrder[13][26])
                    ])
                  ])
                ])
              ])
            ]),
          ]),
        ]
    );

    Node watt=Node(name: MyLocalizations.of(context).trans('watt'),order: listaOrder[14][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('milliwatt'),order: listaOrder[14][1],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('kilowatt'),order: listaOrder[14][2],),
          Node(isMultiplication: true, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('megawatt'),order: listaOrder[14][3],),
          Node(isMultiplication: true, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('gigawatt'),order: listaOrder[14][4],),
          Node(isMultiplication: true, coefficientPer: 735.49875, name: MyLocalizations.of(context).trans('cavallo_vapore_eurpeo'),order: listaOrder[14][5],),
          Node(isMultiplication: true, coefficientPer: 745.69987158, name: MyLocalizations.of(context).trans('cavallo_vapore_imperiale'),order: listaOrder[14][6],),
    ]);

    Node newton=Node(name: MyLocalizations.of(context).trans('newton'),order: listaOrder[15][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 100000.0, name: MyLocalizations.of(context).trans('dyne'),order: listaOrder[15][1],),
          Node(isMultiplication: true, coefficientPer: 4.448222 , name: MyLocalizations.of(context).trans('libbra_forza'),order: listaOrder[15][2],),
          Node(isMultiplication: true, coefficientPer: 9.80665, name: MyLocalizations.of(context).trans('kilogrammo_forza'),order: listaOrder[15][3],),
          Node(isMultiplication: true, coefficientPer: 0.138254954376, name: MyLocalizations.of(context).trans('poundal'),order: listaOrder[15][4],),
    ]);

    Node newton_metro=Node(name: MyLocalizations.of(context).trans('newton_metro'),order: listaOrder[16][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 100000.0, name: MyLocalizations.of(context).trans('dyne_metro'),order: listaOrder[16][1],),
          Node(isMultiplication: false, coefficientPer: 0.7374631268436578 , name: MyLocalizations.of(context).trans('libbra_forza_piede'),order: listaOrder[16][2],),
          Node(isMultiplication: false, coefficientPer: 0.10196798205363515, name: MyLocalizations.of(context).trans('kilogrammo_forza_metro'),order: listaOrder[16][3],),
          Node(isMultiplication: true, coefficientPer: 0.138254954376, name: MyLocalizations.of(context).trans('poundal_metro'),order: listaOrder[16][4],),
    ]);


    listaConversioni=[metro,metroq, metroc,secondo, celsius, metri_secondo,SI,grammo,pascal,joule,gradi,USD, centimetri_scarpe,bit,watt,newton, newton_metro];
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    listaTitoli=[MyLocalizations.of(context).trans('lunghezza'),MyLocalizations.of(context).trans('superficie'),MyLocalizations.of(context).trans('volume'),
    MyLocalizations.of(context).trans('tempo'),MyLocalizations.of(context).trans('temperatura'),MyLocalizations.of(context).trans('velocita'),
    MyLocalizations.of(context).trans('prefissi_si'),MyLocalizations.of(context).trans('massa'),MyLocalizations.of(context).trans('pressione'),
    MyLocalizations.of(context).trans('energia'), MyLocalizations.of(context).trans('angoli'),MyLocalizations.of(context).trans('valuta'),
    MyLocalizations.of(context).trans('taglia_scarpe'),MyLocalizations.of(context).trans('dati_digitali'),MyLocalizations.of(context).trans('potenza'),
    MyLocalizations.of(context).trans('forza'), MyLocalizations.of(context).trans('momento')];
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    initializeTiles();

    List<Choice> choices = <Choice>[
      Choice(title: MyLocalizations.of(context).trans('riordina'), icon: Icons.reorder),
    ];
    return Scaffold(
      resizeToAvoidBottomPadding: false,  //per evitare che il fab salga quando clicco
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: listaColori[_currentPage],
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Builder(builder: (context) {
              return IconButton(icon: Icon(Icons.menu,color: Colors.white,), onPressed: () {
                Scaffold.of(context).openDrawer();
              });
            }),
            Row(children: <Widget>[
              IconButton(icon: Icon(Icons.clear,color: Colors.white,semanticLabel: 'Clear all',),
                onPressed: () {
                  setState(() {
                    listaConversioni[_currentPage].ClearAllValues();
                  });
                },),
              PopupMenuButton<Choice>(
                icon: Icon(Icons.more_vert,color: Colors.white,),
                onSelected: (Choice choice){
                  _changeOrderUnita(context, MyLocalizations.of(context).trans('mio_ordinamento'), listaConversioni[_currentPage].getStringOrderedNodiFiglio(), listaColori[_currentPage]);
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
            ],)
          ],
      ),
    ),
      drawer: new Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: listaDrawer,
      ),
      ),
      body: ConversionPage(listaConversioni[_currentPage],listaTitoli[_currentPage], _currentPage==11 ? lastUpdateCurrency : ""),
      
      floatingActionButton: FloatingActionButton(
        child: SvgPicture.asset("resources/images/calculator.svg",width: 30.0,),
        onPressed: (){
          _fabPressed();
        },
        
        elevation: 10.0,
        backgroundColor: listaColori[_currentPage],
      ),

    );
  }

  _fabPressed(){
    showModalBottomSheet<void>(context: context,
      builder: (BuildContext context) {
        double displayWidth=MediaQuery.of(context).size.width;
        return Calculator(listaColori[_currentPage], displayWidth); 
      }
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class ListTileConversion extends StatefulWidget{
  String text;
  String imagePath;
  Color color;
  bool selected;
  Function onTapFunction;
  ListTileConversion(this.text, this.imagePath, this.color, this.selected,this.onTapFunction);

  @override
  _ListTileConversion createState() => new _ListTileConversion();
} 

class _ListTileConversion extends State<ListTileConversion>{



  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      child:ListTile(
        title: Row(children: <Widget>[
          SvgPicture.asset(widget.imagePath,width: 30.0,height: 30.0, color:  widget.selected ? widget.color : (darkTheme ? Color(0xFFCCCCCC) : Colors.black54),),
          SizedBox(width: 20.0,),
          Text(widget.text)
        ],),
        selected: widget.selected,
        onTap: widget.onTapFunction
      ),
      selectedColor: widget.color,
    );
  }
}