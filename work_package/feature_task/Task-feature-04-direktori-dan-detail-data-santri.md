# Task-feature-04: Implementasi Modul Direktori & Detail Data Santri

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-04` |
| **Prioritas** | **P1 - High** |
| **Epic / Modul** | Manajemen Kesiswaan & Profil Santri |
| **Komponen Terkait** | Dashboard menu `data_santri`, `ApiEndpoints.students`, `SppRepository.getStudents` |
| **Status** | Backlog / Belum Diimplementasikan |

---

## 1. Latar Belakang & Masalah Saat Ini
Pada dashboard menu grid, terdapat tombol menu **"Data Santri"** (`id: 'data_santri'`) untuk role *Staff Kesantrian*, *Bendahara*, dan *Admin*.
Meskipun backend telah memiliki endpoint `/students` (dan method `getStudents()` sudah ada di `SppRepository`), di aplikasi mobile:
- **Belum ada layar daftar santri** (`StudentListScreen`).
- Mengklik menu "Data Santri" di dashboard tidak memicu tindakan apa pun (*no-op*).
- Belum ada layar biodata santri, detail kelas, kamar/asrama, status kelulusan, dan ringkasan keuangan per santri.

---

## 2. User Story
- **Sebagai Staff Kesantrian / Bendahara**, saya ingin mencari santri berdasarkan nama/NIS, menyaring berdasarkan kelas atau asrama, dan melihat status keuangan serta data wali santri.
- **Sebagai Wali Santri**, saya ingin melihat profil santri (anak saya), riwayat penempatan kamar asrama, dan rekapitulasi uang saku santri.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Layar Direktori Santri (`StudentListScreen`)**:
   - Kolom pencarian real-time (Nama / NIS / NISN).
   - Filter dropdown kelas (Kelas 7 s/d 12) dan status asrama.
   - List santri menampilkan: Foto profil, Nama Lengkap, NIS, Kelas, Asrama, dan badge status keuangan (Lunas / Ada Tunggakan).
2. **Layar Detail Santri (`StudentDetailScreen`)**:
   - Kartu Identitas Digital Santri (dilengkapi barcode/QR Code NIS untuk absensi atau belanja di kantin).
   - Tab 1: Biodata Lengkap & Kontak Wali Santri.
   - Tab 2: Ringkasan Tagihan SPP & Tunggakan.
   - Tab 3: Saldo Dompet Santri & Riwayat Uang Saku Terakhir.
   - Tombol cepat aksi: *"Bayar SPP Santri Ini"* atau *"Kirim Pesan ke Wali"*.

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/students`
  - Query: `search`, `class`, `dormitory`, `page`, `per_page`
- `GET /api/v1/students/{id}`
  - Response lengkap: profil, data wali, rincian kamar, saldo dompet saat ini, tunggakan SPP belum lunas.

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Mengetuk menu "Data Santri" di dashboard membuka `StudentListScreen`.
- [ ] Pengguna dapat mencari nama santri secara cepat dengan debounce search.
- [ ] Memilih santri menampilkan profil komprehensif beserta QR/Barcode santri dan status keuangannya.
- [ ] Rute baru terdaftar rapi di `AppRouter`.
