import cv2
import mediapipe as mp
import time

# 1. Inisialisasi MediaPipe Pose (Gunakan yang standar)
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils

# Mengatur konfigurasi deteksi pose
pose = mp_pose.Pose(
    static_image_mode=False,
    model_complexity=1,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

# 2. Mengakses Webcam (0 adalah default untuk webcam bawaan Mac)
cap = cv2.VideoCapture(0)

# Variabel untuk menghitung FPS (Frames Per Second)
pTime = 0

print("Membuka kamera... Tekan huruf 'q' pada keyboard untuk keluar.")

while cap.isOpened():
    success, img = cap.read()
    if not success:
        print("Gagal membaca dari kamera. Pastikan izin kamera sudah diberikan.")
        break

    # OpenCV membaca gambar dalam format BGR, sedangkan MediaPipe butuh RGB
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # 3. Proses gambar untuk mendeteksi pose
    results = pose.process(imgRGB)

    # 4. Menggambar landmark (titik sendi) dan koneksi (garis) di atas gambar asli
    if results.pose_landmarks:
        mp_drawing.draw_landmarks(
            img, 
            results.pose_landmarks, 
            mp_pose.POSE_CONNECTIONS,
            mp_drawing.DrawingSpec(color=(245,117,66), thickness=2, circle_radius=2), # Warna titik (merah-oranye)
            mp_drawing.DrawingSpec(color=(245,66,230), thickness=2, circle_radius=2)  # Warna garis (ungu-merah muda)
        )

    # Menghitung dan menampilkan FPS di pojok layar
    cTime = time.time()
    fps = 1 / (cTime - pTime)
    pTime = cTime
    cv2.putText(img, f'FPS: {int(fps)}', (20, 70), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 255, 0), 3)

    # 5. Tampilkan hasil akhirnya di sebuah jendela baru
    cv2.imshow('RUNFORM-AI - Uji Coba BlazePose', img)

    # Program akan berhenti jika kamu menekan tombol 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# 6. Bersihkan memori dan tutup kamera setelah selesai
cap.release()
cv2.destroyAllWindows()