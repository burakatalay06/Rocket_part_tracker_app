import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity/connectivity.dart';
import 'package:deneme_1/consts.dart';
import 'package:deneme_1/main.dart';
import 'package:deneme_1/screens/welcome_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  BitmapDescriptor mapMarker_burun;
  BitmapDescriptor mapMarker_govde;

  int _dropdownValue = 1;

  bool switch_status = false;

  bool closed = false;

  bool map_theme_is_normal = false;

  var selected_marker;

  ///---------------spinner----------------------///
  bool spinner_boolen = false;

  void show_spinner() {
    setState(() {
      spinner_boolen = true;
    });
  }

  void stop_spinner() {
    setState(() {
      spinner_boolen = false;
    });
  }

  ///------------------spinner----------------------///

  ///-----------utc converter-------------///

  /*
  BURUN AVİYONİĞİ

B1,175039,37.738172,29.092508,6,-0.6,0,0,31,60

roket_no & saat &latude & longtude & uydu_sayısı & yükseklik & x_açısı & y_açısı & sıcaklık & pil_durumu



ANA AVİYONİK

A1,19113,37.738190,29.092569,6,-1.4,-68,-180,29,-,-     

roket_no & saat & latude & longtude & uydu_sayısı & yükseklik & x_açısı & y_açısı & sıcaklık & patlama durumu_1 & patlama durumu_2
  */
  ///
  ///

  ///---------------firebase-------------------////
  ///roket-x: [38.399722,34.706806,38.399722,33.706806] sırasıyla [ust latitude,ust longitude,alt latitude,alt longitude]
  ///işlediğim veri [A1,19113,37.738190,29.092569,6,-1.4,-68,-180,29,-,-]

  final databaseReference = FirebaseDatabase.instance.reference();

  void readData() async {
    await databaseReference.once().then((DataSnapshot snapshot) {
      ///--------------arayıcı-1 firebase okuma-----------------///
      var searcher_1_notready = snapshot.value["current_location"]["arayıcı1"];
      var searcher_1_ready = json.decode(searcher_1_notready);
      searcher_1_latitude = searcher_1_ready[0];
      searcher_1_longitude = searcher_1_ready[1];

      ///--------------arayıcı-2 firebase okuma-----------------///
      var searcher_2_notready = snapshot.value["current_location"]["arayıcı2"];
      var searcher_2_ready = json.decode(searcher_2_notready);
      searcher_2_latitude = searcher_2_ready[0];
      searcher_2_longitude = searcher_2_ready[1];

      ///--------------roket-1 firebase okuma-----------------///

      String roket_1_ana_notready = snapshot.value["ana"]["ana_1"]["ana_1"];
      List<String> roket_1_ana_ready = roket_1_ana_notready.split(",");

      var roket_1_burun_notready =
          snapshot.value["burun"]["burun_1"]["burun_1"];

      List<String> roket_1_burun_ready = roket_1_burun_notready.split(",");

      roket_1_ana_kod = roket_1_ana_ready[0];
      roket_1_ana_gps_saat = roket_1_ana_ready[1];
      roket_1_ana_latitude = json.decode(roket_1_ana_ready[2]);
      roket_1_ana_longitude = json.decode(roket_1_ana_ready[3]);
      roket_1_ana_uydu_sayisi = roket_1_ana_ready[4];
      roket_1_ana_yukseklik = roket_1_ana_ready[5];
      roket_1_ana_x_aci = roket_1_ana_ready[6];
      roket_1_ana_y_aci = roket_1_ana_ready[7];
      roket_1_ana_sicaklik = roket_1_ana_ready[8];
      roket_1_ana_patlama_durumu_1 = roket_1_ana_ready[9];
      roket_1_ana_patlama_durumu_2 = roket_1_ana_ready[10];

      roket_1_burun_kod = roket_1_burun_ready[0];
      roket_1_burun_gps_saat = roket_1_burun_ready[1];
      roket_1_burun_latitude = json.decode(roket_1_burun_ready[2]);
      roket_1_burun_longitude = json.decode(roket_1_burun_ready[3]);
      roket_1_burun_uydu_sayisi = roket_1_burun_ready[4];
      roket_1_burun_yukseklik = roket_1_burun_ready[5];
      roket_1_burun_x_aci = roket_1_burun_ready[6];
      roket_1_burun_y_aci = roket_1_burun_ready[7];
      roket_1_burun_sicaklik = roket_1_burun_ready[8];
      roket_1_burun_pil_durumu = roket_1_burun_ready[9];

      ///--------------roket-2 firebase okuma-----------------///
      var roket_2_ana_notready = snapshot.value["ana"]["ana_2"]["ana_2"];
      var roket_2_ana_ready = roket_2_ana_notready.split(",");

      var roket_2_burun_notready =
          snapshot.value["burun"]["burun_2"]["burun_2"];
      var roket_2_burun_ready = roket_2_burun_notready.split(",");

      roket_2_ana_kod = roket_2_ana_ready[0];
      roket_2_ana_gps_saat = roket_2_ana_ready[1];
      roket_2_ana_latitude = json.decode(roket_2_ana_ready[2]);
      roket_2_ana_longitude = json.decode(roket_2_ana_ready[3]);
      roket_2_ana_uydu_sayisi = roket_2_ana_ready[4];
      roket_2_ana_yukseklik = roket_2_ana_ready[5];
      roket_2_ana_x_aci = roket_2_ana_ready[6];
      roket_2_ana_y_aci = roket_2_ana_ready[7];
      roket_2_ana_sicaklik = roket_2_ana_ready[8];
      roket_2_ana_patlama_durumu_1 = roket_2_ana_ready[9];
      roket_2_ana_patlama_durumu_2 = roket_2_ana_ready[10];

      roket_2_burun_kod = roket_2_burun_ready[0];
      roket_2_burun_gps_saat = roket_2_burun_ready[1];
      roket_2_burun_latitude = json.decode(roket_2_burun_ready[2]);
      roket_2_burun_longitude = json.decode(roket_2_burun_ready[3]);
      roket_2_burun_uydu_sayisi = roket_2_burun_ready[4];
      roket_2_burun_yukseklik = roket_2_burun_ready[5];
      roket_2_burun_x_aci = roket_2_burun_ready[6];
      roket_2_burun_y_aci = roket_2_burun_ready[7];
      roket_2_burun_sicaklik = roket_2_burun_ready[8];
      roket_2_burun_pil_durumu = roket_2_burun_ready[9];

      ///--------------roket-3 firebase okuma-----------------///

      var roket_3_ana_notready = snapshot.value["ana"]["ana_3"]["ana_3"];
      var roket_3_ana_ready = roket_3_ana_notready.split(",");

      var roket_3_burun_notready =
          snapshot.value["burun"]["burun_3"]["burun_3"];
      var roket_3_burun_ready = roket_3_burun_notready.split(",");

      roket_3_ana_kod = roket_3_ana_ready[0];
      roket_3_ana_gps_saat = roket_3_ana_ready[1];
      roket_3_ana_latitude = json.decode(roket_3_ana_ready[2]);
      roket_3_ana_longitude = json.decode(roket_3_ana_ready[3]);
      roket_3_ana_uydu_sayisi = roket_3_ana_ready[4];
      roket_3_ana_yukseklik = roket_3_ana_ready[5];
      roket_3_ana_x_aci = roket_3_ana_ready[6];
      roket_3_ana_y_aci = roket_3_ana_ready[7];
      roket_3_ana_sicaklik = roket_3_ana_ready[8];
      roket_3_ana_patlama_durumu_1 = roket_3_ana_ready[9];
      roket_3_ana_patlama_durumu_2 = roket_3_ana_ready[10];

      roket_3_burun_kod = roket_3_burun_ready[0];
      roket_3_burun_gps_saat = roket_3_burun_ready[1];
      roket_3_burun_latitude = json.decode(roket_3_burun_ready[2]);
      roket_3_burun_longitude = json.decode(roket_3_burun_ready[3]);
      roket_3_burun_uydu_sayisi = roket_3_burun_ready[4];
      roket_3_burun_yukseklik = roket_3_burun_ready[5];
      roket_3_burun_x_aci = roket_3_burun_ready[6];
      roket_3_burun_y_aci = roket_3_burun_ready[7];
      roket_3_burun_sicaklik = roket_3_burun_ready[8];
      roket_3_burun_pil_durumu = roket_3_burun_ready[9];

      ///--------------roket-4 firebase okuma-----------------///

      var roket_4_ana_notready = snapshot.value["ana"]["ana_4"]["ana_4"];
      var roket_4_ana_ready = roket_4_ana_notready.split(",");

      var roket_4_burun_notready =
          snapshot.value["burun"]["burun_4"]["burun_4"];
      var roket_4_burun_ready = roket_4_burun_notready.split(",");

      roket_4_ana_kod = roket_4_ana_ready[0];
      roket_4_ana_gps_saat = roket_4_ana_ready[1];
      roket_4_ana_latitude = json.decode(roket_4_ana_ready[2]);
      roket_4_ana_longitude = json.decode(roket_4_ana_ready[3]);
      roket_4_ana_uydu_sayisi = roket_4_ana_ready[4];
      roket_4_ana_yukseklik = roket_4_ana_ready[5];
      roket_4_ana_x_aci = roket_4_ana_ready[6];
      roket_4_ana_y_aci = roket_4_ana_ready[7];
      roket_4_ana_sicaklik = roket_4_ana_ready[8];
      roket_4_ana_patlama_durumu_1 = roket_4_ana_ready[9];
      roket_4_ana_patlama_durumu_2 = roket_4_ana_ready[10];

      roket_4_burun_kod = roket_4_burun_ready[0];
      roket_4_burun_gps_saat = roket_4_burun_ready[1];
      roket_4_burun_latitude = json.decode(roket_4_burun_ready[2]);
      roket_4_burun_longitude = json.decode(roket_4_burun_ready[3]);
      roket_4_burun_uydu_sayisi = roket_4_burun_ready[4];
      roket_4_burun_yukseklik = roket_4_burun_ready[5];
      roket_4_burun_x_aci = roket_4_burun_ready[6];
      roket_4_burun_y_aci = roket_4_burun_ready[7];
      roket_4_burun_sicaklik = roket_4_burun_ready[8];
      roket_4_burun_pil_durumu = roket_4_burun_ready[9];

      ///--------------roket-5 firebase okuma-----------------///

      var roket_5_ana_notready = snapshot.value["ana"]["ana_5"]["ana_5"];
      var roket_5_ana_ready = roket_5_ana_notready.split(",");

      var roket_5_burun_notready =
          snapshot.value["burun"]["burun_5"]["burun_5"];
      var roket_5_burun_ready = roket_5_burun_notready.split(",");

      roket_5_ana_kod = roket_5_ana_ready[0];
      roket_5_ana_gps_saat = roket_5_ana_ready[1];
      roket_5_ana_latitude = json.decode(roket_5_ana_ready[2]);
      roket_5_ana_longitude = json.decode(roket_5_ana_ready[3]);
      roket_5_ana_uydu_sayisi = roket_5_ana_ready[4];
      roket_5_ana_yukseklik = roket_5_ana_ready[5];
      roket_5_ana_x_aci = roket_5_ana_ready[6];
      roket_5_ana_y_aci = roket_5_ana_ready[7];
      roket_5_ana_sicaklik = roket_5_ana_ready[8];
      roket_5_ana_patlama_durumu_1 = roket_5_ana_ready[9];
      roket_5_ana_patlama_durumu_2 = roket_5_ana_ready[10];

      roket_5_burun_kod = roket_5_burun_ready[0];
      roket_5_burun_gps_saat = roket_5_burun_ready[1];
      roket_5_burun_latitude = json.decode(roket_5_burun_ready[2]);
      roket_5_burun_longitude = json.decode(roket_5_burun_ready[3]);
      roket_5_burun_uydu_sayisi = roket_5_burun_ready[4];
      roket_5_burun_yukseklik = roket_5_burun_ready[5];
      roket_5_burun_x_aci = roket_5_burun_ready[6];
      roket_5_burun_y_aci = roket_5_burun_ready[7];
      roket_5_burun_sicaklik = roket_5_burun_ready[8];
      roket_5_burun_pil_durumu = roket_5_burun_ready[9];

      ///--------------roket-6 firebase okuma-----------------///

      var roket_6_ana_notready = snapshot.value["ana"]["ana_6"]["ana_6"];
      var roket_6_ana_ready = roket_6_ana_notready.split(",");

      var roket_6_burun_notready =
          snapshot.value["burun"]["burun_6"]["burun_6"];
      var roket_6_burun_ready = roket_6_burun_notready.split(",");

      roket_6_ana_kod = roket_6_ana_ready[0];
      roket_6_ana_gps_saat = roket_6_ana_ready[1];
      roket_6_ana_latitude = json.decode(roket_6_ana_ready[2]);
      roket_6_ana_longitude = json.decode(roket_6_ana_ready[3]);
      roket_6_ana_uydu_sayisi = roket_6_ana_ready[4];
      roket_6_ana_yukseklik = roket_6_ana_ready[5];
      roket_6_ana_x_aci = roket_6_ana_ready[6];
      roket_6_ana_y_aci = roket_6_ana_ready[7];
      roket_6_ana_sicaklik = roket_6_ana_ready[8];
      roket_6_ana_patlama_durumu_1 = roket_6_ana_ready[9];
      roket_6_ana_patlama_durumu_2 = roket_6_ana_ready[10];

      roket_6_burun_kod = roket_6_burun_ready[0];
      roket_6_burun_gps_saat = roket_6_burun_ready[1];
      roket_6_burun_latitude = json.decode(roket_6_burun_ready[2]);
      roket_6_burun_longitude = json.decode(roket_6_burun_ready[3]);
      roket_6_burun_uydu_sayisi = roket_6_burun_ready[4];
      roket_6_burun_yukseklik = roket_6_burun_ready[5];
      roket_6_burun_x_aci = roket_6_burun_ready[6];
      roket_6_burun_y_aci = roket_6_burun_ready[7];
      roket_6_burun_sicaklik = roket_6_burun_ready[8];
      roket_6_burun_pil_durumu = roket_6_burun_ready[9];

      ///--------------roket-7 firebase okuma-----------------///

      var roket_7_ana_notready = snapshot.value["ana"]["ana_7"]["ana_7"];
      var roket_7_ana_ready = roket_7_ana_notready.split(",");

      var roket_7_burun_notready =
          snapshot.value["burun"]["burun_7"]["burun_7"];
      var roket_7_burun_ready = roket_7_burun_notready.split(",");

      roket_7_ana_kod = roket_7_ana_ready[0];
      roket_7_ana_gps_saat = roket_7_ana_ready[1];
      roket_7_ana_latitude = json.decode(roket_7_ana_ready[2]);
      roket_7_ana_longitude = json.decode(roket_7_ana_ready[3]);
      roket_7_ana_uydu_sayisi = roket_7_ana_ready[4];
      roket_7_ana_yukseklik = roket_7_ana_ready[5];
      roket_7_ana_x_aci = roket_7_ana_ready[6];
      roket_7_ana_y_aci = roket_7_ana_ready[7];
      roket_7_ana_sicaklik = roket_7_ana_ready[8];
      roket_7_ana_patlama_durumu_1 = roket_7_ana_ready[9];
      roket_7_ana_patlama_durumu_2 = roket_7_ana_ready[10];

      roket_7_burun_kod = roket_7_burun_ready[0];
      roket_7_burun_gps_saat = roket_7_burun_ready[1];
      roket_7_burun_latitude = json.decode(roket_7_burun_ready[2]);
      roket_7_burun_longitude = json.decode(roket_7_burun_ready[3]);
      roket_7_burun_uydu_sayisi = roket_7_burun_ready[4];
      roket_7_burun_yukseklik = roket_7_burun_ready[5];
      roket_7_burun_x_aci = roket_7_burun_ready[6];
      roket_7_burun_y_aci = roket_7_burun_ready[7];
      roket_7_burun_sicaklik = roket_7_burun_ready[8];
      roket_7_burun_pil_durumu = roket_7_burun_ready[9];

      ///--------------roket-8 firebase okuma-----------------///

      var roket_8_ana_notready = snapshot.value["ana"]["ana_8"]["ana_8"];
      var roket_8_ana_ready = roket_8_ana_notready.split(",");

      var roket_8_burun_notready =
          snapshot.value["burun"]["burun_8"]["burun_8"];
      var roket_8_burun_ready = roket_8_burun_notready.split(",");

      roket_8_ana_kod = roket_8_ana_ready[0];
      roket_8_ana_gps_saat = roket_8_ana_ready[1];
      roket_8_ana_latitude = json.decode(roket_8_ana_ready[2]);
      roket_8_ana_longitude = json.decode(roket_8_ana_ready[3]);
      roket_8_ana_uydu_sayisi = roket_8_ana_ready[4];
      roket_8_ana_yukseklik = roket_8_ana_ready[5];
      roket_8_ana_x_aci = roket_8_ana_ready[6];
      roket_8_ana_y_aci = roket_8_ana_ready[7];
      roket_8_ana_sicaklik = roket_8_ana_ready[8];
      roket_8_ana_patlama_durumu_1 = roket_8_ana_ready[9];
      roket_8_ana_patlama_durumu_2 = roket_8_ana_ready[10];

      roket_8_burun_kod = roket_8_burun_ready[0];
      roket_8_burun_gps_saat = roket_8_burun_ready[1];
      roket_8_burun_latitude = json.decode(roket_8_burun_ready[2]);
      roket_8_burun_longitude = json.decode(roket_8_burun_ready[3]);
      roket_8_burun_uydu_sayisi = roket_8_burun_ready[4];
      roket_8_burun_yukseklik = roket_8_burun_ready[5];
      roket_8_burun_x_aci = roket_8_burun_ready[6];
      roket_8_burun_y_aci = roket_8_burun_ready[7];
      roket_8_burun_sicaklik = roket_8_burun_ready[8];
      roket_8_burun_pil_durumu = roket_8_burun_ready[9];

      ///--------------roket-9 firebase okuma-----------------///

      var roket_9_ana_notready = snapshot.value["ana"]["ana_9"]["ana_9"];
      var roket_9_ana_ready = roket_9_ana_notready.split(",");

      var roket_9_burun_notready =
          snapshot.value["burun"]["burun_9"]["burun_9"];
      var roket_9_burun_ready = roket_9_burun_notready.split(",");

      roket_9_ana_kod = roket_9_ana_ready[0];
      roket_9_ana_gps_saat = roket_9_ana_ready[1];
      roket_9_ana_latitude = json.decode(roket_9_ana_ready[2]);
      roket_9_ana_longitude = json.decode(roket_9_ana_ready[3]);
      roket_9_ana_uydu_sayisi = roket_9_ana_ready[4];
      roket_9_ana_yukseklik = roket_9_ana_ready[5];
      roket_9_ana_x_aci = roket_9_ana_ready[6];
      roket_9_ana_y_aci = roket_9_ana_ready[7];
      roket_9_ana_sicaklik = roket_9_ana_ready[8];
      roket_9_ana_patlama_durumu_1 = roket_9_ana_ready[9];
      roket_9_ana_patlama_durumu_2 = roket_9_ana_ready[10];

      roket_9_burun_kod = roket_9_burun_ready[0];
      roket_9_burun_gps_saat = roket_9_burun_ready[1];
      roket_9_burun_latitude = json.decode(roket_9_burun_ready[2]);
      roket_9_burun_longitude = json.decode(roket_9_burun_ready[3]);
      roket_9_burun_uydu_sayisi = roket_9_burun_ready[4];
      roket_9_burun_yukseklik = roket_9_burun_ready[5];
      roket_9_burun_x_aci = roket_9_burun_ready[6];
      roket_9_burun_y_aci = roket_9_burun_ready[7];
      roket_9_burun_sicaklik = roket_9_burun_ready[8];
      roket_9_burun_pil_durumu = roket_9_burun_ready[9];

      ///--------------roket-10 firebase okuma-----------------///

      var roket_10_ana_notready = snapshot.value["ana"]["ana_10"]["ana_10"];
      var roket_10_ana_ready = roket_10_ana_notready.split(",");

      var roket_10_burun_notready =
          snapshot.value["burun"]["burun_10"]["burun_10"];
      var roket_10_burun_ready = roket_10_burun_notready.split(",");

      roket_10_ana_kod = roket_10_ana_ready[0];
      roket_10_ana_gps_saat = roket_10_ana_ready[1];
      roket_10_ana_latitude = json.decode(roket_10_ana_ready[2]);
      roket_10_ana_longitude = json.decode(roket_10_ana_ready[3]);
      roket_10_ana_uydu_sayisi = roket_10_ana_ready[4];
      roket_10_ana_yukseklik = roket_10_ana_ready[5];
      roket_10_ana_x_aci = roket_10_ana_ready[6];
      roket_10_ana_y_aci = roket_10_ana_ready[7];
      roket_10_ana_sicaklik = roket_10_ana_ready[8];
      roket_10_ana_patlama_durumu_1 = roket_10_ana_ready[9];
      roket_10_ana_patlama_durumu_2 = roket_10_ana_ready[10];

      roket_10_burun_kod = roket_10_burun_ready[0];
      roket_10_burun_gps_saat = roket_10_burun_ready[1];
      roket_10_burun_latitude = json.decode(roket_10_burun_ready[2]);
      roket_10_burun_longitude = json.decode(roket_10_burun_ready[3]);
      roket_10_burun_uydu_sayisi = roket_10_burun_ready[4];
      roket_10_burun_yukseklik = roket_10_burun_ready[5];
      roket_10_burun_x_aci = roket_10_burun_ready[6];
      roket_10_burun_y_aci = roket_10_burun_ready[7];
      roket_10_burun_sicaklik = roket_10_burun_ready[8];
      roket_10_burun_pil_durumu = roket_10_burun_ready[9];
    });
  }

  ///---------------firebase-------------------////

  ///----------------geo locator service ------------------///

  var current_location_latitude;
  var current_location_longitude;

  Position position;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("gps kapalı!!!");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Gps'e erişilmesine izin verilmiyor");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Gps izin hatası");
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> get_current_location() async {
    if (this.mounted) {
      try {
        position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best)
            .whenComplete(() {
          setState(() {
            position = position;
          });
        });
      } catch (e) {
        print(e);
      }
    }
  }

  double calculate_distance(

      ///abi burada geolocatordan aldığın anlık konum ile roketlerin konumları arasındaki mesafeyi ölçüyorsun
      ///!! burası çokommelli bak ::::::>>>>calculate_distance fonksiyonunu get_current_location fonksiyonundan sonra çağır!!!!!
      {@required double startLatitude,
      @required double startLongitude,
      @required double endLatitude,
      @required double endLongitude}) {
    try {
      return Geolocator.distanceBetween(
              startLatitude, startLongitude, endLatitude, endLongitude)
          .toDouble();
    } catch (e) {
      print(e);
    }
  }

  ///----------------geo locator service ---------------------///

  ///-----------------manuel roket koordinatları--------------///

  var manuel_burun_latitude_not_ready;
  var manuel_burun_longitude_not_ready;

  var manuel_burun_latitude_ready;
  var manuel_burun_longitude_ready;

  var manuel_govde_latitude_not_ready;
  var manuel_govde_longitude_not_ready;

  var manuel_govde_latitude_ready;
  var manuel_govde_longitude_ready;

  String secilen_roket = "roket-1"; //default olarak roket-1 seçili !

  ///-----------------manuel roket koordinatları--------------///

  ///-----------------roket seçimleri------------------------///
  bool roket_1_boolen = false;
  bool roket_2_boolen = false;
  bool roket_3_boolen = false;
  bool roket_4_boolen = false;
  bool roket_5_boolen = false;
  bool roket_6_boolen = false;
  bool roket_7_boolen = false;
  bool roket_8_boolen = false;
  bool roket_9_boolen = false;
  bool roket_10_boolen = false;

  ///-----------------------arayıcıların koordinatları--------------///

  bool searcher_1_boolen = false; //arayıcıların konumları
  bool searcher_2_boolen = false; //arayıcıların konumları

  var searcher_1_latitude;
  var searcher_1_longitude;

  var searcher_2_latitude;
  var searcher_2_longitude;

  ///---------------Roketlerin koordinatları---------------///

  var roket_1_ana_latitude;
  var roket_1_ana_longitude;

  var roket_1_ana_kod;
  var roket_1_ana_uydu_sayisi;
  var roket_1_ana_gps_saat;
  var roket_1_ana_yukseklik;
  var roket_1_ana_x_aci;
  var roket_1_ana_y_aci;
  var roket_1_ana_sicaklik;
  var roket_1_ana_patlama_durumu_1;
  var roket_1_ana_patlama_durumu_2;

  var roket_1_burun_latitude;
  var roket_1_burun_longitude;

  var roket_1_burun_kod;
  var roket_1_burun_uydu_sayisi;
  var roket_1_burun_gps_saat;
  var roket_1_burun_yukseklik;
  var roket_1_burun_x_aci;
  var roket_1_burun_y_aci;
  var roket_1_burun_sicaklik;
  var roket_1_burun_pil_durumu;

  ///-------------------Roket 1------------------------------///

  var roket_2_ana_latitude;
  var roket_2_ana_longitude;

  var roket_2_ana_kod;
  var roket_2_ana_uydu_sayisi;
  var roket_2_ana_gps_saat;
  var roket_2_ana_yukseklik;
  var roket_2_ana_x_aci;
  var roket_2_ana_y_aci;
  var roket_2_ana_sicaklik;
  var roket_2_ana_patlama_durumu_1;
  var roket_2_ana_patlama_durumu_2;

  var roket_2_burun_latitude;
  var roket_2_burun_longitude;

  var roket_2_burun_kod;
  var roket_2_burun_uydu_sayisi;
  var roket_2_burun_gps_saat;
  var roket_2_burun_yukseklik;
  var roket_2_burun_x_aci;
  var roket_2_burun_y_aci;
  var roket_2_burun_sicaklik;
  var roket_2_burun_pil_durumu;

  ///-------------------Roket 2------------------------------///

  var roket_3_ana_latitude;
  var roket_3_ana_longitude;

  var roket_3_ana_kod;
  var roket_3_ana_uydu_sayisi;
  var roket_3_ana_gps_saat;
  var roket_3_ana_yukseklik;
  var roket_3_ana_x_aci;
  var roket_3_ana_y_aci;
  var roket_3_ana_sicaklik;
  var roket_3_ana_patlama_durumu_1;
  var roket_3_ana_patlama_durumu_2;

  var roket_3_burun_latitude;
  var roket_3_burun_longitude;

  var roket_3_burun_kod;
  var roket_3_burun_uydu_sayisi;
  var roket_3_burun_gps_saat;
  var roket_3_burun_yukseklik;
  var roket_3_burun_x_aci;
  var roket_3_burun_y_aci;
  var roket_3_burun_sicaklik;
  var roket_3_burun_pil_durumu;

  ///-------------------Roket 3------------------------------///

  var roket_4_ana_latitude;
  var roket_4_ana_longitude;

  var roket_4_ana_kod;
  var roket_4_ana_uydu_sayisi;
  var roket_4_ana_gps_saat;
  var roket_4_ana_yukseklik;
  var roket_4_ana_x_aci;
  var roket_4_ana_y_aci;
  var roket_4_ana_sicaklik;
  var roket_4_ana_patlama_durumu_1;
  var roket_4_ana_patlama_durumu_2;

  var roket_4_burun_latitude;
  var roket_4_burun_longitude;

  var roket_4_burun_kod;
  var roket_4_burun_uydu_sayisi;
  var roket_4_burun_gps_saat;
  var roket_4_burun_yukseklik;
  var roket_4_burun_x_aci;
  var roket_4_burun_y_aci;
  var roket_4_burun_sicaklik;
  var roket_4_burun_pil_durumu;

  ///-------------------Roket 4------------------------------///

  var roket_5_ana_latitude;
  var roket_5_ana_longitude;

  var roket_5_ana_kod;
  var roket_5_ana_uydu_sayisi;
  var roket_5_ana_gps_saat;
  var roket_5_ana_yukseklik;
  var roket_5_ana_x_aci;
  var roket_5_ana_y_aci;
  var roket_5_ana_sicaklik;
  var roket_5_ana_patlama_durumu_1;
  var roket_5_ana_patlama_durumu_2;

  var roket_5_burun_latitude;
  var roket_5_burun_longitude;

  var roket_5_burun_kod;
  var roket_5_burun_uydu_sayisi;
  var roket_5_burun_gps_saat;
  var roket_5_burun_yukseklik;
  var roket_5_burun_x_aci;
  var roket_5_burun_y_aci;
  var roket_5_burun_sicaklik;
  var roket_5_burun_pil_durumu;

  ///-------------------Roket 5------------------------------///

  var roket_6_ana_latitude;
  var roket_6_ana_longitude;

  var roket_6_ana_kod;
  var roket_6_ana_uydu_sayisi;
  var roket_6_ana_gps_saat;
  var roket_6_ana_yukseklik;
  var roket_6_ana_x_aci;
  var roket_6_ana_y_aci;
  var roket_6_ana_sicaklik;
  var roket_6_ana_patlama_durumu_1;
  var roket_6_ana_patlama_durumu_2;

  var roket_6_burun_latitude;
  var roket_6_burun_longitude;

  var roket_6_burun_kod;
  var roket_6_burun_uydu_sayisi;
  var roket_6_burun_gps_saat;
  var roket_6_burun_yukseklik;
  var roket_6_burun_x_aci;
  var roket_6_burun_y_aci;
  var roket_6_burun_sicaklik;
  var roket_6_burun_pil_durumu;

  ///-------------------Roket 6------------------------------///

  var roket_7_ana_latitude;
  var roket_7_ana_longitude;

  var roket_7_ana_kod;
  var roket_7_ana_uydu_sayisi;
  var roket_7_ana_gps_saat;
  var roket_7_ana_yukseklik;
  var roket_7_ana_x_aci;
  var roket_7_ana_y_aci;
  var roket_7_ana_sicaklik;
  var roket_7_ana_patlama_durumu_1;
  var roket_7_ana_patlama_durumu_2;

  var roket_7_burun_latitude;
  var roket_7_burun_longitude;

  var roket_7_burun_kod;
  var roket_7_burun_uydu_sayisi;
  var roket_7_burun_gps_saat;
  var roket_7_burun_yukseklik;
  var roket_7_burun_x_aci;
  var roket_7_burun_y_aci;
  var roket_7_burun_sicaklik;
  var roket_7_burun_pil_durumu;

  ///-------------------Roket 7------------------------------///

  var roket_8_ana_latitude;
  var roket_8_ana_longitude;

  var roket_8_ana_kod;
  var roket_8_ana_uydu_sayisi;
  var roket_8_ana_gps_saat;
  var roket_8_ana_yukseklik;
  var roket_8_ana_x_aci;
  var roket_8_ana_y_aci;
  var roket_8_ana_sicaklik;
  var roket_8_ana_patlama_durumu_1;
  var roket_8_ana_patlama_durumu_2;

  var roket_8_burun_latitude;
  var roket_8_burun_longitude;

  var roket_8_burun_kod;
  var roket_8_burun_uydu_sayisi;
  var roket_8_burun_gps_saat;
  var roket_8_burun_yukseklik;
  var roket_8_burun_x_aci;
  var roket_8_burun_y_aci;
  var roket_8_burun_sicaklik;
  var roket_8_burun_pil_durumu;

  ///-------------------Roket 8------------------------------///

  var roket_9_ana_latitude;
  var roket_9_ana_longitude;

  var roket_9_ana_kod;
  var roket_9_ana_uydu_sayisi;
  var roket_9_ana_gps_saat;
  var roket_9_ana_yukseklik;
  var roket_9_ana_x_aci;
  var roket_9_ana_y_aci;
  var roket_9_ana_sicaklik;
  var roket_9_ana_patlama_durumu_1;
  var roket_9_ana_patlama_durumu_2;

  var roket_9_burun_latitude;
  var roket_9_burun_longitude;

  var roket_9_burun_kod;
  var roket_9_burun_uydu_sayisi;
  var roket_9_burun_gps_saat;
  var roket_9_burun_yukseklik;
  var roket_9_burun_x_aci;
  var roket_9_burun_y_aci;
  var roket_9_burun_sicaklik;
  var roket_9_burun_pil_durumu;

  ///-------------------Roket 9------------------------------///

  var roket_10_ana_latitude;
  var roket_10_ana_longitude;

  var roket_10_ana_kod;
  var roket_10_ana_uydu_sayisi;
  var roket_10_ana_gps_saat;
  var roket_10_ana_yukseklik;
  var roket_10_ana_x_aci;
  var roket_10_ana_y_aci;
  var roket_10_ana_sicaklik;
  var roket_10_ana_patlama_durumu_1;
  var roket_10_ana_patlama_durumu_2;

  var roket_10_burun_latitude;
  var roket_10_burun_longitude;

  var roket_10_burun_kod;
  var roket_10_burun_uydu_sayisi;
  var roket_10_burun_gps_saat;
  var roket_10_burun_yukseklik;
  var roket_10_burun_x_aci;
  var roket_10_burun_y_aci;
  var roket_10_burun_sicaklik;
  var roket_10_burun_pil_durumu;

  ///-------------------Roket 10-----------------------------///

  static final CameraPosition _karea = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  ///---------------Roketlerin koordinatları---------------///

  String marker_id_den_roket_bulucu({@required String marker_id}) {
    if (marker_id == "id-1" || marker_id == "id-2") {
      return "R1";
    }
    if (marker_id == "id-3" || marker_id == "id-4") {
      return "R2";
    }
    if (marker_id == "id-5" || marker_id == "id-6") {
      return "R3";
    }
    if (marker_id == "id-7" || marker_id == "id-8") {
      return "R4";
    }
    if (marker_id == "id-9" || marker_id == "id-10") {
      return "R5";
    }
    if (marker_id == "id-11" || marker_id == "id-12") {
      return "R6";
    }
    if (marker_id == "id-13" || marker_id == "id-14") {
      return "R7";
    }
    if (marker_id == "id-15" || marker_id == "id-16") {
      return "R8";
    }
    if (marker_id == "id-17" || marker_id == "id-18") {
      return "R9";
    }
    if (marker_id == "id-19" || marker_id == "id-20") {
      return "R10";
    }
  }

  Marker marker_ready({
    @required String marker_id,
    @required latitude,
    @required longitude,
    @required String tag_name,
    @required BitmapDescriptor icon,
  }) {
    return Marker(
      markerId: MarkerId(marker_id),
      position: LatLng(latitude, longitude),
      icon: icon, //mapMarker_burun,
      onTap: () {
        setState(() {
          selected_marker = marker_id_den_roket_bulucu(marker_id: marker_id);
        });
      },
      infoWindow: InfoWindow(
        title: tag_name,
        snippet:
            "${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: latitude, endLongitude: longitude).toString().split(".")[0]} metre",
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    show_spinner();
    if (check_internet() == true) {
      readData();
    } else {}

    _askLocationPermission();
    setState(() {});
    setCustomMarker();
    _determinePosition()
        .whenComplete(() => get_current_location())
        .whenComplete(() {
      setState(() {
        try {
          current_location_latitude = position.latitude;
          current_location_longitude = position.longitude;
        } catch (e) {
          print(e);
        }
      });
      stop_spinner();
    });
  }

  void setCustomMarker() async {
    mapMarker_burun = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "images/burun_map.png",
    );
    mapMarker_govde = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "images/govde_map.png",
    );
  }

  Future<void> send_firebase_current_location(
      {@required longitude, @required latitude}) {
    if (key == searcher_1 || key == searcher_2) {
      databaseReference.child("current_location").update({
        "$key": "[${latitude},${longitude}]",
      });
      print("current_location_1:[${latitude},${longitude}]");
      print("current_location_2:[${latitude},${longitude}]");
    } else
      print("lokasyonun firebase e gönderilmiyor");
  }

  void _onMapCreated(GoogleMapController controller) {
    //controller.setMapStyle(Utils.mapStyle);
    const onesec = const Duration(seconds: 1);
    Timer.periodic(onesec, (Timer t) {
      try {
        if (closed == false) {
          get_current_location();
          send_firebase_current_location(
              longitude: current_location_longitude,
              latitude: current_location_latitude);
        } else
          null;
      } catch (e) {
        print(e);
      }
      if (closed == false) {
        if (switch_status == false) {
          refresh_button();
          print("güncellendi");
        }
      }
    });
  }

  //buraya bak artık aq
  Future<bool> getpermission() async {
    var status = await Permission.location.status;
    return status.isDenied;
  }

  void _askLocationPermission() async {
    print("sordu");
    if (await Permission.camera.request().isGranted) {
      var _permissionStatus = await Permission.location.status;
      setState(() {});
    }
  }

  Future<bool> check_internet() async {
    var connectivity_result = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none == true) {
      Fluttertoast.showToast(
          msg: "İnternet bağlantın yok!!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    } else {
      return true;
    }
  }

  void refresh_button() {
    try {
      setState(() {
        readData();
        _markers.clear();
        if (roket_1_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-1",
              latitude: roket_1_burun_latitude,
              longitude: roket_1_burun_longitude,
              tag_name: "Roket-1 Burun"));

          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-2",
              latitude: roket_1_ana_latitude,
              longitude: roket_1_ana_longitude,
              tag_name: "Roket-1 Gövde"));
        } else {
          null;
        }

        if (roket_2_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-3",
              latitude: roket_2_burun_latitude,
              longitude: roket_2_burun_longitude,
              tag_name: "Roket-2 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-4",
              latitude: roket_2_ana_latitude,
              longitude: roket_2_ana_longitude,
              tag_name: "Roket-2 Gövde"));
        } else {
          null;
        }

        if (roket_3_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-5",
              latitude: roket_3_burun_latitude,
              longitude: roket_3_burun_longitude,
              tag_name: "Roket-3 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-6",
              latitude: roket_3_ana_latitude,
              longitude: roket_3_ana_longitude,
              tag_name: "Roket-3 Gövde"));
        } else {
          null;
        }

        if (roket_4_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-7",
              latitude: roket_4_burun_latitude,
              longitude: roket_4_burun_longitude,
              tag_name: "Roket-4 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-8",
              latitude: roket_4_ana_latitude,
              longitude: roket_4_ana_longitude,
              tag_name: "Roket-4 Gövde"));
        } else {
          null;
        }

        if (roket_5_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-9",
              latitude: roket_5_burun_latitude,
              longitude: roket_5_burun_longitude,
              tag_name: "Roket-5 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-10",
              latitude: roket_5_ana_latitude,
              longitude: roket_5_ana_longitude,
              tag_name: "Roket-5 Gövde"));
        } else {
          null;
        }

        if (roket_6_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-11",
              latitude: roket_6_burun_latitude,
              longitude: roket_6_burun_longitude,
              tag_name: "Roket-6 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-12",
              latitude: roket_6_ana_latitude,
              longitude: roket_6_ana_longitude,
              tag_name: "Roket-6 Gövde"));
        } else {
          null;
        }

        if (roket_7_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-13",
              latitude: roket_7_burun_latitude,
              longitude: roket_7_burun_longitude,
              tag_name: "Roket-7 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-14",
              latitude: roket_7_ana_latitude,
              longitude: roket_7_ana_longitude,
              tag_name: "Roket-7 Gövde"));
        } else {
          null;
        }

        if (roket_8_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-15",
              latitude: roket_8_burun_latitude,
              longitude: roket_8_burun_longitude,
              tag_name: "Roket-8 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-16",
              latitude: roket_8_ana_latitude,
              longitude: roket_8_ana_longitude,
              tag_name: "Roket-8 Gövde"));
        } else {
          null;
        }

        if (roket_9_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-17",
              latitude: roket_9_burun_latitude,
              longitude: roket_9_burun_longitude,
              tag_name: "Roket-9 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-18",
              latitude: roket_9_ana_latitude,
              longitude: roket_9_ana_longitude,
              tag_name: "Roket-9 Gövde"));
        } else {
          null;
        }

        if (roket_10_boolen) {
          _markers.add(marker_ready(
              icon: mapMarker_burun,
              marker_id: "id-19",
              latitude: roket_10_burun_latitude,
              longitude: roket_10_burun_longitude,
              tag_name: "Roket-10 Burun"));
          _markers.add(marker_ready(
              icon: mapMarker_govde,
              marker_id: "id-20",
              latitude: roket_10_ana_latitude,
              longitude: roket_10_ana_longitude,
              tag_name: "Roket-10 Gövde"));
        } else {
          null;
        }

        if (searcher_1_boolen) {
          _markers.add(marker_ready(
              marker_id: "id-21",
              latitude: searcher_1_latitude,
              longitude: searcher_1_longitude,
              tag_name: "arayıcı-1"));
        } else {
          null;
        }

        if (searcher_2_boolen) {
          _markers.add(marker_ready(
              marker_id: "id-22",
              latitude: searcher_2_latitude,
              longitude: searcher_2_longitude,
              tag_name: "arayıcı-2"));
        } else {
          null;
        }
      });
      stop_spinner();
    } catch (e) {
      print(e);
    }
  }

  void manuel_giris() {
    setState(() {
      _markers.clear();
      if (secilen_roket == "roket-1") {
        setState(() {
          roket_1_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-1",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-1 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-2",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-1 Gövde --Manuel"));
      } else {
        print("roket-1 manuel girilmemiş");
      }

      if (secilen_roket == "roket-2") {
        setState(() {
          roket_2_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-3",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-2 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-4",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-2 Gövde --Manuel"));
      } else {
        print("roket-2 manuel girilmemiş");
      }
      if (secilen_roket == "roket-3") {
        setState(() {
          roket_3_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-5",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-3 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-6",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-3 Gövde --Manuel"));
      } else {
        print("roket-3 manuel girilmemiş");
      }

      if (secilen_roket == "roket-4") {
        setState(() {
          roket_4_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-7",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-4 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-8",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-4 Gövde --Manuel"));
      } else {
        print("roket-4 manuel girilmemiş");
      }

      if (secilen_roket == "roket-5") {
        setState(() {
          roket_5_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-9",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-5 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-10",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-5 Gövde --Manuel"));
      } else {
        print("roket-5 manuel girilmemiş");
      }

      if (secilen_roket == "roket-6") {
        setState(() {
          roket_6_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-11",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-6 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-12",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-6 Gövde --Manuel"));
      } else {
        print("roket-6 manuel girilmemiş");
      }

      if (secilen_roket == "roket-7") {
        setState(() {
          roket_7_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-13",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-7 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-14",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-7 Gövde --Manuel"));
      } else {
        print("roket-7 manuel girilmemiş");
      }

      if (secilen_roket == "roket-8") {
        setState(() {
          roket_8_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-15",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-8 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-16",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-8 Gövde --Manuel"));
      } else {
        print("roket-8 manuel girilmemiş");
      }

      if (secilen_roket == "roket-9") {
        setState(() {
          roket_9_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-17",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-9 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-18",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-9 Gövde --Manuel"));
      } else {
        print("roket-9 manuel girilmemiş");
      }

      if (secilen_roket == "roket-10") {
        setState(() {
          roket_10_boolen = false;
        });
        _markers.add(marker_ready(
            icon: mapMarker_burun,
            marker_id: "id-19",
            latitude: manuel_burun_latitude_ready,
            longitude: manuel_burun_longitude_ready,
            tag_name: "Roket-10 Burun --Manuel"));

        _markers.add(marker_ready(
            icon: mapMarker_govde,
            marker_id: "id-20",
            latitude: manuel_govde_latitude_ready,
            longitude: manuel_govde_longitude_ready,
            tag_name: "Roket-10 Gövde --Manuel"));
      } else {
        print("roket-10 manuel girilmemiş");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.width * 35 / 411,
          ),
          Column(
            children: <Widget>[
              CheckboxListTile(
                title: Text("Roket-1"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_1_burun_latitude, endLongitude: roket_1_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_1_ana_latitude, endLongitude: roket_1_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_1_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_1_boolen = value;
                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-1",
                            latitude: roket_1_burun_latitude,
                            longitude: roket_1_burun_longitude,
                            tag_name: "Roket-1 burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-2",
                            latitude: roket_1_ana_latitude,
                            longitude: roket_1_ana_longitude,
                            tag_name: "Roket-1 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-1"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-2"));
                    }
                  });
                },
                activeColor: my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-2"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_2_burun_latitude, endLongitude: roket_2_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_2_ana_latitude, endLongitude: roket_2_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_2_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_2_boolen = value;
                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-3",
                            latitude: roket_2_burun_latitude,
                            longitude: roket_2_burun_longitude,
                            tag_name: "Roket-2 Burun"),
                      );
                      _markers.add(marker_ready(
                          icon: mapMarker_govde,
                          marker_id: "id-4",
                          latitude: roket_2_ana_latitude,
                          longitude: roket_2_ana_longitude,
                          tag_name: "Roket-2 Gövde"));
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-3"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-4"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-3"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_3_burun_latitude, endLongitude: roket_3_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_3_ana_latitude, endLongitude: roket_3_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_3_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_3_boolen = value;
                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-5",
                            latitude: roket_3_burun_latitude,
                            longitude: roket_3_burun_longitude,
                            tag_name: "Roket-3 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-6",
                            latitude: roket_3_ana_latitude,
                            longitude: roket_3_ana_longitude,
                            tag_name: "Roket-3 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-5"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-6"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-4"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_4_burun_latitude, endLongitude: roket_4_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_4_ana_latitude, endLongitude: roket_4_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_4_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_4_boolen = value;

                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-7",
                            latitude: roket_4_burun_latitude,
                            longitude: roket_4_burun_longitude,
                            tag_name: "Roket-4 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-8",
                            latitude: roket_4_ana_latitude,
                            longitude: roket_4_ana_longitude,
                            tag_name: "Roket-4 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-7"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-8"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-5"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_5_burun_latitude, endLongitude: roket_5_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_5_ana_latitude, endLongitude: roket_5_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_5_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_5_boolen = value;

                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-9",
                            latitude: roket_5_burun_latitude,
                            longitude: roket_5_burun_longitude,
                            tag_name: "Roket-5 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-10",
                            latitude: roket_5_ana_latitude,
                            longitude: roket_5_ana_longitude,
                            tag_name: "Roket-5 Burun"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-9"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-10"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-6"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_6_burun_latitude, endLongitude: roket_6_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_6_ana_latitude, endLongitude: roket_6_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_6_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_6_boolen = value;
                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-11",
                            latitude: roket_6_burun_latitude,
                            longitude: roket_6_burun_longitude,
                            tag_name: "Roket-6 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-12",
                            latitude: roket_6_ana_latitude,
                            longitude: roket_6_ana_longitude,
                            tag_name: "Roket-6 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-11"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-12"));
                    }
                  });
                },
                activeColor: my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-7"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_7_burun_latitude, endLongitude: roket_7_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_7_ana_latitude, endLongitude: roket_7_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_7_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_7_boolen = value;

                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-13",
                            latitude: roket_7_burun_latitude,
                            longitude: roket_7_burun_longitude,
                            tag_name: "Roket-7 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-14",
                            latitude: roket_7_ana_latitude,
                            longitude: roket_7_ana_longitude,
                            tag_name: "Roket-7 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-13"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-14"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-8"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_8_burun_latitude, endLongitude: roket_8_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_8_ana_latitude, endLongitude: roket_8_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_8_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_8_boolen = value;

                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-15",
                            latitude: roket_8_burun_latitude,
                            longitude: roket_8_burun_longitude,
                            tag_name: "Roket-8 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-16",
                            latitude: roket_8_ana_latitude,
                            longitude: roket_8_ana_longitude,
                            tag_name: "Roket-8 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-15"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-16"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-9"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_9_burun_latitude, endLongitude: roket_9_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_9_ana_latitude, endLongitude: roket_9_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_9_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_9_boolen = value;

                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-17",
                            latitude: roket_9_burun_latitude,
                            longitude: roket_9_burun_longitude,
                            tag_name: "Roket-9 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-18",
                            latitude: roket_9_ana_latitude,
                            longitude: roket_9_ana_longitude,
                            tag_name: "Roket-9 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-17"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-18"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text("Roket-10"),
                subtitle: current_location_latitude == null
                    ? Text("hesaplanıyor...")
                    : Text(
                        "Burun=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_10_burun_latitude, endLongitude: roket_10_burun_longitude).toString().split(".")[0]} metre\nGövde=${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: roket_10_ana_latitude, endLongitude: roket_10_ana_longitude).toString().split(".")[0]} metre"),
                secondary: FaIcon(FontAwesomeIcons.rocket),
                controlAffinity: ListTileControlAffinity.platform,
                value: roket_10_boolen,
                onChanged: (bool value) {
                  setState(() {
                    roket_10_boolen = value;

                    if (value) {
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_burun,
                            marker_id: "id-19",
                            latitude: roket_10_burun_latitude,
                            longitude: roket_10_burun_longitude,
                            tag_name: "Roket-10 Burun"),
                      );
                      _markers.add(
                        marker_ready(
                            icon: mapMarker_govde,
                            marker_id: "id-20",
                            latitude: roket_10_ana_latitude,
                            longitude: roket_10_ana_longitude,
                            tag_name: "Roket-10 Gövde"),
                      );
                    } else {
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-19"));
                      _markers.remove(_markers.firstWhere(
                          (element) => element.markerId.value == "id-20"));
                    }
                  });
                },
                activeColor:  my_colors().yellow,
                checkColor: Colors.black,
              ),
              key != key_close
                  ? CheckboxListTile(
                      title: Text("arayıcı-1"),
                      subtitle: current_location_latitude == null
                          ? Text("hesaplanıyor...")
                          : Text(
                              "arayıcı:${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: searcher_1_latitude, endLongitude: searcher_1_longitude).toString().split(".")[0]} metre"),
                      secondary: FaIcon(FontAwesomeIcons.rocket),
                      controlAffinity: ListTileControlAffinity.platform,
                      value: searcher_1_boolen,
                      onChanged: (bool value) {
                        setState(() {
                          searcher_1_boolen = value;
                          if (value) {
                            _markers.add(
                              marker_ready(
                                  marker_id: "id-21",
                                  latitude: searcher_1_latitude,
                                  longitude: searcher_1_longitude,
                                  tag_name: "arayıcı-1"),
                            );
                          } else {
                            _markers.remove(_markers.firstWhere((element) =>
                                element.markerId.value == "id-21"));
                          }
                        });
                      },
                      activeColor:  my_colors().yellow,
                      checkColor: Colors.black,
                    )
                  : SizedBox(),
              key != key_close
                  ? CheckboxListTile(
                      title: Text("arayıcı-2"),
                      subtitle: current_location_latitude == null
                          ? Text("hesaplanıyor...")
                          : Text(
                              "arayıcı:${calculate_distance(startLatitude: current_location_latitude, startLongitude: current_location_longitude, endLatitude: searcher_2_latitude, endLongitude: searcher_2_longitude).toString().split(".")[0]} metre"),
                      secondary: FaIcon(FontAwesomeIcons.rocket),
                      controlAffinity: ListTileControlAffinity.platform,
                      value: searcher_2_boolen,
                      onChanged: (bool value) {
                        setState(() {
                          searcher_2_boolen = value;
                          if (value) {
                            _markers.add(
                              marker_ready(
                                  marker_id: "id-22",
                                  latitude: searcher_2_latitude,
                                  longitude: searcher_2_longitude,
                                  tag_name: "arayıcı-2"),
                            );
                          } else {
                            _markers.remove(_markers.firstWhere((element) =>
                                element.markerId.value == "id-22"));
                          }
                        });
                      },
                      activeColor: my_colors().yellow,
                      checkColor: Colors.black,
                    )
                  : SizedBox(),
            ],
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.rocket,
              color: Colors.black,
              size: MediaQuery.of(context).size.width * 35 / 411,
            ),
            title: Text("Manuel koordinat ayarla"),
            subtitle: Text(
                "İnternet bağlantısı olmadığı zaman manuel olarak koordinatları girebilirsin"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return SingleChildScrollView(
                      child: AlertDialog(
                        title: Text("Manuel koordinat girişi"),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton(
                                value: _dropdownValue,
                                items: [
                                  DropdownMenuItem(
                                    child: Text("roket-1"),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-2"),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-3"),
                                    value: 3,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-4"),
                                    value: 4,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-5"),
                                    value: 5,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-6"),
                                    value: 6,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-7"),
                                    value: 7,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-8"),
                                    value: 8,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-9"),
                                    value: 9,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("roket-10"),
                                    value: 10,
                                  )
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _dropdownValue = value;
                                    secilen_roket = "roket-$value";
                                    print(secilen_roket);
                                  });
                                },
                              ),
                            ],
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.]+')),
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.black,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Roket Burun latitude",
                              focusColor: Colors.black,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    MediaQuery.of(context).size.width *
                                        20 /
                                        411)),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.brown,
                                fontSize: MediaQuery.of(context).size.width *
                                    27 /
                                    411, //mediaquery ile düzenle
                                fontFamily: "bahnschrift",
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                manuel_burun_latitude_not_ready = value;
                              });
                            },
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.width * 20 / 411,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.]+')),
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.black,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Roket Burun longitude",
                              focusColor: Colors.black,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    MediaQuery.of(context).size.width *
                                        20 /
                                        411)),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.brown,
                                fontSize: MediaQuery.of(context).size.width *
                                    27 /
                                    411, //mediaquery ile düzenle
                                fontFamily: "bahnschrift",
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                manuel_burun_longitude_not_ready = value;
                              });
                            },
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.width * 20 / 411,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.]+')),
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.black,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Roket Gövde latitude",
                              focusColor: Colors.black,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    MediaQuery.of(context).size.width *
                                        20 /
                                        411)),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.brown,
                                fontSize: MediaQuery.of(context).size.width *
                                    27 /
                                    411, //mediaquery ile düzenle
                                fontFamily: "bahnschrift",
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                manuel_govde_latitude_not_ready = value;
                              });
                            },
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.width * 20 / 411,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.]+')),
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.black,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Roket Gövde longitude",
                              focusColor: Colors.black,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    MediaQuery.of(context).size.width *
                                        20 /
                                        411)),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.brown,
                                fontSize: MediaQuery.of(context).size.width *
                                    27 /
                                    411, //mediaquery ile düzenle
                                fontFamily: "bahnschrift",
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                manuel_govde_longitude_not_ready = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("İptal"),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    if (manuel_burun_latitude_not_ready !=
                                            null &&
                                        manuel_burun_longitude_not_ready !=
                                            null) {
                                      setState(() {
                                        manuel_burun_latitude_ready =
                                            double.parse(
                                                manuel_burun_latitude_not_ready);
                                        manuel_burun_longitude_ready =
                                            double.parse(
                                                manuel_burun_longitude_not_ready);
                                      });
                                    }
                                    if (manuel_govde_latitude_not_ready !=
                                            null &&
                                        manuel_govde_longitude_not_ready !=
                                            null) {
                                      setState(() {
                                        manuel_govde_latitude_ready =
                                            double.parse(
                                                manuel_govde_latitude_not_ready);
                                        manuel_govde_longitude_ready =
                                            double.parse(
                                                manuel_govde_longitude_not_ready);
                                        secilen_roket = secilen_roket;
                                      });
                                      Navigator.pop(context);
                                    }
                                    manuel_giris();
                                  },
                                  child: Text("tamamdır")),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.rocket,
              color: Colors.black,
              size: MediaQuery.of(context).size.width * 35 / 411,
            ),
            title: Text("Resetle"),
            subtitle: Text("Markerları resetlemek için kullanabilirsin"),
            onTap: () {
              reset_button();
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.rocket,
              color: Colors.black,
              size: MediaQuery.of(context).size.width * 35 / 411,
            ),
            title: Text("Çıkış Yap"),
            subtitle: Text("başka bir key girişi yapabilmek için çıkış yap."),
            onTap: () {
              setState(() {
                Get.to(() => welcome_screen());
                key = null;
                closed = true;
                Fluttertoast.showToast(msg: "Çıkış yapılıyor..");
              });
            },
          ),
        ],
      )),
      appBar: AppBar(
        backgroundColor: my_colors().grey_2,
        title: Text(
          key == searcher_1 || key == searcher_2 ? "$key" : "Takip",
          style: TextStyle(
            color: my_colors().yellow,
            fontSize: MediaQuery.of(context).size.width *
                27 /
                411, //mediaquery ile düzenle
            fontFamily: "bahnschrift",
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterSwitch(
                  activeColor: my_colors().orange_google,
                  toggleColor: my_colors().haki_green,
                  height: MediaQuery.of(context).size.width * 30 / 411,
                  showOnOff: true,
                  value: map_theme_is_normal,
                  onToggle: (value) {
                    setState(() {
                      map_theme_is_normal = value;
                    });
                  }),
              Text(
                map_theme_is_normal ? "normal" : "uydu",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 10 / 411),
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 15 / 411,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterSwitch(
                  activeColor: my_colors().orange_google,
                  toggleColor: my_colors().haki_green,
                  height: MediaQuery.of(context).size.width * 30 / 411,
                  showOnOff: true,
                  value: switch_status,
                  onToggle: (value) {
                    setState(() {
                      switch_status = value;
                    });
                  }),
              Text(
                "Manuel Mod",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 10 / 411),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              show_spinner();
              setState(() {
                refresh_button();
              });
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner_boolen,
        child: Stack(alignment: Alignment.centerRight, children: <Widget>[
          Center(
            child: GoogleMap(
              mapType: map_theme_is_normal ? MapType.normal : MapType.satellite,
              onMapCreated: _onMapCreated,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(38.399722, 33.706806),
                zoom: 7,
              ),
              myLocationEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
          SlidingUpPanel(
            color: my_colors().grey_2,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                MediaQuery.of(context).size.width * 50 / 411,
              ),
              topRight: Radius.circular(
                MediaQuery.of(context).size.width * 50 / 411,
              ),
            ),
            panel: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset(
                        "images/burun.png",
                        scale: MediaQuery.of(context).size.width * 10 / 411,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Roket no:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_kod
                                : selected_marker == "R2"
                                    ? roket_2_burun_kod
                                    : selected_marker == "R3"
                                        ? roket_3_burun_kod
                                        : selected_marker == "R4"
                                            ? roket_4_burun_kod
                                            : selected_marker == "R5"
                                                ? roket_5_burun_kod
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_kod
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_kod
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_kod
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_kod
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_kod
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "GPS saat:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_gps_saat
                                : selected_marker == "R2"
                                    ? roket_2_burun_gps_saat
                                    : selected_marker == "R3"
                                        ? roket_3_burun_gps_saat
                                        : selected_marker == "R4"
                                            ? roket_4_burun_gps_saat
                                            : selected_marker == "R5"
                                                ? roket_5_burun_gps_saat
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_gps_saat
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_gps_saat
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_gps_saat
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_gps_saat
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_gps_saat
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Latitude:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_latitude.toString()
                                : selected_marker == "R2"
                                    ? roket_2_burun_latitude.toString()
                                    : selected_marker == "R3"
                                        ? roket_3_burun_latitude.toString()
                                        : selected_marker == "R4"
                                            ? roket_4_burun_latitude.toString()
                                            : selected_marker == "R5"
                                                ? roket_5_burun_latitude
                                                    .toString()
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_latitude
                                                        .toString()
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_latitude
                                                            .toString()
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_latitude
                                                                .toString()
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_latitude
                                                                    .toString()
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_latitude
                                                                        .toString()
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Longitude:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_longitude.toString()
                                : selected_marker == "R2"
                                    ? roket_2_burun_longitude.toString()
                                    : selected_marker == "R3"
                                        ? roket_3_burun_longitude.toString()
                                        : selected_marker == "R4"
                                            ? roket_4_burun_longitude.toString()
                                            : selected_marker == "R5"
                                                ? roket_5_burun_longitude
                                                    .toString()
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_longitude
                                                        .toString()
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_longitude
                                                            .toString()
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_longitude
                                                                .toString()
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_longitude
                                                                    .toString()
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_longitude
                                                                        .toString()
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Uydu Sayısı:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_uydu_sayisi
                                : selected_marker == "R2"
                                    ? roket_2_burun_uydu_sayisi
                                    : selected_marker == "R3"
                                        ? roket_3_burun_uydu_sayisi
                                        : selected_marker == "R4"
                                            ? roket_4_burun_uydu_sayisi
                                            : selected_marker == "R5"
                                                ? roket_5_burun_uydu_sayisi
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_uydu_sayisi
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_uydu_sayisi
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_uydu_sayisi
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_uydu_sayisi
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_uydu_sayisi
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Yükseklik:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_yukseklik + " m"
                                : selected_marker == "R2"
                                    ? roket_2_burun_yukseklik + " m"
                                    : selected_marker == "R3"
                                        ? roket_3_burun_yukseklik + " m"
                                        : selected_marker == "R4"
                                            ? roket_4_burun_yukseklik + " m"
                                            : selected_marker == "R5"
                                                ? roket_5_burun_yukseklik + " m"
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_yukseklik +
                                                        " m"
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_yukseklik +
                                                            " m"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_yukseklik +
                                                                " m"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_yukseklik +
                                                                    " m"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_yukseklik +
                                                                        " m"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "x açısı:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_x_aci + " °"
                                : selected_marker == "R2"
                                    ? roket_2_burun_x_aci + " °"
                                    : selected_marker == "R3"
                                        ? roket_3_burun_x_aci + " °"
                                        : selected_marker == "R4"
                                            ? roket_4_burun_x_aci + " °"
                                            : selected_marker == "R5"
                                                ? roket_5_burun_x_aci + " °"
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_x_aci + " °"
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_x_aci +
                                                            " °"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_x_aci +
                                                                " °"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_x_aci +
                                                                    " °"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_x_aci +
                                                                        " °"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "y açısı:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_y_aci + " °"
                                : selected_marker == "R2"
                                    ? roket_2_burun_y_aci + " °"
                                    : selected_marker == "R3"
                                        ? roket_3_burun_y_aci + " °"
                                        : selected_marker == "R4"
                                            ? roket_4_burun_y_aci + " °"
                                            : selected_marker == "R5"
                                                ? roket_5_burun_y_aci + " °"
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_y_aci + " °"
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_y_aci +
                                                            " °"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_y_aci +
                                                                " °"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_y_aci +
                                                                    " °"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_y_aci +
                                                                        " °"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Sıcaklık:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_burun_sicaklik + " °C"
                                : selected_marker == "R2"
                                    ? roket_2_burun_sicaklik + " °C"
                                    : selected_marker == "R3"
                                        ? roket_3_burun_sicaklik + " °C"
                                        : selected_marker == "R4"
                                            ? roket_4_burun_sicaklik + " °C"
                                            : selected_marker == "R5"
                                                ? roket_5_burun_sicaklik + " °C"
                                                : selected_marker == "R6"
                                                    ? roket_6_burun_sicaklik +
                                                        " °C"
                                                    : selected_marker == "R7"
                                                        ? roket_7_burun_sicaklik +
                                                            " °C"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_burun_sicaklik +
                                                                " °C"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_burun_sicaklik +
                                                                    " °C"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_burun_sicaklik +
                                                                        " °C"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Pil durumu:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? "% " + roket_1_burun_pil_durumu
                                : selected_marker == "R2"
                                    ? "% " + roket_2_burun_pil_durumu
                                    : selected_marker == "R3"
                                        ? "% " + roket_3_burun_pil_durumu
                                        : selected_marker == "R4"
                                            ? "% " + roket_4_burun_pil_durumu
                                            : selected_marker == "R5"
                                                ? "% " +
                                                    roket_5_burun_pil_durumu
                                                : selected_marker == "R6"
                                                    ? "% " +
                                                        roket_6_burun_pil_durumu
                                                    : selected_marker == "R7"
                                                        ? "% " +
                                                            roket_7_burun_pil_durumu
                                                        : selected_marker ==
                                                                "R8"
                                                            ? "% " +
                                                                roket_8_burun_pil_durumu
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? "% " +
                                                                    roket_9_burun_pil_durumu
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? "% " +
                                                                        roket_10_burun_pil_durumu
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 10 / 411,
                      ),
                    ]),
                Container(
                  width: MediaQuery.of(context).size.width * 3 / 411,
                  height: double.maxFinite,
                  color: Colors.black,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset(
                        "images/govde.png",
                        scale: MediaQuery.of(context).size.width * 4 / 411,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Roket no:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_kod
                                : selected_marker == "R2"
                                    ? roket_2_ana_kod
                                    : selected_marker == "R3"
                                        ? roket_3_ana_kod
                                        : selected_marker == "R4"
                                            ? roket_4_ana_kod
                                            : selected_marker == "R5"
                                                ? roket_5_ana_kod
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_kod
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_kod
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_kod
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_kod
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_kod
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "GPS saat:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_gps_saat
                                : selected_marker == "R2"
                                    ? roket_2_ana_gps_saat
                                    : selected_marker == "R3"
                                        ? roket_3_ana_gps_saat
                                        : selected_marker == "R4"
                                            ? roket_4_ana_gps_saat
                                            : selected_marker == "R5"
                                                ? roket_5_ana_gps_saat
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_gps_saat
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_gps_saat
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_gps_saat
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_gps_saat
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_gps_saat
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Latitude:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_latitude.toString()
                                : selected_marker == "R2"
                                    ? roket_2_ana_latitude.toString()
                                    : selected_marker == "R3"
                                        ? roket_3_ana_latitude.toString()
                                        : selected_marker == "R4"
                                            ? roket_4_ana_latitude.toString()
                                            : selected_marker == "R5"
                                                ? roket_5_ana_latitude
                                                    .toString()
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_latitude
                                                        .toString()
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_latitude
                                                            .toString()
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_latitude
                                                                .toString()
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_latitude
                                                                    .toString()
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_latitude
                                                                        .toString()
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Longitude:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_longitude.toString()
                                : selected_marker == "R2"
                                    ? roket_2_ana_longitude.toString()
                                    : selected_marker == "R3"
                                        ? roket_3_ana_longitude.toString()
                                        : selected_marker == "R4"
                                            ? roket_4_ana_longitude.toString()
                                            : selected_marker == "R5"
                                                ? roket_5_ana_longitude
                                                    .toString()
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_longitude
                                                        .toString()
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_longitude
                                                            .toString()
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_longitude
                                                                .toString()
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_longitude
                                                                    .toString()
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_longitude
                                                                        .toString()
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Uydu Sayısı:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_uydu_sayisi
                                : selected_marker == "R2"
                                    ? roket_2_ana_uydu_sayisi
                                    : selected_marker == "R3"
                                        ? roket_3_ana_uydu_sayisi
                                        : selected_marker == "R4"
                                            ? roket_4_ana_uydu_sayisi
                                            : selected_marker == "R5"
                                                ? roket_5_ana_uydu_sayisi
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_uydu_sayisi
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_uydu_sayisi
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_uydu_sayisi
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_uydu_sayisi
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_uydu_sayisi
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Yükseklik:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_yukseklik + " m"
                                : selected_marker == "R2"
                                    ? roket_2_ana_yukseklik + " m"
                                    : selected_marker == "R3"
                                        ? roket_3_ana_yukseklik + " m"
                                        : selected_marker == "R4"
                                            ? roket_4_ana_yukseklik + " m"
                                            : selected_marker == "R5"
                                                ? roket_5_ana_yukseklik + " m"
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_yukseklik +
                                                        " m"
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_yukseklik +
                                                            " m"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_yukseklik +
                                                                " m"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_yukseklik +
                                                                    " m"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_yukseklik +
                                                                        " m"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "x açısı:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_x_aci + " °"
                                : selected_marker == "R2"
                                    ? roket_2_ana_x_aci + " °"
                                    : selected_marker == "R3"
                                        ? roket_3_ana_x_aci + " °"
                                        : selected_marker == "R4"
                                            ? roket_4_ana_x_aci + " °"
                                            : selected_marker == "R5"
                                                ? roket_5_ana_x_aci + " °"
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_x_aci + " °"
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_x_aci +
                                                            " °"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_x_aci +
                                                                " °"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_x_aci +
                                                                    " °"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_x_aci +
                                                                        " °"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "y açısı:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_y_aci + " °"
                                : selected_marker == "R2"
                                    ? roket_2_ana_y_aci + " °"
                                    : selected_marker == "R3"
                                        ? roket_3_ana_y_aci + " °"
                                        : selected_marker == "R4"
                                            ? roket_4_ana_y_aci + " °"
                                            : selected_marker == "R5"
                                                ? roket_5_ana_y_aci + " °"
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_y_aci + " °"
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_y_aci +
                                                            " °"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_y_aci +
                                                                " °"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_y_aci +
                                                                    " °"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_y_aci +
                                                                        " °"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Sıcaklık:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_sicaklik + " °C"
                                : selected_marker == "R2"
                                    ? roket_2_ana_sicaklik + " °C"
                                    : selected_marker == "R3"
                                        ? roket_3_ana_sicaklik + " °C"
                                        : selected_marker == "R4"
                                            ? roket_4_ana_sicaklik + " °C"
                                            : selected_marker == "R5"
                                                ? roket_5_ana_sicaklik + " °C"
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_sicaklik +
                                                        " °C"
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_sicaklik +
                                                            " °C"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_sicaklik +
                                                                " °C"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_sicaklik +
                                                                    " °C"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_sicaklik +
                                                                        " °C"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Patlama-1:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_patlama_durumu_1 == "+"
                                    ? "gerçekleşti"
                                    : "gerçekleşmedi"
                                : selected_marker == "R2"
                                    ? roket_2_ana_patlama_durumu_1 == "+"
                                        ? "gerçekleşti"
                                        : "gerçekleşmedi"
                                    : selected_marker == "R3"
                                        ? roket_3_ana_patlama_durumu_1 == "+"
                                            ? "gerçekleşti"
                                            : "gerçekleşmedi"
                                        : selected_marker == "R4"
                                            ? roket_4_ana_patlama_durumu_1 ==
                                                    "+"
                                                ? "gerçekleşti"
                                                : "gerçekleşmedi"
                                            : selected_marker == "R5"
                                                ? roket_5_ana_patlama_durumu_1 ==
                                                        "+"
                                                    ? "gerçekleşti"
                                                    : "gerçekleşmedi"
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_patlama_durumu_1 ==
                                                            "+"
                                                        ? "gerçekleşti"
                                                        : "gerçekleşmedi"
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_patlama_durumu_1 ==
                                                                "+"
                                                            ? "gerçekleşti"
                                                            : "gerçekleşmedi"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_patlama_durumu_1 ==
                                                                    "+"
                                                                ? "gerçekleşti"
                                                                : "gerçekleşmedi"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_patlama_durumu_1 ==
                                                                        "+"
                                                                    ? "gerçekleşti"
                                                                    : "gerçekleşmedi"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_patlama_durumu_1 ==
                                                                            "+"
                                                                        ? "gerçekleşti"
                                                                        : "gerçekleşmedi"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Patlama-2:",
                            style: TextStyle(
                              color: my_colors().grey,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                          Text(
                            selected_marker == "R1"
                                ? roket_1_ana_patlama_durumu_2 == "+"
                                    ? "gerçekleşti"
                                    : "gerçekleşmedi"
                                : selected_marker == "R2"
                                    ? roket_2_ana_patlama_durumu_2 == "+"
                                        ? "gerçekleşti"
                                        : "gerçekleşmedi"
                                    : selected_marker == "R3"
                                        ? roket_3_ana_patlama_durumu_2 == "+"
                                            ? "gerçekleşti"
                                            : "gerçekleşmedi"
                                        : selected_marker == "R4"
                                            ? roket_4_ana_patlama_durumu_2 ==
                                                    "+"
                                                ? "gerçekleşti"
                                                : "gerçekleşmedi"
                                            : selected_marker == "R5"
                                                ? roket_5_ana_patlama_durumu_2 ==
                                                        "+"
                                                    ? "gerçekleşti"
                                                    : "gerçekleşmedi"
                                                : selected_marker == "R6"
                                                    ? roket_6_ana_patlama_durumu_2 ==
                                                            "+"
                                                        ? "gerçekleşti"
                                                        : "gerçekleşmedi"
                                                    : selected_marker == "R7"
                                                        ? roket_7_ana_patlama_durumu_2 ==
                                                                "+"
                                                            ? "gerçekleşti"
                                                            : "gerçekleşmedi"
                                                        : selected_marker ==
                                                                "R8"
                                                            ? roket_8_ana_patlama_durumu_2 ==
                                                                    "+"
                                                                ? "gerçekleşti"
                                                                : "gerçekleşmedi"
                                                            : selected_marker ==
                                                                    "R9"
                                                                ? roket_9_ana_patlama_durumu_2 ==
                                                                        "+"
                                                                    ? "gerçekleşti"
                                                                    : "gerçekleşmedi"
                                                                : selected_marker ==
                                                                        "R10"
                                                                    ? roket_10_ana_patlama_durumu_2 ==
                                                                            "+"
                                                                        ? "gerçekleşti"
                                                                        : "gerçekleşmedi"
                                                                    : "...",
                            style: TextStyle(
                              color: my_colors().yellow,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 15 / 411,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 10 / 411,
                      ),
                    ]),
              ],
            ),
            collapsed: Container(
              color: my_colors().grey,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.arrowUp,
                      size: MediaQuery.of(context).size.width * 50 / 411,
                      color: Colors.black,
                    ),
                    Text(
                      selected_marker == "R1"
                          ? "Roket-1"
                          : selected_marker == "R2"
                              ? "Roket-2"
                              : selected_marker == "R3"
                                  ? "Roket-3"
                                  : selected_marker == "R4"
                                      ? "Roket-4"
                                      : selected_marker == "R5"
                                          ? "Roket-5"
                                          : selected_marker == "R6"
                                              ? "Roket-6"
                                              : selected_marker == "R7"
                                                  ? "Roket-7"
                                                  : selected_marker == "R8"
                                                      ? "Roket-8"
                                                      : selected_marker == "R9"
                                                          ? "Roket-9"
                                                          : selected_marker ==
                                                                  "R10"
                                                              ? "Roket-10"
                                                              : "Harita üzerinden roket seçiniz...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 18 / 411,
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.arrowUp,
                      size: MediaQuery.of(context).size.width * 50 / 411,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void reset_button() async {
    setState(() {
      _markers.clear();
      roket_1_boolen = false;
      roket_2_boolen = false;
      roket_3_boolen = false;
      roket_4_boolen = false;
      roket_5_boolen = false;
      roket_6_boolen = false;
      roket_7_boolen = false;
      roket_8_boolen = false;
      roket_9_boolen = false;
      roket_10_boolen = false;
      searcher_1_boolen = false;
      searcher_2_boolen = false;

      manuel_burun_latitude_not_ready = null;
      manuel_burun_longitude_not_ready = null;

      manuel_burun_latitude_ready = null;
      manuel_burun_longitude_ready = null;

      manuel_govde_latitude_not_ready = null;
      manuel_govde_longitude_not_ready = null;

      manuel_govde_latitude_ready = null;
      manuel_govde_longitude_ready = null;

      secilen_roket = null;

      selected_marker = null;
    });
  }
}

class Utils {
  static String mapStyle = '''
  [
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.local",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
  ''';
}
