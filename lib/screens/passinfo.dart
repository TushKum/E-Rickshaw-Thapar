import 'package:flutter/material.dart';

import '../database.dart';
import 'match_details_view.dart';

/// What the driver sees once they accept a passenger's request.
class Userdetails extends StatefulWidget {
  const Userdetails({
    Key? key,
    required this.uid,
    required this.pfrom,
    required this.to,
  }) : super(key: key);

  final String uid;
  final String pfrom;
  final String to;

  @override
  State<Userdetails> createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {
  late Databases db;
  String name = "";
  String phone = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    db = Databases();
    db.initialise();
    _load();
  }

  Future<void> _load() async {
    final value = await db.get_passenger(widget.uid);
    if (!mounted) return;
    setState(() {
      name = value?['name'] ?? '';
      phone = value?['number'] ?? '';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MatchDetailsView(
      title: 'Your passenger',
      subtitle: 'Ride accepted',
      name: name,
      phone: phone,
      from: widget.pfrom,
      to: widget.to,
      loading: _loading,
    );
  }
}
