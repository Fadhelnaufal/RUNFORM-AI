import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.pose, this.imageSize, this.rotation);

  final Pose pose;
  final Size imageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.blueAccent;

    // Fungsi untuk mengubah koordinat ML Kit ke koordinat layar
    double translateX(double x) {
      return x * size.width / imageSize.width;
    }

    double translateY(double y) {
      return y * size.height / imageSize.height;
    }

    // Menggambar Garis antar Sendi (Kabel-kabel skeleton)
    void paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
      final joint1 = pose.landmarks[type1];
      final joint2 = pose.landmarks[type2];
      if (joint1 != null && joint2 != null) {
        canvas.drawLine(
          Offset(translateX(joint1.x), translateY(joint1.y)),
          Offset(translateX(joint2.x), translateY(joint2.y)),
          paintType,
        );
      }
    }

    // Gambar Batang Tubuh & Kaki (Urutan Biomekanik Lari)
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
    paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);
    
    // Kaki Kiri
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
    paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
    paintLine(PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel, leftPaint);
    paintLine(PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex, leftPaint);

    // Kaki Kanan
    paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
    paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    paintLine(PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel, rightPaint);
    paintLine(PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex, rightPaint);

    // Gambar Titik Sendi
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(
        Offset(translateX(landmark.x), translateY(landmark.y)),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}