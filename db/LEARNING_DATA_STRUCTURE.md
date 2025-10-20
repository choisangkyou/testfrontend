# 📚 학습 데이터 테이블 구조 가이드

## 🎯 전체 계층 구조

```
교재 (Books)
    ↓
강좌 (Lecture)
    ↓
지문 (Passage)
    ↓
┌───────────────┬─────────────────┬──────────────────┐
│               │                 │                  │
페이지          독해 문제        줄거리 순서       어휘
(Pages)        (Questions)      (Plot Items)     (Vocabulary)
    ↓              ↓                ↓               ↓
  내용          선택지            순서 배열        문제/선택지
             정보처리 답안
```

---

## 📖 1. 교재 계층 (Books Layer)

### **1-1. books (교재)**

```sql
CREATE TABLE books (
  book_id INT PRIMARY KEY AUTO_INCREMENT,
  book_name VARCHAR(255) NOT NULL,        -- 교재명
  volume_number INT NOT NULL,             -- 권 번호 (1권, 2권...)
  description TEXT NULL,                  -- 교재 설명
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY ux_book_volume (book_name, volume_number)
);
```

**데이터 예시:**
