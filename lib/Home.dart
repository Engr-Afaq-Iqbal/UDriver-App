import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:u_driver/users.dart';
import 'package:url_launcher/url_launcher.dart';

import 'EditProfile/EditProfile.dart';
import 'Registration/Log_In.dart';
import 'ScheduleTimeTable/timeTable.dart';
import 'Support/support.dart';
import 'global.dart';
import 'main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool status = false;
  String routeIndex = '00';
  int shuttleIndex = 0;
  String? selectedValue;
  String markersInforWindowRoute = 'Please Select First';
  String markerBustype = 'Select First';
  Set<Marker> markersSet = {};
  BitmapDescriptor? nearByIcon;
  final List<String> items = [
    "Piran Ghaib(Boys & Girls)",
    "Mumtazabad(Boys & Girls)",
    "By Pass(Boys & Girls)",
    "Makhdom Rasheed(Boys & Girls)",
    "Bamd Bosan(Ailam Pur)(Boys & Girls)",
    "Chowk Shahidan(Boys & Girls)",
    "Basti Khudad Mill Muzafarabad",
    "Shah Ruk-ne-Alam(Boys & Girls)",
    "Seven Up Factory(Boys & Girls)",
    "Sher Shah(Boys & Girls)",
    "City Routes(Boys & Girls)",
    "Textile College",
    "Qasim Baila(Boys & Girls)",
    "Bilal Chowk(Boys & Girls)",
    "Wallayatabad(Boys & Girls)",
    "Masoom Shah Road(Boys & Girls)",
    "Darse Chawan(Boys & Girls)",
    "Adda Laar(Boys & Girls)",
    "IMs(Khuda Dad & By Pass)",
    "Kabir wala(Boys & Girls)",
  ];
  String? selectedRoutesType;

  List<String> shuttleTypesList = [
    "Shuttle 1",
    "Shuttle 2",
  ];

  getDriversData() async {
    final snapshot = await driversRef.child(currentFirebaseUser!.uid).get();
    print(snapshot.value!);
    setState(() {
      currentDriversinfo = Users.fromSnapshot(snapshot);
    });
    debugPrint(currentDriversinfo!.name);
    print(currentDriversinfo!.profile);
  }

  var geoLocator = Geolocator();
  Position? currentPosition;
  GoogleMapController? newGoogleMapController;
  Completer<GoogleMapController> _controller = Completer();

  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    List<DropdownMenuItem<String>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return _menuItems;
  }

  void locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    markersOnMap();
  }

  List<double> _getCustomItemsHeights() {
    List<double> _itemsHeights = [];
    for (var i = 0; i < (items.length * 2) - 1; i++) {
      if (i.isEven) {
        _itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        _itemsHeights.add(4);
      }
    }
    return _itemsHeights;
  }

  final auth = FirebaseAuth.instance;
  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(30.162750784907014, 71.52545420721886),
    zoom: 14.4746,
  );

  String? selectedShuttleType;
  TextEditingController routetypeTextEditingController =
      TextEditingController();
  TextEditingController busnoController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    getDriversData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: drawerMethod(context),
      ),
      appBar: AppBar(
        title: const Text("Driver App"),
        actions: [
          Container(
            child: FlutterSwitch(
              width: 80.0,
              height: 30.0,
              valueFontSize: 12.0,
              toggleSize: 45.0,
              value: status,
              borderRadius: 30.0,
              padding: 3.0,
              showOnOff: true,
              onToggle: (val) {
                setState(() {
                  status = val;
                  print(status);
                  if (status == true) {
                    print(status);
                    makeDriverOnline();
                    getLiveLocationUpdates();
                    Fluttertoast.showToast(msg: "You are Online Now");
                  } else {
                    Geofire.removeLocation(currentFirebaseUser!.uid);
                    rideRequestRef.onDisconnect();
                    rideRequestRef.remove();
                    Fluttertoast.showToast(msg: "You are Offline Now");
                  }
                });
              },
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        // customButton: const Icon(
                        //   Icons.directions_bus,
                        //   size: 30,
                        //   color: Colors.white,
                        // ),
                        isExpanded: true,
                        items: _addDividersAfterItems(items),
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            status = false;
                            Geofire.removeLocation(
                                '$routeIndex${currentFirebaseUser!.uid}');
                            rideRequestRef.onDisconnect();
                            rideRequestRef.remove();
                            selectedValue = value as String;
                            markersInforWindowRoute = selectedValue!;
                            markerBustype = 'Route';
                            print(selectedValue);
                            markersOnMap();
                            if (items.indexOf(value) <= 9) {
                              routeIndex = '0${items.indexOf(value) + 1}';
                            } else {
                              routeIndex = '${items.indexOf(value) + 1}';
                            }

                            print(routeIndex);
                          });
                        },
                        hint: Text(
                          'Select Routes',
                          style: TextStyle(color: Colors.white),
                        ),

                        buttonStyleData:
                            const ButtonStyleData(height: 20, width: 200),
                        dropdownStyleData: DropdownStyleData(
                            maxHeight: 500,
                            width: MediaQuery.of(context).size.width * 0.5),
                        menuItemStyleData: MenuItemStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          customHeights: _getCustomItemsHeights(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  DropdownButton(
                    iconEnabledColor: Colors.white,
                    iconSize: 26,
                    dropdownColor: Colors.white,
                    hint: Text(
                      'Select Shuttle',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: selectedShuttleType,
                    onChanged: (newValue) {
                      setState(() {
                        status = false;
                        Geofire.removeLocation(
                            '$routeIndex${currentFirebaseUser!.uid}');
                        rideRequestRef.onDisconnect();
                        rideRequestRef.remove();
                        selectedShuttleType = newValue.toString();
                        routeIndex =
                            '${shuttleTypesList.indexOf(newValue!) + 21}';
                        markersInforWindowRoute = selectedShuttleType!;
                        print(selectedShuttleType);
                        markerBustype = 'Shuttle';
                        markersOnMap();
                      });
                    },
                    items: shuttleTypesList.map((shuttle) {
                      return DropdownMenuItem(
                        value: shuttle,
                        child: Text(
                          shuttle,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.815,
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: _cameraPosition,
                  myLocationEnabled: true,
                  markers: markersSet,
                  // zoomControlsEnabled: true,
                  // zoomGesturesEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    newGoogleMapController = controller;
                    locatePosition();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      // Container(
      //   margin: EdgeInsets.only(
      //     left: 20,
      //     right: 20,
      //   ),
      //   child: Column(
      //     children: [
      //       SizedBox(
      //         height: 40,
      //       ),
      //       TextField(
      //         controller: busnoController,
      //         decoration: const InputDecoration(
      //           labelText: "Bus No",
      //           hintText: "Bus No",
      //           enabledBorder: UnderlineInputBorder(
      //             borderSide: BorderSide(color: Colors.grey),
      //           ),
      //           focusedBorder: UnderlineInputBorder(
      //             borderSide: BorderSide(color: Colors.grey),
      //           ),
      //           hintStyle: TextStyle(
      //             color: Colors.black,
      //             fontSize: 10,
      //           ),
      //           labelStyle: TextStyle(
      //             color: Colors.black,
      //             fontSize: 16,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 12,
      //       ),
    );
  }

  Padding drawerMethod(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.15,
              ),
              Center(
                child: Container(
                  height: 124,
                  width: 124,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent),
                  child: currentDriversinfo != null
                      ? Image.network(
                          currentDriversinfo!.profile!,
                          fit: BoxFit.fill,
                        )
                      : Center(
                          child: Container(
                            height: 150,
                            width: 170,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage(
                                "images/bbu.png",
                              ),
                              fit: BoxFit.cover,
                            )),
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.05,
              ),
              Text(
                currentDriversinfo?.name ?? '',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.1,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfile()),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.edit),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              Divider(),
              Row(
                children: const [
                  Icon(Icons.email_outlined),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Invite Friend',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TimeTable()));
                },
                child: Row(
                  children: const [
                    Icon(Icons.timer),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Schedule Time Table',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SupportPage()));
                },
                child: Row(
                  children: const [
                    Icon(Icons.support),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Support',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  auth.signOut().then(
                    (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogIn(),
                          ));
                    },
                  ).onError(
                    (error, stackTrace) {
                      Fluttertoast.showToast(
                        msg: error.toString(),
                      );
                    },
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              Divider(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    launchUrl(
                        Uri.parse('https://www.facebook.com/bzupakistan'));
                  },
                  child: const Icon(
                    Icons.facebook,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.bzu.edu.pk/'));
                  },
                  child: const Icon(
                    Icons.wordpress_rounded,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void markersOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMarkers = Set<Marker>();
    LatLng driverAvailablePosition =
        LatLng(currentPosition!.latitude, currentPosition!.longitude);
    Marker marker = Marker(
      markerId: MarkerId('drivers${currentFirebaseUser!.uid}'),
      position: driverAvailablePosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      //rotation: createRandomNumber(270),
      infoWindow: InfoWindow(
        title: '${markersInforWindowRoute}',
        snippet: '${markerBustype}',
      ),
    );
    tMarkers.add(marker);

    setState(() {
      markersSet = tMarkers;
    });
  }

  void makeDriverOnline() {
    Geofire.initialize("availableDrivers");
    var id = '$routeIndex${currentFirebaseUser!.uid}';
    Geofire.setLocation(
        id, currentPosition!.latitude, currentPosition!.longitude);
    print(currentFirebaseUser!.uid);
    print(currentPosition!.latitude);
    print(currentPosition!.longitude);
    print(id[0]);
    rideRequestRef.onValue.listen((event) {});
  }

  void getLiveLocationUpdates() {
    homePageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      print(currentPosition);
      var id = '$routeIndex${currentFirebaseUser!.uid}';
      print(id[0]);
      Geofire.setLocation(id, position.latitude, position.longitude);
      LatLng latlng = LatLng(position.latitude, position.longitude);
      print(latlng);
      newGoogleMapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    });
  }
}
