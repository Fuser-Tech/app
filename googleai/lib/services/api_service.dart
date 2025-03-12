import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mysore_tourism_app/models/event.dart';
import 'package:mysore_tourism_app/models/tourist_spot.dart';
import 'package:mysore_tourism_app/models/accommodation.dart';
import 'package:mysore_tourism_app/models/community_post.dart'; 

class ApiService with ChangeNotifier {
  // API Keys (REPLACE these with YOUR OWN!)
  final String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY'; 
  //  Google Places API 
  final String googlePlacesBaseUrl = "https://maps.googleapis.com/maps/api/place"; 

  // *Google Maps for Directions* 
  final String googleDirectionsBaseUrl = "https://maps.googleapis.com/maps/api/directions/json";

  //  Example using Eventbrite API (Obtain your own API key!)
  final String eventbriteApiKey = "YOUR_EVENTBRITE_API_KEY";
  final String eventbriteBaseUrl = "https://www.eventbriteapi.com/v3"; 

  //  Sample Data for  Accommodation, etc., you'll need your own data source
  // For actual app, you'd fetch from a specific Accommodation API, booking service, or a dataset
  List<Accommodation> sampleAccommodation = [
    Accommodation(
      name: "The Lalitha Mahal Palace Hotel",
      description: "Historic hotel known for its grandeur.",
      imageUrl: "https://www.thelalitha mahalpalace.com/images/slider-3.jpg", 
      address: "Ashoka Rd, Chamundi Mohalla, Mysore, Karnataka 570001",
      phoneNumber: "+91 821 241 9241",
      website: "https://www.thelalitha mahalpalace.com",
      starRating: 5,
    ),
    //  ... Add more as needed ... 
  ];

  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$eventbriteBaseUrl/events/search/?token=$eventbriteApiKey&q=mysore&location.address=Mysore&expand=venue,logo,description'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Event> events = [];
        for (var eventData in data['events']) {
          events.add(Event.fromJson(eventData));
        }
        return events;
      } else {
        throw Exception('Failed to fetch events. Check API key or try again later.');
      }
    } catch (error) {
      //  Error handling. Log or display the error appropriately in the app
      print('Error fetching events: $error'); 
      return [];
    }
  }
  
  Future<List<TouristSpot>> fetchTouristSpots() async {
    final response = await http.get(Uri.parse('$googlePlacesBaseUrl/nearbysearch/output=json?location=12.3155,76.6352&radius=10000&keyword=Mysore&key=$googlePlacesApiKey')); 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<TouristSpot> spots = [];
      for (var placeData in data['results']) {
        spots.add(TouristSpot.fromJson(placeData));
      }
      return spots;
    } else {
      throw Exception('Failed to fetch tourist spots.');
    }
  }

  Future<List<double>> getAddressToCoordinates(String address) async {
    final response = await http.get(Uri.parse('$googlePlacesBaseUrl/geocode/output=json?address=$address&key=$googlePlacesApiKey')); 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Example structure using the Google Geocoding API
      if (data['results'].isNotEmpty) {
        double lat = double.tryParse(data['results'][0]['geometry']['location']['lat'].toString()) ?? 0.0; 
        double lng = double.tryParse(data['results'][0]['geometry']['location']['lng'].toString()) ?? 0.0;
        return [lat, lng];
      }
    } else {
      throw Exception('Failed to convert address to coordinates. Check API key or try again later.');
    }
    return [0.0, 0.0]; 
  }

  
  Future<List<CommunityPost>> fetchCommunityPosts() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<CommunityPost> posts = [];
        for (var postJson in data) {
          posts.add(CommunityPost.fromJson(postJson));
        }
        return posts;
      } else {
        throw Exception('Failed to fetch community posts. Check API key or try again later.');
      }
    } catch (error) {
      print('Error fetching community posts: $error');
      return [];
    }
  }
}