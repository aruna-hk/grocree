import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'start_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransporterHomePage extends StatefulWidget {
  const TransporterHomePage({super.key});

  @override
  State<TransporterHomePage> createState() => _TransporterHomePageState();
}

class _TransporterHomePageState extends State<TransporterHomePage> with TickerProviderStateMixin {
  late WebSocketChannel channel;
  LatLng? userLocation;
  LatLng? fromLocation;
  LatLng? toLocation;
  String? shipmentInfo;
  String? fromLocationName;
  String? toLocationName;
  String? userName;
  bool showPanel = false;
  bool isConnected = false;
  Timer? countdownTimer;
  int countdown = 30;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    initLocation();
    connectToWebSocket();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  MapController mapController = MapController();

  Future<void> initLocation() async {
    await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition();
    final userPos = LatLng(position.latitude, position.longitude);

    setState(() {
      userLocation = userPos;
    });

    // Move map to new position
    mapController.move(userPos, 16.0); // Adjust zoom as needed

    // Live update
    Geolocator.getPositionStream().listen((position) {
      final updatedPos = LatLng(position.latitude, position.longitude);
      setState(() {
        userLocation = updatedPos;
      });
      mapController.move(updatedPos, mapController.camera.zoom);
    });
  }

  void _showWelcomeDialog(String message, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.waving_hand, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $name!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to shipments channel',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'You\'re now ready to receive shipment notifications!',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isConnected = true;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Get Started'),
            ),
          ],
        );
      },
    );
  }

  void connectToWebSocket() async {
    try {
      // Get the stored JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "hk";
    
      //if (token == null || token.isEmpty) {
        //print('No auth token found, redirecting to login');
        //Navigator.pushReplacement(
        //  context,
        //  MaterialPageRoute(builder: (context) => LoginPage()),
        //);
        //return;
      //}
    
      // Create WebSocket URL with token as query parameter
      final String wsUrl = 'ws://127.0.0.1:8080?token=${token}';
      print('Connecting to WebSocket with token: $wsUrl');
    
      // Create WebSocket connection
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
      // Listen for messages
      channel!.stream.listen(
        (message) {
          print('WebSocket message received: $message');
        
          try {
            final data = jsonDecode(message);
            print('Parsed data: $data');
          
            // Handle different message types
            if (data['type'] == 'connection') {
              print('Connected to server: ${data['message']}');
              final user = data['user'];
              if (user != null) {
                final name = user['name'] ?? 'User';
                setState(() {
                  userName = name;
                });
                _showWelcomeDialog(data['message'], name);
              }
            } else if (data['type'] == 'error') {
              print('Server error: ${data['message']}');
              if (data['code'] == 'AUTH_REQUIRED' || data['code'] == 'AUTH_FAILED') {
                // Token is invalid, redirect to login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StartPage()),
                );
              }
            } else {
              // Handle shipment data
              final shipmentData = data['data'] ?? data;
              setState(() {
                fromLocation = LatLng(shipmentData['from']['lat'], shipmentData['from']['lng']);
                toLocation = LatLng(shipmentData['to']['lat'], shipmentData['to']['lng']);
                fromLocationName = shipmentData['from']['name'] ?? 'Pickup Location';
                toLocationName = shipmentData['to']['name'] ?? 'Destination';
                shipmentInfo = shipmentData['info'];
                showPanel = true;
                countdown = 30;
              });
              _slideController.forward();
              startCountdown();
            }
          } catch (e) {
            print('Error parsing message: $e');
            // If not JSON, treat as simple message
            print('Simple message: $message');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() {
            isConnected = false;
          });
        },
      );
    
    } catch (e) {
      print('WebSocket connection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server: $e')),
      );
    }
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        _slideController.reverse().then((_) {
          setState(() {
            showPanel = false;
            fromLocation = null;
            toLocation = null;
            shipmentInfo = null;
            fromLocationName = null;
            toLocationName = null;
          });
        });
        timer.cancel();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  double calculateDistance() {
    if (userLocation == null || toLocation == null) return 0.0;
    final distance = Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      fromLocation!.latitude,
      fromLocation!.longitude,
    ) + Geolocator.distanceBetween(
      fromLocation!.latitude,
      fromLocation!.longitude,
      toLocation!.latitude,
      toLocation!.longitude,
    );
    return distance / 1000; // in km
  }

  void _acceptShipment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Shipment accepted successfully!"),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    _slideController.reverse().then((_) {
      setState(() {
        showPanel = false;
        fromLocation = null;
        toLocation = null;
        shipmentInfo = null;
        fromLocationName = null;
        toLocationName = null;
      });
    });
    countdownTimer?.cancel();
  }

  @override
  void dispose() {
    channel.sink.close();
    countdownTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (userLocation != null)
        Marker(
          point: userLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
        ),
      if (fromLocation != null)
        Marker(
          point: fromLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
        ),
      if (toLocation != null)
        Marker(
          point: toLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.flag, color: Colors.white, size: 20),
          ),
        ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Map View
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: userLocation ?? LatLng(0.1769, 37.9083),
              initialZoom: 1000,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Logout Button (Top-Right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.red.withOpacity(0.3),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StartPage()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ),
            ),
          ),

          // Connection Status (Top-Left)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isConnected ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.wifi : Icons.wifi_off,
                        color: isConnected ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isConnected ? 'Connected' : 'Connecting...',
                        style: TextStyle(
                          color: isConnected ? Colors.green[800] : Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // WebSocket Placeholder Slide (bottom, visible when no shipment)
          if (!showPanel && isConnected)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.12,
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.radar, color: Colors.blue[800], size: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Listening for shipments...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // WebSocket Shipment Panel
          if (showPanel && shipmentInfo != null)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      _slideAnimation.value * MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange[400]!, Colors.orange[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.local_shipping, color: Colors.white, size: 24),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "New Shipment Available",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "⏳ ${countdown}s remaining",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Content
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Route Information
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "From: ${fromLocationName ?? 'Pickup Location'}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, color: Colors.red, size: 16),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "To: ${toLocationName ?? 'Destination'}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Shipment Details
                                  Text(
                                    "Shipment Details:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue[200]!),
                                        ),
                                        child: Text(
                                          shipmentInfo!,
                                          style: TextStyle(fontSize: 14, height: 1.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Distance Info
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.route, color: Colors.amber[800], size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          "Total Distance: ${calculateDistance().toStringAsFixed(2)} km",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amber[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 20),
                                  
                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _acceptShipment,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[600],
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: Colors.green.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            "Accept Shipment",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
