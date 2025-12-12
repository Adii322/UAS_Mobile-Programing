
# 📱young_care 
Aplikasi artikel bertema **Run App** berbasis Flutter, menggunakan **Supabase** sebagai backend dan **GetX** untuk state management.  
Aplikasi ini menyediakan artikel Islami, edukasi kesehatan, serta fitur run traking system dan sistem autentikasi pengguna yang aman dan modern.

## 🚀 Fitur Utama

- 🔐 **Autentikasi Pengguna**  
  Register, Login, Logout, dan Session Management menggunakan Supabase Auth.

- 📚 **Manajemen Run traking**  
  Menampilkan daftar run traking yang tersimpan di Supabase Database.

- ⚡ **State Management dengan GetX**  
  Controller, routing, reaktif, dan dependency injection.

- 🌐  **Artikel API Eksternal**  
  Mendukung integrasi API artikel.

## 🏗️ Arsitektur Teknologi

| Layer | Teknologi |
|-------|-----------|
| Frontend | Flutter + GetX |
| Backend | Supabase (Auth, DB, Storage) |
| State Management | GetX Controller |
| Networking | Supabase Dart SDK |
| Eksternal API | (Opsional) Hadith API / Quran API |

## 📡 Daftar Endpoint API

### 🔐 **Authentication API**
| Operation | Method | Endpoint |
|-----------|--------|----------|
| Register | POST | `/auth/v1/signup` |
| Login | POST | `/auth/v1/token?grant_type=password` |
| Logout | POST | `/auth/v1/logout` |

### 📚 **Articles API (Supabase DB Table: `articles`)**
| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get All Articles | GET | `/rest/v1/articles?select=*` |
| Get Article by ID | GET | `/rest/v1/articles?id=eq.{id}` |
| Create Article | POST | `/rest/v1/articles` |
| Update Article | PATCH | `/rest/v1/articles?id=eq.{id}` |
| Delete Article | DELETE | `/rest/v1/articles?id=eq.{id}` |

### 🖼️ **Storage API**
| Operation | Method | Endpoint |
|-----------|--------|----------|
| Upload Image | POST | `/storage/v1/object/articles_images/{file}` |
| Get Public URL | GET | `/storage/v1/object/public/articles_images/{file}` |

## 📦 Instalasi & Setup

### 1️⃣ Clone Repository
```bash
git clone https://github.com/username/project.git
cd project
````

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Konfigurasi Supabase

Buka file:

```
lib/env.dart
```

Isi dengan:

```dart
const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
const SUPABASE_KEY = "YOUR-PUBLIC-ANON-KEY";
```

### 4️⃣ Jalankan Aplikasi

```bash
flutter run
```

## 📁 Struktur Folder Utama

```
lib/
 ├─ app/
 │   ├─ modules/
 │   ├─ routes/
 │   ├─ data/
 │   └─ common/
 ├─ core/
 └─ main.dart
```

* `modules/` → halaman + controller
* `data/` → provider API (Supabase, HTTP)
* `routes/` → manajemen navigasi GetX
* `common/` → component dan theme

## 🧩 Cara Kerja Aplikasi (Flow)

### 🔐 Login Flow

```
User → Login Page → AuthController → Supabase Auth → Home Page
```

### 📚 Artikel Flow

```
Home → ArticleController → Supabase DB → Article List
```

### 🖼️ Upload Gambar (Admin)

```
Upload → Supabase Storage → Simpan URL → Tampilkan di Artikel
```

## ✨ Preview UI (Opsional Tambahkan Screenshot)

| Login                      | Home                     | Detail Artikel               |
| -------------------------- | ------------------------ | ---------------------------- |
| ![login](assets/Screenshot%202025-10-30%20135949.png) | ![home](assets/Screenshot%202025-11-01%20221456.png) | ![detail](assets/Screenshot%202025-11-01%20221109.png) |


## 🤝 Kontribusi

Pull Request dan masukan sangat diterima!
Gunakan branch baru sebelum melakukan PR.

## 📄 Lisensi

Proyek ini menggunakan lisensi **MIT License**.

## 👤 Author

Created by **Adi** ❤️
Aplikasi untuk edukasi dan keperluan pembelajaran.


