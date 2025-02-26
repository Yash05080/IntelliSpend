import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Map<String, dynamic>> transactionsData = [
  {
    'name': 'Ramen',
    'totalamount': '₹250.00',
    'date': 'Today',
    'description': 'Delicious ramen at a Japanese restaurant',
    'category': 'Food',
  },
  {
    'name': 'New Phone',
    'totalamount': '₹45,000.00',
    'date': 'Today',
    'description': 'Bought a brand-new smartphone',
    'category': 'Shopping',
  },
  {
    'name': 'Movie Night',
    'totalamount': '₹550.00',
    'date': 'Yesterday',
    'description': 'Watched the latest blockbuster',
    'category': 'Entertainment',
  },
  {
    'name': 'Trip to Japan',
    'totalamount': '₹1,50,000.00',
    'date': 'Last Week',
    'description': 'Flight tickets and accommodation for Japan',
    'category': 'Travel',
  },
  {
    'name': 'Taxi to Delhi',
    'totalamount': '₹3,200.00',
    'date': 'Today',
    'description': 'Cab fare for business travel',
    'category': 'Travel',
  },
  {
    'name': 'Hospital Bill',
    'totalamount': '₹10,000.00',
    'date': '2 Days ago',
    'description': 'Medical check-up and treatment',
    'category': 'Medical',
  },
  {
    'name': 'Internet Bill',
    'totalamount': '₹999.00',
    'date': 'Yesterday',
    'description': 'Monthly broadband payment',
    'category': 'Recharge',
  },
  {
    'name': 'Rent Payment',
    'totalamount': '₹12,000.00',
    'date': '1 Week ago',
    'description': 'Monthly house rent',
    'category': 'Rent',
  },
  {
    'name': 'Freelance Work',
    'totalamount': '₹15,000.00',
    'date': 'Today',
    'description': 'Payment received for freelance project',
    'category': 'Others',
  },
  {
    'name': 'Car Fuel',
    'totalamount': '₹2,000.00',
    'date': '3 Days ago',
    'description': 'Petrol for the car',
    'category': 'Automobile',
  },
];

// Categories
final List<Map<String, dynamic>> DataCategories = [
  {
    'icon': const FaIcon(
      FontAwesomeIcons.burger,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Food',
    'color': Colors.red, // Suitable for food, like a red apple or burger
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.bagShopping,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Shopping',
    'color': Colors.pink, // Pink is often associated with shopping or fashion
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.ticket,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Entertainment',
    'color': Colors.blue, // Blue can represent fun and entertainment
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.planeDeparture,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Travel',
    'color': Colors.orange, // Orange evokes a sense of adventure and travel
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.kitMedical,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Medical',
    'color': Colors.green, // Green represents health and wellness
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.phone,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Recharge',
    'color':
        Colors.teal, // Teal is a fresh color, good for utilities like recharge
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.house,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Rent',
    'color':
        Colors.brown, // Brown represents stability, fitting for rent or home
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.car,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Automobile',
    'color': Colors.blueGrey, // Grey for miscellaneous or other expenses
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.cashRegister,
      color: Colors.white, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Others',
    'color': Colors.grey, // Grey for miscellaneous or other expenses
  },
];

Map<String, dynamic> getCategoryDetails(String category) {
  return DataCategories.firstWhere(
    (cat) => cat['name'] == category,
    orElse: () => {
      'icon': const FaIcon(FontAwesomeIcons.question,
          color: Colors.white, size: 30),
      'color': Colors.grey,
    },
  );
}
