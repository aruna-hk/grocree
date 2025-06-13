import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

// Shipment model with status and last known position
class Shipment {
  final String id;
  final String title;
  final String status;
  final LatLng from;
  final LatLng to;
  final String cargoType;
  final String cargoSize;
  final DateTime createdAt;
  final LatLng? lastKnownLocation;

  Shipment({
    required this.id,
    required this.title,
    required this.status,
    required this.from,
    required this.to,
    required this.cargoType,
    required this.cargoSize,
    required this.createdAt,
    this.lastKnownLocation,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    final from = json['from'];
    final to = json['to'];
    return Shipment(
      id: json['_id'] ?? '',
      title: 'From (${from['lat'].toStringAsFixed(3)},${from['lng'].toStringAsFixed(3)}) → (${to['lat'].toStringAsFixed(3)},${to['lng'].toStringAsFixed(3)})',
      status: json['status'],
      from: LatLng((from['lat'] as num).toDouble(), (from['lng'] as num).toDouble()),
      to: LatLng((to['lat'] as num).toDouble(), (to['lng'] as num).toDouble()),
      cargoType: json['cargoType'],
      cargoSize: json['cargoSize'],
      createdAt: DateTime.parse(json['createdAt']),
      lastKnownLocation: json['lastKnownLocation'] != null
          ? LatLng(
              (json['lastKnownLocation']['lat'] as num).toDouble(),
              (json['lastKnownLocation']['lng'] as num).toDouble())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'from': {'lat': from.latitude, 'lng': from.longitude},
        'to': {'lat': to.latitude, 'lng': to.longitude},
        'cargoType': cargoType,
        'cargoSize': cargoSize,
      };

  Shipment copyWith({
    String? id,
    String? title,
    String? status,
    LatLng? from,
    LatLng? to,
    String? cargoType,
    String? cargoSize,
    DateTime? createdAt,
    LatLng? lastKnownLocation,
  }) {
    return Shipment(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      from: from ?? this.from,
      to: to ?? this.to,
      cargoType: cargoType ?? this.cargoType,
      cargoSize: cargoSize ?? this.cargoSize,
      createdAt: createdAt ?? this.createdAt,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
    );
  }
}

class ShipperHomePage extends StatefulWidget {
  @override
  State<ShipperHomePage> createState() => _ShipperHomePageState();
}

class _ShipperHomePageState extends State<ShipperHomePage> {
  List<Shipment> shipments = [];
  int? liveTrackIndex;
  bool showBookingPopup = false;
  bool showExtraInfoDialog = false;
  String activeBookingField = 'from';
  LatLng bookingMarkerPosition = LatLng(-1.2921, 36.8219);
  LatLng? fromLocation;
  LatLng? toLocation;

  String? cargoType;
  String? cargoSize;
  bool showSubmissionConfirmation = false;

  LatLng? userLocation = LatLng(-1.2921, 36.8219); // Nairobi

  final String apiBase = 'http://localhost:5000/api/shipments';

  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool showUserDropdown = false;

  // Featured product and catalogue/shop state
  final featuredProduct = {
    'company': 'Mega Logistics',
    'productName': 'Smart Pallet Tracker',
    'image':
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=500&q=80',
    'description': 'Track your shipments with real-time IoT sensors.',
    'companyId': 'company_1',
    'price': 'KES 18,000'
  };

  final Map<String, List<Map<String, String>>> companyCatalogues = {
    'company_1': [
      {
        'productName': 'Smart Pallet Tracker',
        'image':
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=200&q=80',
        'description': 'Track your shipments with real-time IoT sensors.',
      },
      {
        'productName': 'RFID Container Lock',
        'image':
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=200&q=80',
        'description': 'Secure your cargo with RFID-enabled locks.',
      },
    ],
    'company_2': [
      {
        'productName': 'Eco Shipping Box',
        'image':
            'https://images.unsplash.com/photo-1465101162946-4377e57745c3?auto=format&fit=crop&w=200&q=80',
        'description': 'Sustainable, reusable shipping containers.',
      },
    ],
  };

  final List<Map<String, String>> shops = [
    {
      'company': 'Mega Logistics',
      'companyId': 'company_1',
      'logo':
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=80&q=80'
    },
    {
      'company': 'Eco Freight',
      'companyId': 'company_2',
      'logo':
          'https://images.unsplash.com/photo-1465101162946-4377e57745c3?auto=format&fit=crop&w=80&q=80'
    },
  ];

  bool showCatalogueModal = false;
  String? catalogueCompanyId;
  bool showShopModal = false;
  String? viewingInventoryCompanyId;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    fetchShipments();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _wsChannel?.sink.close(ws_status.goingAway);
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('shipment_channel', 'Shipment Alerts',
            importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final wsUrl = Uri.parse('ws://localhost:8080?token=$token');

    _wsChannel = WebSocketChannel.connect(wsUrl);
    _wsSubscription = _wsChannel!.stream.listen((event) {
      final Map<String, dynamic> data = json.decode(event);
      if (data['type'] == 'shipment_update') {
        final updated = Shipment.fromJson(data['shipment']);
        final index = shipments.indexWhere((s) => s.id == updated.id);
        if (index != -1) {
          setState(() {
            shipments[index] = updated;
          });
          if (data['proximity'] == true) {
            _showNotification("Shipment Proximity Alert",
                "Shipment ${updated.title} is near destination.");
          }
          if (shipments[index].status != updated.status) {
            _showNotification("Shipment Status Updated",
                "Shipment ${updated.title} status is now ${updated.status}");
          }
        } else {
          setState(() {
            shipments.insert(0, updated);
          });
          _showNotification("New Shipment", "A new shipment has been added.");
        }
      }
    }, onError: (e) {
      Future.delayed(const Duration(seconds: 5), _connectWebSocket);
    }, onDone: () {
      Future.delayed(const Duration(seconds: 5), _connectWebSocket);
    });
  }

  Future<void> fetchShipments() async {
    try {
      final response = await http.get(Uri.parse(apiBase));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shipments = data.map((e) => Shipment.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> submitShipmentRequest() async {
    if (fromLocation == null || toLocation == null || cargoType == null || cargoSize == null) return;
    final data = {
      'from': {'lat': fromLocation!.latitude, 'lng': fromLocation!.longitude},
      'to': {'lat': toLocation!.latitude, 'lng': toLocation!.longitude},
      'cargoType': cargoType,
      'cargoSize': cargoSize
    };
    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString('auth_token') ?? '';
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/shipments/"),
        headers: {'Content-Type': 'application/json', 'authorization': "Bearer ${_token}"},
        body: json.encode(data),
      );
      if (response.statusCode == 201) {
        final newShipment = Shipment.fromJson(json.decode(response.body));
        setState(() {
          shipments.insert(0, newShipment);
          showSubmissionConfirmation = true;
          fromLocation = null;
          toLocation = null;
          cargoType = null;
          cargoSize = null;
        });
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          showSubmissionConfirmation = false;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double userIconSize = 50.0; // Increased user icon space
    final double userIconRightMargin = 12.0;
    final double margin = 8.0;
    final bool isSmall = deviceWidth < 540;
    
    // Calculate available width for the shipment row
    final double shipmentRowWidth = deviceWidth - userIconSize - userIconRightMargin - margin * 3;
    
    final double fontSize = 12.0;
    final double popupWidth = deviceWidth * 0.75 < 190 ? deviceWidth * 0.75 : 190;

    LatLng mapFocus = _getMainMapCenter();
    if (liveTrackIndex != null && shipments.isNotEmpty && shipments[liveTrackIndex!].lastKnownLocation != null) {
      mapFocus = shipments[liveTrackIndex!].lastKnownLocation!;
    }

    // Feature/Request grid ratio for bottom section
    final int featureFlex = 5;
    final int requestFlex = 1;
    final double featureWidgetHeight = isSmall ? 158 : 220;
    final double requestBtnHeight = isSmall ? 44 : 58;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: mapFocus,
                initialZoom: liveTrackIndex != null ? 8.5 : 6.5,
                onTap: (tapPos, latlng) {
                  if (showBookingPopup) {
                    setState(() {
                      bookingMarkerPosition = latlng;
                      if (activeBookingField == 'from') {
                        fromLocation = latlng;
                      } else {
                        toLocation = latlng;
                      }
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (liveTrackIndex != null && shipments.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      if (shipments[liveTrackIndex!].lastKnownLocation != null)
                        Marker(
                          width: 36,
                          height: 36,
                          point: shipments[liveTrackIndex!].lastKnownLocation!,
                          child: Icon(Icons.local_shipping, size: 32, color: Colors.blue),
                        ),
                      if (userLocation != null)
                        Marker(
                          width: 32,
                          height: 32,
                          point: userLocation!,
                          child: Icon(Icons.person_pin_circle, size: 26, color: Colors.green),
                        ),
                    ],
                  ),
                if (showBookingPopup)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 36,
                        height: 36,
                        point: bookingMarkerPosition,
                        child: Icon(Icons.location_pin, size: 36, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Top Row: Shipments list in a horizontal row
          if (!showBookingPopup && liveTrackIndex == null)
            Positioned(
              top: margin,
              left: margin,
              right: userIconSize + userIconRightMargin + margin,
              child: Container(
                height: 70, // Fixed height for the row
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.93),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 7)],
                ),
                child: Row(
                  children: [
                    // Title/Label section (flex: 1)
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Shipments",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ),
                    ),
                    // Shipment list section (flex: 5)
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: _buildShipmentRow(context, fontSize: fontSize, isSmall: isSmall),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Top user icon (dropdown on click)
          Positioned(
            top: 6,
            right: 12,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showUserDropdown = !showUserDropdown;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 21,
                    child: Icon(Icons.person, color: Colors.black, size: 20),
                  ),
                ),
                if (showUserDropdown)
                  Positioned(
                    top: 45,
                    right: 0,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      child: Container(
                        width: 152,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  showUserDropdown = false;
                                });
                                _showShipmentHistory(context);
                              },
                              icon: Icon(Icons.history, color: Colors.blue),
                              label: Text('Shipment History'),
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  showUserDropdown = false;
                                });
                              },
                              icon: Icon(Icons.settings, color: Colors.indigo),
                              label: Text('Account'),
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade300),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  showUserDropdown = false;
                                });
                                _logout(context);
                              },
                              icon: Icon(Icons.logout, color: Colors.redAccent),
                              label: Text('Logout', style: TextStyle(color: Colors.redAccent)),
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Live Tracking Strip
          if (liveTrackIndex != null && shipments.isNotEmpty)
            _buildLiveTrackingStrip(context, fontSize: fontSize + 1),

          // 5. Booking popup
          if (showBookingPopup)
            Positioned(
              bottom: 12,
              right: 10,
              child: _buildBookingPopup(context, popupWidth: popupWidth, fontSize: fontSize),
            ),

          // 6. Extra Info Dialog
          if (showExtraInfoDialog)
            _buildExtraInfoDialog(context, fontSize: fontSize, popupWidth: popupWidth + 60),

          // 7. Submission confirmation
          if (showSubmissionConfirmation)
            _buildSubmissionConfirmation(context),

          // 8. Modal for catalogue/shop/inventory
          if (showCatalogueModal && catalogueCompanyId != null)
            _buildCatalogueModal(context, catalogueCompanyId!),
          if (showShopModal)
            _buildShopModal(context),
          if (viewingInventoryCompanyId != null)
            _buildVendorInventoryModal(context, viewingInventoryCompanyId!),

          // 9. Bottom: Feature Product (left) and Request Button (right) - UNCHANGED
          if (!showBookingPopup && liveTrackIndex == null)
            Positioned(
              bottom: isSmall ? 8 : 28,
              left: margin,
              right: margin,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Feature Product (wider, taller, background image, info overlay)
                  Expanded(
                    flex: featureFlex,
                    child: SizedBox(
                      height: featureWidgetHeight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            catalogueCompanyId = featuredProduct['companyId'];
                            showCatalogueModal = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            image: DecorationImage(
                              image: NetworkImage(featuredProduct['image']!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.48), BlendMode.darken),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(2, 8),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 20,
                                top: 18,
                                right: 18,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=80&q=80'
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            featuredProduct['company']!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 21,
                                              shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            featuredProduct['productName']!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 24,
                                bottom: 26,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.62),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    featuredProduct['price'] ?? '',
                                    style: TextStyle(
                                      color: Colors.yellow[200],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                              // More Button
                              Positioned(
                                right: 18,
                                bottom: 22,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    backgroundColor: Colors.white.withOpacity(0.92),
                                    minimumSize: Size(0, 34),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: Icon(Icons.store_mall_directory, size: 18, color: Colors.indigo),
                                  label: Text(
                                    "More Shops",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showShopModal = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmall ? 7 : 20),
                  // Request Shipment Button (right, smaller, bold, no "+", max word wrapping)
                  Expanded(
                    flex: requestFlex,
                    child: SizedBox(
                      height: featureWidgetHeight,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 90,
                              maxWidth: isSmall ? 120 : 155,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: requestBtnHeight,
                              child: ElevatedButton(
                                child: Text(
                                  "Request Shipment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmall ? 14 : 17,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: isSmall ? 8 : 14, horizontal: 6),
                                ),
                                onPressed: () {
                                  setState(() {
                                    showBookingPopup = true;
                                    activeBookingField = 'from';
                                    bookingMarkerPosition = fromLocation ?? LatLng(-1.2921, 36.8219);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // NEW: Horizontal shipment row
  Widget _buildShipmentRow(BuildContext context, {required double fontSize, bool isSmall = false}) {
    if (shipments.isEmpty) {
      return Center(child: Text('No shipment requests yet.', style: TextStyle(fontSize: fontSize + 2)));
    }
    
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: shipments.length,
      separatorBuilder: (_, __) => SizedBox(width: 10),
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        Color color;
        IconData icon;
        switch (shipment.status) {
          case "Pending":
            color = Colors.orange;
            icon = Icons.timelapse;
            break;
          case "In Transit":
            color = Colors.blue;
            icon = Icons.local_shipping;
            break;
          default:
            color = Colors.grey;
            icon = Icons.assignment_late;
        }
        
        return GestureDetector(
          onTap: shipment.status == "In Transit"
              ? () {
                  setState(() {
                    liveTrackIndex = index;
                  });
                }
              : null,
          child: Container(
            width: 180, // Fixed width for each shipment card
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color,
                width: shipment.status == "In Transit" ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    SizedBox(width: 6),
                    Text(
                      shipment.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  shipment.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: fontSize - 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShipmentList(BuildContext context, {required double fontSize, bool isSmall = false}) {
    if (shipments.isEmpty) {
      return Center(child: Text('No shipment requests yet.', style: TextStyle(fontSize: fontSize + 2)));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: shipments.length,
      separatorBuilder: (_, __) => SizedBox(height: isSmall ? 4 : 8),
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        Color color;
        IconData icon;
        switch (shipment.status) {
          case "Pending":
            color = Colors.orange;
            icon = Icons.timelapse;
            break;
          case "In Transit":
            color = Colors.blue;
            icon = Icons.local_shipping;
            break;
          default:
            color = Colors.grey;
            icon = Icons.assignment_late;
        }
        final isPending = shipment.status == "Pending";
        return GestureDetector(
          onTap: shipment.status == "In Transit"
              ? () {
                  setState(() {
                    liveTrackIndex = index;
                  });
                }
              : null,
          child: AnimatedOpacity(
            opacity: shipment.status == "In Transit" ? 1 : 0.92,
            duration: Duration(milliseconds: 200),
            child: Container(
              constraints: BoxConstraints(
                  minHeight: isSmall ? 34 : 40,
                  maxHeight: isPending ? (isSmall ? 38 : 44) : (isSmall ? 48 : 54)),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: isSmall ? 5 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color,
                  width: shipment.status == "In Transit" ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: isSmall ? 16 : 18),
                  SizedBox(width: isSmall ? 4 : 7),
                  Expanded(
                    child: Text(
                      shipment.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: isSmall ? 2 : 5),
                  Text(
                    shipment.status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveTrackingStrip(BuildContext context, {required double fontSize}) {
    final shipment = shipments[liveTrackIndex!];
    final location = shipment.lastKnownLocation;
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.93),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => setState(() => liveTrackIndex = null),
                child: Icon(Icons.arrow_back, color: Colors.blue, size: fontSize + 8),
              ),
              SizedBox(width: 8),
              Icon(Icons.local_shipping, color: Colors.blue, size: fontSize + 5),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  shipment.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize + 1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 5),
              if (location != null)
                Text(
                  "${location.latitude.toStringAsFixed(3)},${location.longitude.toStringAsFixed(3)}",
                  style: TextStyle(color: Colors.blueGrey, fontSize: fontSize - 1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingPopup(BuildContext context, {required double popupWidth, required double fontSize}) {
    return Material(
      elevation: 14,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: popupWidth,
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniField(
              label: "FROM",
              selected: activeBookingField == 'from',
              value: fromLocation != null
                  ? "${fromLocation!.latitude.toStringAsFixed(3)},${fromLocation!.longitude.toStringAsFixed(3)}"
                  : "",
              onTap: () {
                setState(() {
                  activeBookingField = 'from';
                  bookingMarkerPosition = fromLocation ?? LatLng(-1.2921, 36.8219);
                });
              },
              fontSize: fontSize,
            ),
            SizedBox(height: 5),
            _miniField(
              label: "TO",
              selected: activeBookingField == 'to',
              value: toLocation != null
                  ? "${toLocation!.latitude.toStringAsFixed(3)},${toLocation!.longitude.toStringAsFixed(3)}"
                  : "",
              onTap: () {
                setState(() {
                  activeBookingField = 'to';
                  bookingMarkerPosition = toLocation ?? LatLng(-1.2921, 36.8219);
                });
              },
              fontSize: fontSize,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (fromLocation != null && toLocation != null)
                        ? () {
                            setState(() {
                              showBookingPopup = false;
                              showExtraInfoDialog = true;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      textStyle: TextStyle(fontSize: fontSize + 1),
                      minimumSize: Size(0, 32),
                    ),
                    child: Text("Submit"),
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.close, size: fontSize + 7),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      showBookingPopup = false;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _miniField({
    required String label,
    required bool selected,
    required String value,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey[400]!,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? Colors.blue : Colors.grey,
              size: fontSize + 5,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 2,
                color: selected ? Colors.blue : Colors.black87,
              ),
            ),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: fontSize + 1, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraInfoDialog(BuildContext context, {required double fontSize, required double popupWidth}) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => setState(() => showExtraInfoDialog = false),
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        Center(
          child: Material(
            elevation: 18,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: popupWidth,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Shipment Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize + 6,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    value: cargoType,
                    decoration: InputDecoration(
                      labelText: "Type (Cargo/Person)",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    items: [
                      DropdownMenuItem(value: "cargo", child: Text("Cargo", style: TextStyle(fontSize: fontSize + 2))),
                      DropdownMenuItem(value: "person", child: Text("Person Pickup", style: TextStyle(fontSize: fontSize + 2))),
                    ],
                    onChanged: (v) => setState(() => cargoType = v),
                  ),
                  SizedBox(height: 10),
                  if (cargoType == "cargo")
                    DropdownButtonFormField<String>(
                      value: cargoSize,
                      decoration: InputDecoration(
                        labelText: "Cargo Size",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      items: [
                        DropdownMenuItem(value: "small", child: Text("Small (Parcel/Box)", style: TextStyle(fontSize: fontSize + 2))),
                        DropdownMenuItem(value: "medium", child: Text("Medium (Pallet)", style: TextStyle(fontSize: fontSize + 2))),
                        DropdownMenuItem(value: "large", child: Text("Large (Truckload)", style: TextStyle(fontSize: fontSize + 2))),
                      ],
                      onChanged: (v) => setState(() => cargoSize = v),
                    ),
                  if (cargoType == "person")
                    DropdownButtonFormField<String>(
                      value: cargoSize,
                      decoration: InputDecoration(
                        labelText: "Pickup Size",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      items: [
                        DropdownMenuItem(value: "1", child: Text("1 Person", style: TextStyle(fontSize: fontSize + 2))),
                        DropdownMenuItem(value: "2", child: Text("2 People", style: TextStyle(fontSize: fontSize + 2))),
                        DropdownMenuItem(value: "4", child: Text("4 People", style: TextStyle(fontSize: fontSize + 2))),
                        DropdownMenuItem(value: "7", child: Text("7+ Van", style: TextStyle(fontSize: fontSize + 2))),
                      ],
                      onChanged: (v) => setState(() => cargoSize = v),
                    ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      textStyle: TextStyle(fontSize: fontSize + 3),
                      minimumSize: Size(0, 36),
                      padding: EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    onPressed: (cargoType != null && ((cargoType == "cargo" && cargoSize != null) || (cargoType == "person" && cargoSize != null)))
                        ? () async {
                            setState(() => showExtraInfoDialog = false);
                            await submitShipmentRequest();
                          }
                        : null,
                    child: Text("Send Request"),
                  ),
                  SizedBox(height: 6),
                  TextButton(
                    onPressed: () => setState(() => showExtraInfoDialog = false),
                    child: Text("Cancel"),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionConfirmation(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black38,
          ),
        ),
        Center(
          child: Material(
            elevation: 16,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 15),
                  Text(
                    "Request Sent!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green[800]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueModal(BuildContext context, String companyId) {
    final products = companyCatalogues[companyId] ?? [];
    final companyName = shops.firstWhere((s) => s['companyId'] == companyId, orElse: () => {'company': 'Company'})['company']!;
    return _buildModalBackdrop(
      context,
      child: Container(
        width: 420,
        constraints: BoxConstraints(maxWidth: 420),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('$companyName Catalogue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      showCatalogueModal = false;
                      catalogueCompanyId = null;
                    });
                  },
                )
              ],
            ),
            Divider(),
            ...products.map((prod) => ListTile(
                  leading: Image.network(prod['image']!, width: 42, height: 42, fit: BoxFit.cover),
                  title: Text(prod['productName']!, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(prod['description']!),
                  onTap: () {
                    setState(() {
                      viewingInventoryCompanyId = companyId;
                      showCatalogueModal = false;
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildShopModal(BuildContext context) {
    return _buildModalBackdrop(
      context,
      child: Container(
        width: 370,
        constraints: BoxConstraints(maxWidth: 370),
        padding: EdgeInsets.all(14),
        margin: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Browse Shops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() => showShopModal = false);
                  },
                )
              ],
            ),
            Divider(),
            ...shops.map((shop) => ListTile(
                  leading: Image.network(shop['logo']!, width: 36, height: 36, fit: BoxFit.cover),
                  title: Text(shop['company']!),
                  onTap: () {
                    setState(() {
                      viewingInventoryCompanyId = shop['companyId'];
                      showShopModal = false;
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInventoryModal(BuildContext context, String companyId) {
    final products = companyCatalogues[companyId] ?? [];
    final companyName = shops.firstWhere((s) => s['companyId'] == companyId, orElse: () => {'company': 'Company'})['company']!;
    return _buildModalBackdrop(
      context,
      child: Container(
        width: 420,
        constraints: BoxConstraints(maxWidth: 420),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('$companyName Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      viewingInventoryCompanyId = null;
                    });
                  },
                )
              ],
            ),
            Divider(),
            ...products.map((prod) => Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Image.network(prod['image']!, width: 40, height: 40, fit: BoxFit.cover),
                    title: Text(prod['productName']!, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(prod['description']!),
                    trailing: ElevatedButton(
                      child: Text("Order"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Order placed for ${prod['productName']}")),
                        );
                        setState(() {
                          viewingInventoryCompanyId = null;
                        });
                      },
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildModalBackdrop(BuildContext context, {required Widget child}) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showCatalogueModal = false;
                showShopModal = false;
                viewingInventoryCompanyId = null;
              });
            },
            child: Container(color: Colors.black45),
          ),
        ),
        Center(child: SingleChildScrollView(child: child)),
      ],
    );
  }

  LatLng _getMainMapCenter() {
    if (liveTrackIndex != null && shipments.isNotEmpty && shipments[liveTrackIndex!].lastKnownLocation != null) {
      return shipments[liveTrackIndex!].lastKnownLocation!;
    }
    if (showBookingPopup) {
      return bookingMarkerPosition;
    }
    return LatLng(-1.2921, 36.8219);
  }

  void _showShipmentHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            final fontSize = 13.0;
            return Column(
              children: [
                SizedBox(height: 10),
                Container(
                  width: 38,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Shipment History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize + 5),
                ),
                Expanded(
                  child: shipments.isEmpty
                      ? Center(child: Text("No shipments yet."))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: shipments.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final s = shipments[index];
                            return ListTile(
                              leading: Icon(
                                s.status == "In Transit"
                                    ? Icons.local_shipping
                                    : s.status == "Pending"
                                        ? Icons.timelapse
                                        : Icons.assignment_late,
                                color: s.status == "In Transit"
                                    ? Colors.blue
                                    : s.status == "Pending"
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                              title: Text(s.title, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  "Status: ${s.status} • ${s.createdAt.toLocal().toString().split(' ')[0]}"),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
