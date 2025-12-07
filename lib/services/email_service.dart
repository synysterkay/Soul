import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Comprehensive email service for transactional, behavioral, and value-add emails
/// All emails use OneSignal REST API with beautiful HTML templates
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _restApiKey = 'os_v2_app_g2icp4vjzfgdzeruayxhqura4ebyq3cyeuyewofdnxfahb7i5x4tbixt4hjlcornqqgxdm2lzh5ouogqged66tjidgurtll2dhjyopi';
  static const String _appId = '369027f2-a9c9-4c3c-9234-062e785220e1';
  static const String _fromName = 'SoulPlan';
  static const String _fromEmail = 'hello@soulplan.app';
  
  // App links
  static const String _androidLink = 'https://play.google.com/store/apps/details?id=com.aifun.dateideas.planadate';
  static const String _iosLink = 'https://apps.apple.com/app/soulplan-ai-date-ideas/id6702018988';

  /// Sync user email with OneSignal when they sign up or log in
  Future<void> syncUserEmail({
    required String userId,
    required String email,
    required String name,
    String? partnerId,
  }) async {
    try {
      // Login to OneSignal with Firebase userId
      await OneSignal.login(userId);

      // Add email
      await OneSignal.User.addEmail(email);

      // Add tags for segmentation
      final tags = {
        'name': name,
        'user_id': userId,
        'signup_date': DateTime.now().toIso8601String(),
      };
      
      if (partnerId != null) {
        tags['has_partner'] = 'true';
        tags['partner_id'] = partnerId;
      }
      
      await OneSignal.User.addTags(tags);

      // Save to Firebase
      await _firestore.collection('users').doc(userId).update({
        'email': email,
        'oneSignalPlayerId': OneSignal.User.pushSubscription.id,
        'emailSyncedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Email synced: $email');
    } catch (e) {
      print('❌ Error syncing email: $e');
    }
  }

  /// Track user behavior for smart segmentation
  Future<void> trackBehavior({
    required String userId,
    required String event,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tags = <String, String>{};

      switch (event) {
        case 'questionnaire_completed':
          tags['questionnaire_complete'] = 'true';
          tags['questionnaire_date'] = DateTime.now().toIso8601String();
          break;

        case 'date_created':
          final count = metadata?['total_dates'] ?? 1;
          tags['dates_planned'] = count.toString();
          tags['last_date_created'] = DateTime.now().toIso8601String();
          if (count == 1) tags['milestone_first_date'] = 'true';
          if (count == 5) tags['milestone_fifth_date'] = 'true';
          break;

        case 'date_confirmed':
          tags['last_date_confirmed'] = DateTime.now().toIso8601String();
          tags['active_user'] = 'true';
          break;

        case 'app_opened':
          tags['last_active'] = DateTime.now().toIso8601String();
          break;
      }

      // Update OneSignal tags
      if (tags.isNotEmpty) {
        await OneSignal.User.addTags(tags);
      }

      print('✅ Behavior tracked: $event');
    } catch (e) {
      print('❌ Error tracking behavior: $e');
    }
  }

  /// Core email sending method via OneSignal REST API
  Future<bool> _sendEmail({
    required String recipientEmail,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'include_email_tokens': [recipientEmail],
          'email_subject': subject,
          'email_body': htmlContent,
          'email_from_name': _fromName,
          'email_from_address': _fromEmail,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email sent: $subject to $recipientEmail');
        return true;
      } else {
        print('❌ Email failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      return false;
    }
  }

  /// Replace personalization tokens in HTML
  String _personalize(String html, Map<String, String> data) {
    String result = html;
    data.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }

  /// Base HTML template wrapper
  String _wrapTemplate(String content) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; background: #f5f5f5; }
    .container { max-width: 600px; margin: 0 auto; background: white; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 28px; }
    .content { padding: 40px 30px; background: white; }
    .content h2 { color: #333; font-size: 24px; margin-top: 0; }
    .content p { color: #666; line-height: 1.6; font-size: 16px; }
    .button { display: inline-block; background: #667eea; color: white !important; padding: 16px 32px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
    .button:hover { background: #5568d3; }
    .highlight-box { background: #f8f9ff; border-left: 4px solid #667eea; padding: 20px; margin: 20px 0; border-radius: 8px; }
    .footer { background: #f9f9f9; padding: 30px; text-align: center; color: #999; font-size: 14px; }
    .footer a { color: #667eea; text-decoration: none; }
    .app-badges { margin: 20px 0; }
    .app-badges img { height: 40px; margin: 0 5px; }
  </style>
</head>
<body>
  <div class="container">
    $content
    <div class="footer">
      <p><strong>SoulPlan</strong> - Plan the perfect date together 💕</p>
      <p>
        <a href="$_androidLink"><img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" height="40" alt="Get it on Google Play"></a>
        <a href="$_iosLink"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="40" alt="Download on App Store"></a>
      </p>
      <p>
        <a href="#">Unsubscribe</a> | 
        <a href="#">Email Preferences</a> | 
        <a href="#">Help</a>
      </p>
    </div>
  </div>
</body>
</html>
    ''';
  }

  // ============================================
  // TRANSACTIONAL EMAILS (Always send)
  // ============================================

  /// Email 1: Date request created - invite partner to fill questionnaire
  Future<void> sendDateRequestEmail({
    required String recipientEmail,
    required String recipientName,
    required String partnerName,
    required String dateRequestId,
  }) async {
    final content = '''
<div class="header">
  <h1>💕 New Date Request!</h1>
</div>
<div class="content">
  <h2>Hi $recipientName!</h2>
  <p><strong>$partnerName</strong> wants to plan a date with you!</p>
  <p>Take just 2 minutes to answer a few questions. Our AI will analyze both your preferences and suggest the perfect date that you'll both love.</p>
  
  <div class="highlight-box">
    <p><strong>Why fill the questionnaire?</strong></p>
    <ul style="margin: 10px 0; padding-left: 20px;">
      <li>Get AI-powered personalized date suggestions</li>
      <li>Discover activities you both enjoy</li>
      <li>Save time planning the perfect date</li>
    </ul>
  </div>
  
  <center>
    <a href="soulplan://questionnaire/$dateRequestId" class="button">Fill Questionnaire Now →</a>
  </center>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>$partnerName is excited and waiting! Don't keep them waiting too long 😊</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '$partnerName wants to plan a date with you! 💕',
      htmlContent: _wrapTemplate(content),
    );

    // Track email sent
    await trackBehavior(
      userId: recipientEmail,
      event: 'email_sent',
      metadata: {'type': 'date_request', 'date_request_id': dateRequestId},
    );
  }

  /// Email 2: Time proposed - notify partner
  Future<void> sendTimeProposedEmail({
    required String recipientEmail,
    required String recipientName,
    required String partnerName,
    required String proposedTime,
    required String dateRequestId,
  }) async {
    final content = '''
<div class="header">
  <h1>⏰ New Time Proposed!</h1>
</div>
<div class="content">
  <h2>Hi $recipientName!</h2>
  <p><strong>$partnerName</strong> proposed a time for your date:</p>
  
  <div class="highlight-box" style="text-align: center; background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);">
    <p style="font-size: 14px; color: #999; margin: 0;">Proposed Time</p>
    <h3 style="margin: 10px 0; color: #667eea; font-size: 28px;">$proposedTime</h3>
  </div>
  
  <p>What do you think? Accept this time or suggest a different one that works better for you.</p>
  
  <center>
    <a href="soulplan://time-negotiation/$dateRequestId" class="button">Respond Now →</a>
  </center>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>💡 Tip: The sooner you respond, the sooner you can finalize your date plans!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '⏰ $partnerName proposed $proposedTime for your date!',
      htmlContent: _wrapTemplate(content),
    );
  }

  /// Email 3: Date confirmed - both partners get confirmation
  Future<void> sendDateConfirmedEmail({
    required String recipientEmail,
    required String recipientName,
    required String partnerName,
    required String confirmedTime,
    required String dateDetails,
    required String dateRequestId,
  }) async {
    final content = '''
<div class="header">
  <h1>✅ Your Date is Confirmed!</h1>
</div>
<div class="content">
  <h2>Hi $recipientName!</h2>
  <p>Great news! Your date with <strong>$partnerName</strong> is all set! 🎉</p>
  
  <div class="highlight-box" style="background: linear-gradient(135deg, #10b98115 0%, #06986615 100%);">
    <p style="font-size: 14px; color: #999; margin: 0;">Date Confirmed</p>
    <h3 style="margin: 10px 0; color: #10b981; font-size: 24px;">$confirmedTime</h3>
    <p style="margin: 10px 0; color: #666;">$dateDetails</p>
  </div>
  
  <p><strong>Tips for an amazing date:</strong></p>
  <ul style="color: #666; line-height: 1.8;">
    <li>Be on time - it shows you care</li>
    <li>Put your phone away and be present</li>
    <li>Ask questions and listen actively</li>
    <li>Relax and enjoy the moment!</li>
  </ul>
  
  <center>
    <a href="soulplan://dates" class="button">View Date Details →</a>
  </center>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>💕 Have a wonderful time together!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '✅ Your date with $partnerName is confirmed!',
      htmlContent: _wrapTemplate(content),
    );
  }

  /// Email 4: Questionnaire completed - celebrate and guide next steps
  Future<void> sendQuestionnaireCompletedEmail({
    required String recipientEmail,
    required String recipientName,
  }) async {
    final content = '''
<div class="header">
  <h1>🎉 Questionnaire Complete!</h1>
</div>
<div class="content">
  <h2>Great job, $recipientName!</h2>
  <p>You've completed the questionnaire! Our AI is now analyzing your preferences to suggest the perfect dates.</p>
  
  <div class="highlight-box">
    <p><strong>What happens next?</strong></p>
    <ol style="margin: 10px 0; padding-left: 20px; color: #666;">
      <li>We'll compare your answers with your partner's</li>
      <li>AI will generate personalized date suggestions</li>
      <li>You'll both see the top matches</li>
      <li>Pick your favorites and find the perfect date!</li>
    </ol>
  </div>
  
  <center>
    <a href="soulplan://dates" class="button">View Suggestions →</a>
  </center>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>💡 Tip: The more dates you plan together, the better our AI gets at understanding your preferences!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '🎉 Your date suggestions are ready!',
      htmlContent: _wrapTemplate(content),
    );
  }

  // ============================================
  // BEHAVIORAL EMAILS (Based on user actions)
  // ============================================

  /// Welcome email - sent immediately after signup
  Future<void> sendWelcomeEmail({
    required String recipientEmail,
    required String recipientName,
  }) async {
    final content = '''
<div class="header">
  <h1>Welcome to SoulPlan! 💕</h1>
</div>
<div class="content">
  <h2>Hi $recipientName!</h2>
  <p>We're so excited to have you here! SoulPlan helps couples plan the perfect dates using AI-powered suggestions.</p>
  
  <p><strong>Here's how it works:</strong></p>
  <div class="highlight-box">
    <p style="margin: 5px 0;"><strong>1.</strong> Create a date request with your partner</p>
    <p style="margin: 5px 0;"><strong>2.</strong> Both fill out a quick questionnaire</p>
    <p style="margin: 5px 0;"><strong>3.</strong> Get AI-powered personalized suggestions</p>
    <p style="margin: 5px 0;"><strong>4.</strong> Pick a date and confirm the time</p>
  </div>
  
  <center>
    <a href="soulplan://main" class="button">Get Started →</a>
  </center>
  
  <p><strong>Why couples love SoulPlan:</strong></p>
  <ul style="color: #666; line-height: 1.8;">
    <li>No more "What should we do?" arguments</li>
    <li>Discover new activities you both enjoy</li>
    <li>Save time with AI-powered suggestions</li>
    <li>Keep the romance alive with regular dates</li>
  </ul>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>Need help? Just reply to this email - we're here for you!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: 'Welcome to SoulPlan! Let\'s plan your first date 💕',
      htmlContent: _wrapTemplate(content),
    );
  }

  /// Re-engagement: Questionnaire incomplete after 24 hours
  Future<void> sendQuestionnaireReminderEmail({
    required String recipientEmail,
    required String recipientName,
    required String partnerName,
  }) async {
    final content = '''
<div class="header">
  <h1>Don't Miss Out!</h1>
</div>
<div class="content">
  <h2>Hi $recipientName,</h2>
  <p>We noticed you haven't completed your questionnaire yet. <strong>$partnerName</strong> is waiting to see the AI-suggested dates!</p>
  
  <p>It only takes 2 minutes, and you'll get:</p>
  <ul style="color: #666; line-height: 1.8;">
    <li>✨ Personalized date suggestions just for you two</li>
    <li>🎯 Activities you'll both enjoy</li>
    <li>⏱️ Save hours of planning time</li>
  </ul>
  
  <center>
    <a href="soulplan://questionnaire" class="button">Complete Questionnaire (2 min) →</a>
  </center>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>💕 $partnerName is excited to plan this date with you!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '$partnerName is waiting for you! Complete your questionnaire',
      htmlContent: _wrapTemplate(content),
    );
  }

  /// Re-engagement: No activity for 7 days
  Future<void> sendWeeklyReengagementEmail({
    required String recipientEmail,
    required String recipientName,
  }) async {
    final content = '''
<div class="header">
  <h1>We Miss You! 💕</h1>
</div>
<div class="content">
  <h2>Hi $recipientName,</h2>
  <p>It's been a while since your last date! Research shows that couples who date regularly are happier and more connected.</p>
  
  <div class="highlight-box">
    <p><strong>💡 Date Idea for This Weekend:</strong></p>
    <p style="font-size: 18px; margin: 10px 0;"><strong>"Sunset Picnic & Stargazing"</strong></p>
    <p style="color: #666;">Pack your favorite snacks, find a cozy spot, and watch the sunset together. Stay for the stars and deep conversations.</p>
  </div>
  
  <center>
    <a href="soulplan://main" class="button">Plan Your Next Date →</a>
  </center>
  
  <p><strong>More date ideas waiting for you:</strong></p>
  <ul style="color: #666; line-height: 1.8;">
    <li>🍳 Cook a new recipe together</li>
    <li>🎨 Take a pottery or painting class</li>
    <li>🚴 Go on a bike ride to a new neighborhood</li>
    <li>🎬 Have a movie marathon with your favorite films</li>
  </ul>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>Small moments together create lasting memories. Start planning today!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: 'Time for another date? Here are some ideas 💕',
      htmlContent: _wrapTemplate(content),
    );
  }

  // ============================================
  // VALUE-ADD EMAILS (Educational/Inspirational)
  // ============================================

  /// Weekly date ideas - sent every Friday
  Future<void> sendWeeklyDateIdeasEmail({
    required String recipientEmail,
    required String recipientName,
  }) async {
    final content = '''
<div class="header">
  <h1>Weekend Date Ideas 🎉</h1>
</div>
<div class="content">
  <h2>Hi $recipientName!</h2>
  <p>The weekend is almost here! Make it special with one of these curated date ideas:</p>
  
  <div class="highlight-box" style="background: #fff3cd;">
    <p style="font-size: 18px; margin: 5px 0;"><strong>🍝 Romantic Dinner Date</strong></p>
    <p style="color: #666;">Try that new Italian restaurant you've been eyeing. Candlelight, good wine, and great conversation.</p>
  </div>
  
  <div class="highlight-box" style="background: #d1ecf1;">
    <p style="font-size: 18px; margin: 5px 0;"><strong>🏞️ Nature Adventure</strong></p>
    <p style="color: #666;">Find a scenic hiking trail nearby. Pack snacks, take photos, and enjoy the fresh air together.</p>
  </div>
  
  <div class="highlight-box" style="background: #f8d7da;">
    <p style="font-size: 18px; margin: 5px 0;"><strong>🎭 Cultural Experience</strong></p>
    <p style="color: #666;">Visit a local museum, art gallery, or catch a live performance. Expand your horizons together.</p>
  </div>
  
  <center>
    <a href="soulplan://main" class="button">Get More Personalized Ideas →</a>
  </center>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>💡 Pro tip: The best dates aren't about the activity, they're about the quality time together!</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '🎉 Weekend Date Ideas Just for You!',
      htmlContent: _wrapTemplate(content),
    );
  }

  /// Milestone celebration - First date completed
  Future<void> sendFirstDateMilestoneEmail({
    required String recipientEmail,
    required String recipientName,
  }) async {
    final content = '''
<div class="header">
  <h1>🎉 Congratulations!</h1>
</div>
<div class="content">
  <h2>You Planned Your First Date! 💕</h2>
  <p>Hey $recipientName,</p>
  <p>We're so excited for you! You've just planned your first date using SoulPlan. This is just the beginning of many amazing memories together.</p>
  
  <div class="highlight-box">
    <p><strong>How was your date?</strong></p>
    <p>We'd love to hear how it went! Your feedback helps us suggest even better dates in the future.</p>
    <center>
      <a href="soulplan://feedback" class="button" style="background: #10b981; margin: 10px;">Share Feedback →</a>
    </center>
  </div>
  
  <p><strong>Keep the momentum going:</strong></p>
  <ul style="color: #666; line-height: 1.8;">
    <li>Plan your next date soon (couples who date regularly are happier!)</li>
    <li>Try different types of dates (adventure, relaxation, culture)</li>
    <li>Let AI surprise you with unexpected suggestions</li>
  </ul>
  
  <p style="color: #999; font-size: 14px; margin-top: 30px;"><em>Thank you for choosing SoulPlan! We're here to help you create amazing memories together 💕</em></p>
</div>
    ''';

    await _sendEmail(
      recipientEmail: recipientEmail,
      subject: '🎉 You planned your first date! How did it go?',
      htmlContent: _wrapTemplate(content),
    );
  }
}
