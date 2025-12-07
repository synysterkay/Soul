import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/date_request_model.dart';
import '../services/date_request_service.dart';
import 'venue_selection_screen.dart';

class TimeNegotiationScreen extends StatefulWidget {
  final String dateRequestId;

  const TimeNegotiationScreen({
    super.key,
    required this.dateRequestId,
  });

  @override
  State<TimeNegotiationScreen> createState() => _TimeNegotiationScreenState();
}

class _TimeNegotiationScreenState extends State<TimeNegotiationScreen> {
  final DateRequestService _dateRequestService = DateRequestService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isProposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF5F7),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('dateRequests')
                .doc(widget.dateRequestId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text(
                    'Error loading date request',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              final dateRequest =
                  DateRequestModel.fromFirestore(snapshot.data!);

              // Check if time is confirmed
              if (dateRequest.status == DateRequestStatus.confirmed) {
                return _buildConfirmedView(dateRequest);
              }

              return Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMatchedDateCard(dateRequest),
                          SizedBox(height: 24),
                          _buildProposeTimeSection(dateRequest),
                          SizedBox(height: 24),
                          _buildProposedTimesSection(dateRequest),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick a Time',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Coordinate when you\'ll go on this date',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedDateCard(DateRequestModel dateRequest) {
    final selectedDate = dateRequest.selectedDate;
    if (selectedDate == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFFFE4EA),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Color(0xFFE91C40), size: 20),
              SizedBox(width: 8),
              Text(
                'Your Matched Date',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            selectedDate['title'] ?? 'Date Night',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          if (selectedDate['venue'] != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, color: Color(0xFF757575), size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    selectedDate['venue'],
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (selectedDate['activities'] != null) ...[
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (selectedDate['activities'] as List)
                  .map((activity) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFFFE4EA),
                          ),
                        ),
                        child: Text(
                          activity.toString(),
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Color(0xFFE91C40),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProposeTimeSection(DateRequestModel dateRequest) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Propose a Time',
            style: GoogleFonts.raleway(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select Date',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFE91C40),
                    side: BorderSide(color: Color(0xFFE0E0E0)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectTime(context),
                  icon: Icon(Icons.access_time),
                  label: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFE91C40),
                    side: BorderSide(color: Color(0xFFE0E0E0)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedDate != null &&
                      _selectedTime != null &&
                      !_isProposing)
                  ? () => _proposeTime(dateRequest)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE91C40),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Color(0xFFE91C40).withOpacity(0.3),
              ),
              child: _isProposing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Propose This Time',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposedTimesSection(DateRequestModel dateRequest) {
    final proposedTimes = dateRequest.proposedTimes ?? [];

    if (proposedTimes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFFFF5F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFFFFE4EA),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.schedule, color: Color(0xFFE91C40), size: 48),
            SizedBox(height: 12),
            Text(
              'No times proposed yet',
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Be the first to suggest when!',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proposed Times',
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        SizedBox(height: 12),
        ...proposedTimes.map((proposedTime) {
          final proposedDateTime =
              (proposedTime['proposedTime'] as Timestamp).toDate();
          final proposedBy = proposedTime['proposedBy'] as String;
          final isMyProposal = proposedBy == currentUserId;
          final isAccepted = proposedTime['accepted'] == true;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAccepted ? Colors.green.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAccepted ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAccepted ? Icons.check_circle : Icons.access_time,
                      color: isAccepted ? Colors.green : Color(0xFFE91C40),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy')
                                .format(proposedDateTime),
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  isAccepted ? Colors.green : Color(0xFF2D1B4E),
                            ),
                          ),
                          Text(
                            'at ${DateFormat('h:mm a').format(proposedDateTime)}',
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              color: isAccepted
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  isMyProposal ? 'Proposed by You' : 'Proposed by Partner',
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (!isMyProposal && !isAccepted) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptProposedTime(
                              dateRequest, proposedDateTime),
                          icon: Icon(Icons.check, size: 18),
                          label: Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _selectedDate = null;
                            _selectedTime = null;
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Select a different time to counter-propose'),
                                backgroundColor: Color(0xFFE91C40),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit, size: 18),
                          label: Text('Counter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFFE91C40),
                            side: BorderSide(color: Color(0xFFE91C40)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isAccepted) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Confirmed!',
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildConfirmedView(DateRequestModel dateRequest) {
    final confirmedTime = dateRequest.confirmedTime!;
    final selectedDate = dateRequest.selectedDate;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            color: Color(0xFFE91C40),
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            'Date Confirmed!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  selectedDate?['title'] ?? 'Date Night',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91C40),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFFE91C40)),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(confirmedTime),
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: Color(0xFFE91C40)),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('h:mm a').format(confirmedTime),
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VenueSelectionScreen(
                      dateRequestId: widget.dateRequestId,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.place, size: 20),
              label: Text(
                'Find Venues',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE91C40),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Color(0xFFE91C40).withOpacity(0.3),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to Dates',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFE91C40),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFE91C40),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _proposeTime(DateRequestModel dateRequest) async {
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() {
      _isProposing = true;
    });

    try {
      final proposedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await _dateRequestService.proposeTime(
        widget.dateRequestId,
        currentUserId,
        proposedDateTime,
      );

      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _isProposing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time proposed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isProposing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to propose time: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acceptProposedTime(
      DateRequestModel dateRequest, DateTime proposedTime) async {
    try {
      await _dateRequestService.acceptProposedTime(
        widget.dateRequestId,
        proposedTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Date confirmed! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept time: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
