# SIKESAN API Documentation

Berikut adalah rangkuman representasi objek JSON untuk setiap *Endpoint* utama di aplikasi backend SIKESAN.

---

## 1. Authentication

### `POST /api/v1/auth/login`
**Payload:**
```json
{
  "username": "wali_123",
  "password": "password123"
}
```
**Response (200 OK):**
```json
{
  "access_token": "1|abcdef123456...",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "Bapak Fulan",
    "username": "wali_123",
    "email": "fulan@example.com",
    "roles": [
      {
        "id": 2,
        "name": "Wali Santri",
        "permissions": []
      }
    ]
  }
}
```

---

## 2. User Management (Super Admin & Admin)

### `GET /api/v1/users`
Mengambil daftar user. Mendukung pagination dan filter parameter `?role=Wali Santri&search=keyword`.
**Response (200 OK):**
```json
{
  "data": [
    {
      "id": 2,
      "username": "bapakbudi",
      "email": "budi@example.com",
      "roles": ["Wali Santri"],
      "created_at": "2026-09-18T10:00:00.000000Z",
      "updated_at": "2026-09-18T10:00:00.000000Z"
    }
  ],
  "links": { ... },
  "meta": { ... }
}
```

### `POST /api/v1/users`
Membuat user baru.
**Payload:**
```json
{
  "username": "bapakbudi",
  "email": "budi@example.com",
  "password": "password123",
  "role": "Wali Santri"
}
```
**Response (201 Created):**
```json
{
  "data": {
    "id": 2,
    "username": "bapakbudi",
    "email": "budi@example.com",
    "roles": ["Wali Santri"],
    "created_at": "2026-09-18T10:05:00.000000Z",
    "updated_at": "2026-09-18T10:05:00.000000Z"
  },
  "message": "User created successfully"
}
```

### `PUT /api/v1/users/{id}`
Mengubah data user (termasuk role). Password bersifat opsional (`nullable`).
**Payload:**
```json
{
  "username": "bapakbudi_update",
  "email": "budi_update@example.com",
  "role": "Wali Santri"
}
```
**Response (200 OK):**
```json
{
  "data": { ... },
  "message": "User updated successfully"
}
```

### `DELETE /api/v1/users/{id}`
Menghapus user. (Super Admin tidak bisa dihapus, akan menghasilkan `403 Forbidden`).
**Response (200 OK):**
```json
{
  "message": "User deleted successfully"
}
```

---

## 3. Dashboards

### `GET /api/v1/dashboard/guardian`
Menampilkan ringkasan metrik khusus Wali Santri (akumulasi dari semua anak yang terhubung dengannya).
**Response (200 OK):**
```json
{
  "message": "Guardian dashboard metrics retrieved successfully",
  "data": {
    "total_balance": 150000, 
    "total_unpaid_spp": 400000,
    "total_infaq_paid": 50000
  }
}
```

### `GET /api/v1/dashboard/treasurer`
Menampilkan ringkasan metrik global untuk Bendahara / Admin.
**Response (200 OK):**
```json
{
  "message": "Treasurer dashboard metrics retrieved successfully",
  "data": {
    "global_wallet_balance": 35000000,
    "total_unpaid_spp_overall": 12000000,
    "total_infaq_overall": 5000000
  }
}
```

---

## 4. Data Retrieval

### `GET /api/v1/students`
Bisa diakses oleh Wali (hanya melihat anaknya) maupun Admin (melihat semua). Mendukung pagination dan filter (`?class_id=1&status=ACTIVE&search=Budi`).
**Response (200 OK):**
```json
{
  "message": "Students retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "nis": "1001",
        "name": "Budi Santoso",
        "class_id": 2,
        "dormitory_id": 1,
        "status": "ACTIVE",
        "classroom": {
          "id": 2,
          "name": "Kelas 10 A"
        },
        "dormitory": {
          "id": 1,
          "name": "Asrama Putra Al-Fatih"
        },
        "wallet": {
          "id": 1,
          "balance": 150000
        }
      }
    ],
    "from": 1,
    "to": 1,
    "total": 1,
    "per_page": 15,
    "last_page": 1,
    "next_page_url": null,
    "prev_page_url": null,
    "links": [
      {
        "url": null,
        "label": "&laquo; Previous",
        "active": false
      },
      {
        "url": "http://localhost:8000/api/v1/students?page=1",
        "label": "1",
        "active": true
      },
      {
        "url": null,
        "label": "Next &raquo;",
        "active": false
      }
    ]
  }
}
```

### `GET /api/v1/transactions/wallet`
**Response (200 OK):**
```json
{
  "message": "Wallet transactions retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": "01h9x...",
        "wallet_id": 1,
        "type": "CREDIT",
        "amount": 500000,
        "balance_before": 10000,
        "balance_after": 510000,
        "reference_type": "App\\Models\\TopUpRequest",
        "reference_id": "01h9y...",
        "status": "SUCCESS",
        "created_at": "2026-09-08T10:00:00.000000Z"
      }
    ],
    "from": 1,
    "to": 10,
    "total": 10,
    "per_page": 15,
    "last_page": 1,
    "next_page_url": null,
    "prev_page_url": null,
    "links": [
      {
        "url": null,
        "label": "&laquo; Previous",
        "active": false
      },
      {
        "url": "http://localhost:8000/api/v1/transactions/wallet?page=1",
        "label": "1",
        "active": true
      },
      {
        "url": null,
        "label": "Next &raquo;",
        "active": false
      }
    ]
  }
}
```

---

## 5. Mutasi Finansial (POST)

### `POST /api/v1/top-ups` (Wali Request Top Up)
**Header:** `Idempotency-Key: uniq-uuid-1234`
**Payload:**
```json
{
  "student_id": 1,
  "requested_amount": 500000,
  "payment_method": "TRANSFER"
}
```
**Response (201 Created):**
```json
{
  "message": "Top up requested successfully",
  "data": {
    "id": "01h9x...",
    "student_id": 1,
    "requested_amount": 500000,
    "payment_method": "TRANSFER",
    "status": "PENDING"
  }
}
```

### `POST /api/v1/top-ups/{id}/approve` (Bendahara Approve Top Up)
**Response (200 OK):**
```json
{
  "message": "Top up request approved and wallet credited.",
  "data": {
    "id": "01h9x...",
    "status": "APPROVED"
  }
}
```

### `POST /api/v1/spp/payments` (Bendahara Bayar SPP via Wallet)
**Header:** `Idempotency-Key: uniq-uuid-5678`
**Payload:**
```json
{
  "student_id": 1,
  "bill_ids": ["01h9a...", "01h9b..."],
  "total_amount": 400000
}
```
**Response (201 Created):**
```json
{
  "message": "SPP Payment successful",
  "data": {
    "id": "01h9c...",
    "total_paid_amount": 400000,
    "payment_method": "WALLET",
    "payment_date": "2026-09-08",
    "bills": [
      {
        "id": "01h9a...",
        "period_month": 8,
        "period_year": 2026,
        "amount_billed": 200000,
        "status": "PAID"
      }
    ]
  }
}
```

### `POST /api/v1/infaqs` (Potong Uang Saku untuk Infaq)
**Payload:**
```json
{
  "student_id": 1,
  "category_id": 2,
  "amount": 50000,
  "notes": "Infaq Pembangunan Masjid"
}
```
**Response (201 Created):**
```json
{
  "message": "Infaq transaction recorded and wallet debited.",
  "data": {
    "id": "01h9d...",
    "amount": 50000,
    "status": "SUCCESS"
  }
}
```

---

## 6. Laporan Keuangan (Reports)

### `GET /api/v1/reports/ledger`
Menggabungkan riwayat dari berbagai jenis tabel transaksi secara kronologis.
**Response (200 OK):**
```json
{
  "message": "Ledger retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "date": "2026-09-08 10:15:00",
        "type": "SPP_PAYMENT",
        "description": "Pembayaran SPP via Wallet untuk Budi Santoso",
        "amount": 200000,
        "reference_id": "01h9x..."
      },
      {
        "date": "2026-09-08 09:00:00",
        "type": "TOP_UP",
        "description": "Top Up Wallet Budi Santoso disetujui",
        "amount": 500000,
        "reference_id": "01h9y..."
      }
    ],
    "from": 1,
    "to": 2,
    "total": 2,
    "per_page": 15,
    "last_page": 1,
    "next_page_url": null,
    "prev_page_url": null,
    "links": [
      {
        "url": null,
        "label": "&laquo; Previous",
        "active": false
      },
      {
        "url": "http://localhost:8000/api/v1/reports/ledger?page=1",
        "label": "1",
        "active": true
      },
      {
        "url": null,
        "label": "Next &raquo;",
        "active": false
      }
    ]
  }
}
```

---

## 7. Standar Respon Error (Error Handling)

Untuk membangun mekanisme *Error Handling* global (misal: menggunakan Axios Interceptors) dan form validasi, berikut adalah struktur standar respon error dari Laravel SIKESAN:

### 1. `422 Unprocessable Entity` (Validation Error)
Sering terjadi saat submit form (misal: saat *request top up* dengan format salah). Respon ini akan otomatis ditangkap oleh React Hook Form jika di- *mapping* dengan benar.
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "student_id": [
      "The selected student id is invalid."
    ],
    "requested_amount": [
      "The requested amount must be at least 10000."
    ]
  }
}
```

### 2. `401 Unauthorized` (Unauthenticated)
Terjadi saat *Bearer Token* tidak dikirim, *expired*, atau tidak valid. *Frontend* harus menghapus *session/cookie* dan *redirect* ke halaman login.
```json
{
  "message": "Unauthenticated."
}
```

### 3. `403 Forbidden` (Unauthorized Action)
Terjadi saat user sudah login, namun mencoba mengakses *resource* atau rute yang tidak diizinkan oleh perannya (misal: Wali mencoba memanggil rute khusus Bendahara).
```json
{
  "message": "This action is unauthorized."
}
```

### 4. `400 Bad Request` (Business Logic Error)
Dikembalikan secara manual oleh sistem saat ada logika bisnis yang dilanggar (misal: mencoba meng-*approve* request yang sudah di-*approve*).
```json
{
  "message": "Only PENDING requests can be approved"
}
```

### 5. `404 Not Found` (Not Found / Data Scoped Out)
Dikembalikan jika data memang tidak ada di database, **ATAU** jika pengguna (contoh: Wali Santri) mencoba mengakses data anak/transaksi milik orang lain. Sistem *Global Scope* akan otomatis menyembunyikan data tersebut dari pandangan *user* yang tidak berhak, seolah-olah data tersebut tidak pernah ada (Mencegah ID *Enumeration*).
```json
{
  "message": "No query results for model [App\\Models\\Student] 2"
}
```
