# Lịch ca & Chia tiền

Ứng dụng web tĩnh bằng HTML, CSS và JavaScript thuần. Có thể mở trực tiếp `index.html` hoặc triển khai bằng GitHub Pages.

## Tính năng

- Lịch ca ngày/đêm theo chu kỳ làm 12 tiếng, nghỉ 24 tiếng; đồng hồ dùng múi giờ Việt Nam.
- Theo dõi ca tiếp theo, ngày nghỉ lễ và các mốc giờ vào/ra theo từng ngày.
- Ghi khoản chi của Phương, Dũng, Dương; chia đều và làm tròn số tiền hiển thị theo nghìn đồng.
- Lịch sử chi tiêu được lưu trong `localStorage` của trình duyệt đang dùng. Dữ liệu chi tiêu không được gửi lên GitHub.

## Chạy trên máy

Mở `index.html` trong trình duyệt.

## Triển khai với GitHub Pages

Sau khi đẩy mã lên nhánh `main`, vào **Settings → Pages**, chọn **Deploy from a branch**, chọn nhánh `main` và thư mục `/(root)`, rồi lưu. GitHub sẽ cung cấp địa chỉ trang Pages trong mục này.

Mỗi lần cập nhật mã và đẩy commit mới lên `main`, GitHub Pages sẽ cập nhật trang.
