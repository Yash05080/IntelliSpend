import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Map<String, dynamic>> transactionsData = [
  {
    'icon': FaIcon(
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
    'icon': FaIcon(
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
    'icon': FaIcon(
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
    'icon': FaIcon(
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
    'icon': FaIcon(
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
    'icon': FaIcon(
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
    'icon': FaIcon(
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
    'icon': FaIcon(
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
