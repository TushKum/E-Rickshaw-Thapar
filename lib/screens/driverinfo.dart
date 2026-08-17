// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import '../database.dart';
import 'match_details_view.dart';

/// What the passenger sees once a driver accepts their request.
class driver_details extends StatefulWidget {
  const driver_details({
    Key? key,
    required this.uid,
    required this.pfrom,
    required this.to,
  }) : super(key: key);

  final String uid;
  final String pfrom;
  final String to;

  @override
  State<driver_details> createState() => _driver_detailsState();
}

class _driver_detailsState extends State<driver_details> {
  late Databases db;
  String name = "";
  String phone = "";
  String plate = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    db = Databases();
    db.initialise();
    _load();
  }

  Future<void> _load() async {
    final value = await db.get_driver(widget.uid);
    if (!mounted) return;
    setState(() {
      name = value?['name'] ?? '';
      phone = value?['number'] ?? '';
      plate = value?['numberplate'] ?? '';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MatchDetailsView(
      title: 'Your driver',
      subtitle: 'Ride confirmed',
      name: name,
      phone: phone,
      plate: plate,
      from: widget.pfrom,
      to: widget.to,
      loading: _loading,
    );
  }
}
