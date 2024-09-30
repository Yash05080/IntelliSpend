import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Map<String, dynamic>> transactionsData = [
  {
    'icon': const FaIcon(
      FontAwesomeIcons.burger,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Food',
    'color': Colors.red, // Suitable for food, like a red apple or burger
    'totalamount': '₹400.00',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.bagShopping,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Shopping',
    'color': Colors.pink, // Pink is often associated with shopping or fashion
    'totalamount': '₹2560.00',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.ticket,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Entertainment',
    'color': Colors.blue, // Blue can represent fun and entertainment
    'totalamount': '₹660.67',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.planeDeparture,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Travel',
    'color': Colors.orange, // Orange evokes a sense of adventure and travel
    'totalamount': '₹5500.00',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.kitMedical,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Medical',
    'color': Colors.green, // Green represents health and wellness
    'totalamount': '₹360.00',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.phone,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Recharge',
    'color':
        Colors.teal, // Teal is a fresh color, good for utilities like recharge
    'totalamount': '₹778.00',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.house,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Rent',
    'color':
        Colors.brown, // Brown represents stability, fitting for rent or home
    'totalamount': '₹11000.00',
    'date': '3 Days ago',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.cashRegister,
      color: Colors.white,
      size: 30,
    ),
    'name': 'Others',
    'color': Colors.grey, // Grey for miscellaneous or other expenses
    'totalamount': '₹3400.00',
    'date': 'Today',
  }
];

// CateGories

final List<Map<String, dynamic>> DataCategories = [
  {
    'icon': const FaIcon(
      FontAwesomeIcons.burger,
      color: Colors.red, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Food',
    'color': Colors.red, // Suitable for food, like a red apple or burger
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.bagShopping,
      color: Colors.pink, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Shopping',
    'color': Colors.pink, // Pink is often associated with shopping or fashion
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.ticket,
      color: Colors.blue, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Entertainment',
    'color': Colors.blue, // Blue can represent fun and entertainment
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.planeDeparture,
      color: Colors.orange, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Travel',
    'color': Colors.orange, // Orange evokes a sense of adventure and travel
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.kitMedical,
      color: Colors.green, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Medical',
    'color': Colors.green, // Green represents health and wellness
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.phone,
      color: Colors.teal, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Recharge',
    'color':
        Colors.teal, // Teal is a fresh color, good for utilities like recharge
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.house,
      color: Colors.brown, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Rent',
    'color':
        Colors.brown, // Brown represents stability, fitting for rent or home
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.cashRegister,
      color: Colors.grey, // Icon color matches the category color
      size: 30,
    ),
    'name': 'Others',
    'color': Colors.grey, // Grey for miscellaneous or other expenses
  }
];
