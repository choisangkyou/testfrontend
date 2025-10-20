# 📖 읽쓰문해력 8단계 학습 프로세스 구조 분석

## 🎯 전체 구조 개요

```
사용자(user)
    ↓
강좌 선택(lecture)
    ↓
지문 선택(passage)
    ↓
학습 세션 생성(user_learning_session)
    ↓
┌─────────────────────────────────────────┐
│         8단계 순차 학습 프로세스           │
└─────────────────────────────────────────┘
    ↓
최종 결과 저장(step8_final_result)
```

---

## 📊 8단계 상세 흐름도

```mermaid
graph TB
    START[학습 세션 시작] --> STEP1[Step 1: 처음 읽기]

    STEP1 --> STEP2[Step 2: 문제 확인]
    STEP2 --> DECISION1{모르는 문제<br/>있나요?}

    DECISION1 -->|Yes| STEP3[Step 3: 다시 읽기]
    DECISION1 -->|No| STEP4[Step 4: 문제 풀이]

    STEP3 --> STEP2_RETRY[Step 2 재시도: 문제 재확인]
    STEP2_RETRY --> DECISION2{여전히 모르는<br/>문제 있나요?}

    DECISION2 -->|Yes| STEP4
    DECISION2 -->|No| STEP4

    STEP4 --> STEP5[Step 5: 정보 처리]
    STEP5 --> STEP6[Step 6: 줄거리 순서]

    STEP6 --> DECISION3{정답<br/>맞췄나요?}
    DECISION3 -->|No, 1회 실패| STEP6_RETRY[Step 6 재시도: 2회 기회]
    DECISION3 -->|Yes or 2회 실패| STEP7[Step 7: 어휘 문제]
    STEP6_RETRY --> STEP7

    STEP7 --> STEP8[Step 8: 최종 결과 통합]
    STEP8 --> END[학습 세션 완료]

    style START fill:#e1f5ff
    style END fill:#c8e6c9
    style STEP1 fill:#fff9c4
    style STEP2 fill:#fff9c4
    style STEP3 fill:#ffecb3
    style STEP4 fill:#ffe0b2
    style STEP5 fill:#ffccbc
    style STEP6 fill:#f8bbd0
    style STEP7 fill:#e1bee7
    style STEP8 fill:#c5cae9
    style DECISION1 fill:#ffcdd2
    style DECISION2 fill:#ffcdd2
    style DECISION3 fill:#ffcdd2
```
