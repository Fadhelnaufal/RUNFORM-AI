# 🏃‍♂️ RUNFORM-AI

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.x-orange)
![MediaPipe](https://img.shields.io/badge/MediaPipe-BlazePose-green)
![OpenCV](https://img.shields.io/badge/OpenCV-Computer_Vision-red)
![Status](https://img.shields.io/badge/Status-Beta_Development-lightgrey)

**Sistem Deteksi dan Klasifikasi Kesalahan Biomekanik Lari Menggunakan CNN 1D dan Analisis Keypoint BlazePose.** *Made By ~ Fadhel Naufal Akbar*

---

## 📖 Tentang Proyek

RUNFORM-AI adalah alat bantu analisis postur lari berbasis *deep learning* yang dirancang khusus untuk pelari rekreasional. Data epidemiologi menunjukkan 50-80% pelari mengalami cedera akibat kesalahan biomekanik yang tidak terdeteksi. Sistem ini memecahkan masalah tersebut dengan menyediakan deteksi kesalahan postur lari yang terjangkau dan akurat tanpa memerlukan sensor *motion capture* khusus.

Sistem ini menggabungkan kemampuan **Google MediaPipe BlazePose** untuk ekstraksi *keypoint* tubuh 3D secara *real-time* dan **Convolutional Neural Network (CNN 1D)** untuk klasifikasi fitur spasial-temporal dari gerakan berlari.

### 🎯 Fitur Utama
* **Pose Estimation Real-time:** Ekstraksi 33 *landmark* tubuh menggunakan BlazePose dari input video standar.
* **Kalkulasi Biomekanik:** Perhitungan otomatis sudut sendi kritis (seperti sudut lutut, *forward lean*, dll).
* **Klasifikasi CNN 1D:** Mendeteksi 3 kelas utama: `Normal`, `Overstride`, dan `Heel Strike` (Dapat diekspansi).
* **Auto-Balancing Dataset:** Penanganan *imbalanced dataset* secara otomatis menggunakan teknik *Undersampling*.
* **Video Inference Engine:** Menghasilkan output video MP4 (Codec H.264) yang dilengkapi *overlay skeleton* dan HUD visualisasi prediksi *real-time*.

---

## 🛠️ Tech Stack & Framework

* **Core Logic:** Python, OpenCV, NumPy, Pandas
* **Machine Learning:** Scikit-learn (Preprocessing), TensorFlow / Keras (CNN Architecture)
* **Computer Vision:** MediaPipe (BlazePose)
* **Mobile Integration (Tahap Selanjutnya):** Flutter, TensorFlow Lite

---

