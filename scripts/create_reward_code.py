#!/usr/bin/env python3
"""
Script tạo mã thưởng trên Firebase Firestore
Sử dụng: python create_reward_code.py

Yêu cầu:
- pip install firebase-admin
- File service account JSON từ Firebase Console
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random
import string

# ============ CẤU HÌNH ============
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"  # Đường dẫn file service account
# ==================================

def init_firebase():
    """Khởi tạo Firebase Admin SDK"""
    if not firebase_admin._apps:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    return firestore.client()

def generate_code(length=8):
    """Tạo mã ngẫu nhiên"""
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def create_reward_code(
    db,
    code: str = None,
    title: str = "Mã thưởng",
    description: str = "Nhập mã để nhận quà",
    coins: int = 0,
    diamonds: int = 0,
    xp: int = 0,
    expires_days: int = None,  # None = không hết hạn
    max_claims: int = 0,  # 0 = unlimited
):
    """
    Tạo mã thưởng mới trên Firebase
    
    Args:
        db: Firestore client
        code: Mã thưởng (tự động tạo nếu None)
        title: Tiêu đề mã
        description: Mô tả
        coins: Số coins thưởng
        diamonds: Số diamonds thưởng
        xp: Số XP thưởng
        expires_days: Số ngày hết hạn (None = vĩnh viễn)
        max_claims: Giới hạn lượt nhận (0 = không giới hạn)
    
    Returns:
        str: Mã đã tạo
    """
    if code is None:
        code = generate_code()
    
    code = code.upper().strip()
    
    # Kiểm tra mã đã tồn tại chưa
    doc_ref = db.collection('reward_codes').document(code)
    if doc_ref.get().exists:
        print(f"❌ Mã '{code}' đã tồn tại!")
        return None
    
    # Tạo data
    data = {
        'title': title,
        'description': description,
        'reward': {
            'coins': coins,
            'diamonds': diamonds,
            'xp': xp,
        },
        'created_at': firestore.SERVER_TIMESTAMP,
        'expires_at': None,
        'max_claims': max_claims,
        'current_claims': 0,
        'is_active': True,
    }
    
    # Thêm ngày hết hạn nếu có
    if expires_days is not None:
        expires_at = datetime.now() + timedelta(days=expires_days)
        data['expires_at'] = expires_at
    
    # Lưu lên Firebase
    doc_ref.set(data)
    
    print(f"\n✅ Đã tạo mã thưởng thành công!")
    print(f"{'='*40}")
    print(f"📝 Mã: {code}")
    print(f"📌 Tiêu đề: {title}")
    print(f"📄 Mô tả: {description}")
    print(f"💰 Coins: {coins:,}")
    print(f"💎 Diamonds: {diamonds:,}")
    print(f"⭐ XP: {xp:,}")
    if expires_days:
        print(f"⏰ Hết hạn: {expires_days} ngày")
    else:
        print(f"⏰ Hết hạn: Không")
    if max_claims > 0:
        print(f"👥 Giới hạn: {max_claims} lượt")
    else:
        print(f"👥 Giới hạn: Không giới hạn")
    print(f"{'='*40}\n")
    
    return code

def list_codes(db, show_inactive=False):
    """Liệt kê tất cả mã thưởng"""
    query = db.collection('reward_codes')
    if not show_inactive:
        query = query.where('is_active', '==', True)
    
    docs = query.stream()
    
    print(f"\n{'='*60}")
    print("📋 DANH SÁCH MÃ THƯỞNG")
    print(f"{'='*60}")
    
    count = 0
    for doc in docs:
        count += 1
        data = doc.to_dict()
        reward = data.get('reward', {})
        
        status = "✅" if data.get('is_active') else "❌"
        expires = data.get('expires_at')
        expires_str = expires.strftime('%d/%m/%Y') if expires else "Không"
        
        print(f"\n{status} {doc.id}")
        print(f"   📌 {data.get('title', 'N/A')}")
        print(f"   💰 {reward.get('coins', 0):,} | 💎 {reward.get('diamonds', 0):,} | ⭐ {reward.get('xp', 0):,}")
        print(f"   👥 {data.get('current_claims', 0)}/{data.get('max_claims', 0) or '∞'} | ⏰ {expires_str}")
    
    print(f"\n{'='*60}")
    print(f"Tổng: {count} mã")
    print(f"{'='*60}\n")

def deactivate_code(db, code: str):
    """Vô hiệu hóa mã thưởng"""
    code = code.upper().strip()
    doc_ref = db.collection('reward_codes').document(code)
    
    if not doc_ref.get().exists:
        print(f"❌ Mã '{code}' không tồn tại!")
        return False
    
    doc_ref.update({'is_active': False})
    print(f"✅ Đã vô hiệu hóa mã '{code}'")
    return True

def delete_code(db, code: str):
    """Xóa mã thưởng"""
    code = code.upper().strip()
    doc_ref = db.collection('reward_codes').document(code)
    
    if not doc_ref.get().exists:
        print(f"❌ Mã '{code}' không tồn tại!")
        return False
    
    doc_ref.delete()
    print(f"✅ Đã xóa mã '{code}'")
    return True

def interactive_menu():
    """Menu tương tác"""
    db = init_firebase()
    
    while True:
        print("\n" + "="*40)
        print("🎁 QUẢN LÝ MÃ THƯỞNG")
        print("="*40)
        print("1. Tạo mã thưởng mới")
        print("2. Tạo mã nhanh (random)")
        print("3. Xem danh sách mã")
        print("4. Vô hiệu hóa mã")
        print("5. Xóa mã")
        print("0. Thoát")
        print("="*40)
        
        choice = input("Chọn: ").strip()
        
        if choice == "1":
            print("\n--- TẠO MÃ THƯỞNG MỚI ---")
            code = input("Mã (Enter = tự động): ").strip() or None
            title = input("Tiêu đề: ").strip() or "Mã thưởng"
            description = input("Mô tả: ").strip() or "Nhập mã để nhận quà"
            coins = int(input("Coins (0): ").strip() or 0)
            diamonds = int(input("Diamonds (0): ").strip() or 0)
            xp = int(input("XP (0): ").strip() or 0)
            expires = input("Hết hạn sau (ngày, Enter = không): ").strip()
            expires_days = int(expires) if expires else None
            max_claims = int(input("Giới hạn lượt (0 = không): ").strip() or 0)
            
            create_reward_code(
                db, code, title, description,
                coins, diamonds, xp,
                expires_days, max_claims
            )
            
        elif choice == "2":
            print("\n--- TẠO MÃ NHANH ---")
            coins = int(input("Coins: ").strip() or 0)
            diamonds = int(input("Diamonds: ").strip() or 0)
            xp = int(input("XP: ").strip() or 0)
            
            create_reward_code(
                db, None, "Mã thưởng", "Nhập mã để nhận quà",
                coins, diamonds, xp
            )
            
        elif choice == "3":
            show_all = input("Hiện cả mã đã vô hiệu? (y/N): ").lower() == 'y'
            list_codes(db, show_all)
            
        elif choice == "4":
            code = input("Nhập mã cần vô hiệu hóa: ").strip()
            if code:
                deactivate_code(db, code)
                
        elif choice == "5":
            code = input("Nhập mã cần xóa: ").strip()
            if code:
                confirm = input(f"Xác nhận xóa '{code}'? (y/N): ").lower()
                if confirm == 'y':
                    delete_code(db, code)
                    
        elif choice == "0":
            print("👋 Tạm biệt!")
            break

if __name__ == "__main__":
    print("🚀 Khởi động script quản lý mã thưởng...")
    try:
        interactive_menu()
    except FileNotFoundError:
        print(f"\n❌ Không tìm thấy file '{SERVICE_ACCOUNT_PATH}'")
        print("📝 Hướng dẫn:")
        print("   1. Vào Firebase Console > Project Settings > Service Accounts")
        print("   2. Click 'Generate new private key'")
        print("   3. Lưu file JSON vào thư mục scripts/ với tên 'serviceAccountKey.json'")
    except Exception as e:
        print(f"\n❌ Lỗi: {e}")
