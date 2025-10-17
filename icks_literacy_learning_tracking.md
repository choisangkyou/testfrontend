### 사용자 학습 추적 (User Learning Tracking)

```mermaid

graph TD
U[user] -->|1:1| P[user_learning_profile]
U -->|1:N| LP[user_lecture_progress]
L[lecture] -->|1:N| LP

    LP -->|1:N| SP[user_lecture_section_progress]
    LS[lesson_section] -->|1:N| SP

    LIGHT[light_status] -.->|참조| SP

    U -->|1:N| VS[user_vocab_status]
    V[vocabulary] -->|1:N| VS

    U -->|1:N| VR[user_vocab_question_result]
    VQ[vocab_question] -->|1:N| VR

```

### 어휘 학습 구조(Vocabulary Learning)

```mermaid
graph TD
    L[lecture] -->|1:N| V[vocabulary]

    V -->|1:N| VQ[vocab_question]
    VQ -->|1:N| VC[vocab_choice]

    U[user] -->|M:N| VS[user_vocab_status]
    V -->|M:N| VS

    U -->|M:N| VR[user_vocab_question_result]
    VQ -->|M:N| VR
    VC -.->|참조| VR
```

### 서술형 요약 구조 (Descriptive Summary)

````mermaid
    graph TD
    B[books] -->|N:1| DS[descript_summary]
    L[lecture] -->|N:1| DS

    DS -->|1:N| H[descript_summary_hint]

    U[user] -->|1:N| HR[user_descript_hint_response]
    H -->|1:N| HR

    U -->|1:N| SR[user_descript_summary_result]
    DS -->|1:N| SR

    U -->|1:N| SP[user_descript_summary_progress]
    B -->|1:N| SP
    L -->|1:N| SP
    ```
````
