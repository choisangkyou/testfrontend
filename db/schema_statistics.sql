/*
================================================================================
읽쓰문해력 통계 테이블 추가
================================================================================

[ 추가 테이블 ]
1. user_reading_statistics - 사용자별 읽기 통계 (누적)
2. grade_reading_statistics - 학년별 평균 읽기 통계
3. reading_speed_benchmark - 학년별 읽기 속도 기준
4. user_performance_summary - 사용자 종합 성과 요약

[ 통계 갱신 방법 ]
- 실시간: 트리거 자동 갱신
- 배치: 저장 프로시저 수동 실행

================================================================================
*/

-- ============================================
-- 1. 사용자별 읽기 통계 (누적)
-- ============================================

CREATE TABLE IF NOT EXISTS user_reading_statistics (
  stat_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  
  -- 읽기 기본 통계
  total_sessions INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '총 학습 세션 수',
  total_passages INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '읽은 지문 수',
  total_reading_time_sec INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '총 읽기 시간(초)',
  
  -- 처음 읽기 통계
  first_reading_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '처음 읽기 횟수',
  first_reading_total_time_sec INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '처음 읽기 총 시간',
  first_reading_total_chars INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '처음 읽기 총 글자수',
  first_reading_avg_cpm DECIMAL(8,2) NULL COMMENT '처음 읽기 평균 CPM',
  
  -- 다시 읽기 통계
  rereading_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '다시 읽기 횟수',
  rereading_total_time_sec INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '다시 읽기 총 시간',
  rereading_total_chars INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '다시 읽기 총 글자수',
  rereading_avg_cpm DECIMAL(8,2) NULL COMMENT '다시 읽기 평균 CPM',
  
  -- 전체 평균
  overall_avg_cpm DECIMAL(8,2) NULL COMMENT '전체 평균 CPM',
  
  -- 읽기 수준 평가
  reading_level VARCHAR(20) NULL COMMENT '읽기 수준 (초급/중급/고급)',
  compared_to_grade VARCHAR(50) NULL COMMENT '학년 대비 수준 (느림/보통/빠름)',
  
  -- 갱신 정보
  last_session_date DATETIME NULL COMMENT '마지막 학습 일시',
  calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '통계 계산 일시',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE INDEX ux_user_reading_stat (user_id),
  INDEX idx_reading_level (reading_level),
  INDEX idx_avg_cpm (overall_avg_cpm),
  
  CONSTRAINT fk_user_reading_stat_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='사용자별 읽기 통계 (누적)';

-- ============================================
-- 2. 학년별 평균 읽기 통계
-- ============================================

CREATE TABLE IF NOT EXISTS grade_reading_statistics (
  grade_stat_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade VARCHAR(20) NOT NULL COMMENT '학년 (초1, 초2, ... 중1, 중2, ...)',
  
  -- 참여자 통계
  total_users INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '해당 학년 총 사용자 수',
  active_users INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '활성 사용자 수',
  
  -- 읽기 속도 통계
  avg_first_reading_cpm DECIMAL(8,2) NULL COMMENT '학년 평균 처음읽기 CPM',
  avg_rereading_cpm DECIMAL(8,2) NULL COMMENT '학년 평균 다시읽기 CPM',
  avg_overall_cpm DECIMAL(8,2) NULL COMMENT '학년 전체 평균 CPM',
  
  -- 분포 통계
  min_cpm DECIMAL(8,2) NULL COMMENT '최소 CPM',
  max_cpm DECIMAL(8,2) NULL COMMENT '최대 CPM',
  std_dev_cpm DECIMAL(8,2) NULL COMMENT 'CPM 표준편차',
  
  -- 백분위수
  percentile_25_cpm DECIMAL(8,2) NULL COMMENT '하위 25% CPM',
  percentile_50_cpm DECIMAL(8,2) NULL COMMENT '중위값 CPM',
  percentile_75_cpm DECIMAL(8,2) NULL COMMENT '상위 25% CPM',
  
  -- 학습량 통계
  avg_sessions_per_user DECIMAL(8,2) NULL COMMENT '사용자당 평균 세션 수',
  avg_passages_per_user DECIMAL(8,2) NULL COMMENT '사용자당 평균 지문 수',
  
  -- 갱신 정보
  calculation_period VARCHAR(50) NULL COMMENT '집계 기간 (예: 2024-01)',
  calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '통계 계산 일시',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE INDEX ux_grade_period (grade, calculation_period),
  INDEX idx_grade (grade),
  INDEX idx_avg_cpm (avg_overall_cpm)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='학년별 평균 읽기 통계';

-- ============================================
-- 3. 학년별 읽기 속도 기준 (벤치마크)
-- ============================================

CREATE TABLE IF NOT EXISTS reading_speed_benchmark (
  benchmark_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade VARCHAR(20) NOT NULL COMMENT '학년',
  
  -- CPM 기준
  slow_max_cpm DECIMAL(8,2) NOT NULL COMMENT '느림 최대값',
  normal_min_cpm DECIMAL(8,2) NOT NULL COMMENT '보통 최소값',
  normal_max_cpm DECIMAL(8,2) NOT NULL COMMENT '보통 최대값',
  fast_min_cpm DECIMAL(8,2) NOT NULL COMMENT '빠름 최소값',
  
  -- 권장 수치
  recommended_cpm DECIMAL(8,2) NOT NULL COMMENT '권장 CPM',
  
  -- 기준 설명
  description TEXT NULL COMMENT '기준 설명',
  reference_source VARCHAR(255) NULL COMMENT '기준 출처',
  
  -- 활성화 여부
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  effective_from DATE NOT NULL COMMENT '적용 시작일',
  effective_to DATE NULL COMMENT '적용 종료일',
  
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE INDEX ux_grade_benchmark (grade, effective_from),
  INDEX idx_grade (grade),
  INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='학년별 읽기 속도 기준';

-- ============================================
-- 4. 사용자 종합 성과 요약
-- ============================================

CREATE TABLE IF NOT EXISTS user_performance_summary (
  summary_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  summary_period VARCHAR(20) NOT NULL COMMENT '요약 기간 (weekly, monthly, all)',
  period_start DATE NULL COMMENT '기간 시작일',
  period_end DATE NULL COMMENT '기간 종료일',
  
  -- 읽기 성과
  reading_sessions INT UNSIGNED NOT NULL DEFAULT 0,
  avg_reading_cpm DECIMAL(8,2) NULL,
  reading_improvement_rate DECIMAL(5,2) NULL COMMENT 'CPM 향상률 (%)',
  
  -- 문제 풀이 성과
  total_questions_attempted INT UNSIGNED NOT NULL DEFAULT 0,
  total_questions_correct INT UNSIGNED NOT NULL DEFAULT 0,
  overall_accuracy_rate DECIMAL(5,2) NULL COMMENT '전체 정답률 (%)',
  
  -- 문제 유형별 정답률
  vocab_accuracy_rate DECIMAL(5,2) NULL COMMENT '어휘 정답률',
  fact_accuracy_rate DECIMAL(5,2) NULL COMMENT '사실 정답률',
  inference_accuracy_rate DECIMAL(5,2) NULL COMMENT '추론 정답률',
  critical_accuracy_rate DECIMAL(5,2) NULL COMMENT '비판 정답률',
  
  -- 학습 패턴
  avg_study_time_min INT UNSIGNED NULL COMMENT '평균 학습시간(분)',
  total_study_time_min INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '총 학습시간(분)',
  
  -- 랭킹 정보
  grade_rank INT UNSIGNED NULL COMMENT '학년 내 순위',
  grade_total_users INT UNSIGNED NULL COMMENT '학년 총 인원',
  percentile DECIMAL(5,2) NULL COMMENT '백분위 순위',
  
  calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE INDEX ux_user_period (user_id, summary_period, period_start),
  INDEX idx_user (user_id),
  INDEX idx_period (summary_period),
  
  CONSTRAINT fk_performance_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='사용자 종합 성과 요약';

-- ============================================
-- 5. 통계 자동 갱신 트리거
-- ============================================

-- Step 1 완료 시 읽기 통계 갱신
DELIMITER $$

CREATE TRIGGER trg_after_step1_insert
AFTER INSERT ON step1_first_reading
FOR EACH ROW
BEGIN
    DECLARE v_user_id INT;
    
    -- 세션의 user_id 조회
    SELECT user_id INTO v_user_id
    FROM user_learning_session
    WHERE session_id = NEW.session_id;
    
    -- user_reading_statistics 갱신 (없으면 생성)
    INSERT INTO user_reading_statistics (
        user_id,
        total_sessions,
        first_reading_count,
        first_reading_total_time_sec,
        first_reading_total_chars,
        first_reading_avg_cpm,
        overall_avg_cpm,
        last_session_date
    ) VALUES (
        v_user_id,
        1,
        1,
        NEW.reading_time_sec,
        NEW.total_characters,
        NEW.chars_per_minute,
        NEW.chars_per_minute,
        NEW.started_at
    )
    ON DUPLICATE KEY UPDATE
        total_sessions = total_sessions + 1,
        first_reading_count = first_reading_count + 1,
        first_reading_total_time_sec = first_reading_total_time_sec + NEW.reading_time_sec,
        first_reading_total_chars = first_reading_total_chars + NEW.total_characters,
        first_reading_avg_cpm = (first_reading_total_chars + NEW.total_characters) / 
                                ((first_reading_total_time_sec + NEW.reading_time_sec) / 60.0),
        overall_avg_cpm = (first_reading_total_chars + NEW.total_characters) / 
                         ((first_reading_total_time_sec + NEW.reading_time_sec) / 60.0),
        last_session_date = NEW.started_at,
        calculated_at = CURRENT_TIMESTAMP;
END$$

-- Step 3 완료 시 다시읽기 통계 갱신
CREATE TRIGGER trg_after_step3_insert
AFTER INSERT ON step3_rereading
FOR EACH ROW
BEGIN
    DECLARE v_user_id INT;
    
    SELECT user_id INTO v_user_id
    FROM user_learning_session
    WHERE session_id = NEW.session_id;
    
    UPDATE user_reading_statistics
    SET 
        rereading_count = rereading_count + 1,
        rereading_total_time_sec = rereading_total_time_sec + NEW.reading_time_sec,
        rereading_total_chars = rereading_total_chars + NEW.total_characters,
        rereading_avg_cpm = (rereading_total_chars + NEW.total_characters) / 
                           ((rereading_total_time_sec + NEW.reading_time_sec) / 60.0),
        overall_avg_cpm = (first_reading_total_chars + rereading_total_chars + NEW.total_characters) / 
                         ((first_reading_total_time_sec + rereading_total_time_sec + NEW.reading_time_sec) / 60.0),
        calculated_at = CURRENT_TIMESTAMP
    WHERE user_id = v_user_id;
END$$

DELIMITER ;

-- ============================================
-- 6. 학년별 통계 갱신 프로시저
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_update_grade_reading_statistics(
    IN p_grade VARCHAR(20),
    IN p_period VARCHAR(50)
)
BEGIN
    /*
    [ 학년별 읽기 통계 갱신 프로시저 ]
    
    특정 학년의 읽기 통계를 집계하여 grade_reading_statistics에 저장
    
    파라미터:
    - p_grade: 학년 (예: '초3', '중1')
    - p_period: 집계 기간 (예: '2024-01', 'all')
    
    사용법:
    CALL sp_update_grade_reading_statistics('초3', '2024-01');
    CALL sp_update_grade_reading_statistics('초3', 'all');
    */
    
    INSERT INTO grade_reading_statistics (
        grade,
        total_users,
        active_users,
        avg_first_reading_cpm,
        avg_rereading_cpm,
        avg_overall_cpm,
        min_cpm,
        max_cpm,
        std_dev_cpm,
        percentile_25_cpm,
        percentile_50_cpm,
        percentile_75_cpm,
        avg_sessions_per_user,
        avg_passages_per_user,
        calculation_period,
        calculated_at
    )
    SELECT 
        p_grade,
        COUNT(DISTINCT urs.user_id) AS total_users,
        SUM(CASE WHEN urs.last_session_date >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) AS active_users,
        AVG(urs.first_reading_avg_cpm) AS avg_first_reading_cpm,
        AVG(urs.rereading_avg_cpm) AS avg_rereading_cpm,
        AVG(urs.overall_avg_cpm) AS avg_overall_cpm,
        MIN(urs.overall_avg_cpm) AS min_cpm,
        MAX(urs.overall_avg_cpm) AS max_cpm,
        STDDEV(urs.overall_avg_cpm) AS std_dev_cpm,
        (SELECT overall_avg_cpm FROM user_reading_statistics urs2 
         JOIN user u2 ON urs2.user_id = u2.user_id 
         WHERE u2.grade = p_grade AND urs2.overall_avg_cpm IS NOT NULL
         ORDER BY urs2.overall_avg_cpm 
         LIMIT 1 OFFSET (COUNT(*) * 0.25)) AS percentile_25_cpm,
        (SELECT overall_avg_cpm FROM user_reading_statistics urs2 
         JOIN user u2 ON urs2.user_id = u2.user_id 
         WHERE u2.grade = p_grade AND urs2.overall_avg_cpm IS NOT NULL
         ORDER BY urs2.overall_avg_cpm 
         LIMIT 1 OFFSET (COUNT(*) * 0.50)) AS percentile_50_cpm,
        (SELECT overall_avg_cpm FROM user_reading_statistics urs2 
         JOIN user u2 ON urs2.user_id = u2.user_id 
         WHERE u2.grade = p_grade AND urs2.overall_avg_cpm IS NOT NULL
         ORDER BY urs2.overall_avg_cpm 
         LIMIT 1 OFFSET (COUNT(*) * 0.75)) AS percentile_75_cpm,
        AVG(urs.total_sessions) AS avg_sessions_per_user,
        AVG(urs.total_passages) AS avg_passages_per_user,
        p_period,
        CURRENT_TIMESTAMP
    FROM user_reading_statistics urs
    JOIN user u ON urs.user_id = u.user_id
    WHERE u.grade = p_grade
    ON DUPLICATE KEY UPDATE
        total_users = VALUES(total_users),
        active_users = VALUES(active_users),
        avg_first_reading_cpm = VALUES(avg_first_reading_cpm),
        avg_rereading_cpm = VALUES(avg_rereading_cpm),
        avg_overall_cpm = VALUES(avg_overall_cpm),
        min_cpm = VALUES(min_cpm),
        max_cpm = VALUES(max_cpm),
        std_dev_cpm = VALUES(std_dev_cpm),
        percentile_25_cpm = VALUES(percentile_25_cpm),
        percentile_50_cpm = VALUES(percentile_50_cpm),
        percentile_75_cpm = VALUES(percentile_75_cpm),
        avg_sessions_per_user = VALUES(avg_sessions_per_user),
        avg_passages_per_user = VALUES(avg_passages_per_user),
        calculated_at = CURRENT_TIMESTAMP;
        
    SELECT CONCAT('✅ ', p_grade, ' 학년 통계가 갱신되었습니다.') AS status;
END$$

DELIMITER ;

-- ============================================
-- 7. 사용자 읽기 수준 평가 프로시저
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_evaluate_user_reading_level(
    IN p_user_id INT
)
BEGIN
    /*
    [ 사용자 읽기 수준 평가 프로시저 ]
    
    사용자의 평균 CPM을 학년 평균과 비교하여 읽기 수준 평가
    
    평가 기준:
    - 느림: 학년 평균 75% 미만
    - 보통: 학년 평균 75% ~ 125%
    - 빠름: 학년 평균 125% 초과
    */
    
    DECLARE v_user_grade VARCHAR(20);
    DECLARE v_user_cpm DECIMAL(8,2);
    DECLARE v_grade_avg_cpm DECIMAL(8,2);
    DECLARE v_compared_to_grade VARCHAR(50);
    DECLARE v_reading_level VARCHAR(20);
    
    -- 사용자 학년 및 CPM 조회
    SELECT u.grade, urs.overall_avg_cpm
    INTO v_user_grade, v_user_cpm
    FROM user u
    JOIN user_reading_statistics urs ON u.user_id = urs.user_id
    WHERE u.user_id = p_user_id;
    
    -- 학년 평균 CPM 조회
    SELECT avg_overall_cpm
    INTO v_grade_avg_cpm
    FROM grade_reading_statistics
    WHERE grade = v_user_grade
      AND calculation_period = 'all'
    ORDER BY calculated_at DESC
    LIMIT 1;
    
    -- 비교 평가
    IF v_user_cpm < (v_grade_avg_cpm * 0.75) THEN
        SET v_compared_to_grade = '느림 (학년 평균 대비 75% 미만)';
    ELSEIF v_user_cpm > (v_grade_avg_cpm * 1.25) THEN
        SET v_compared_to_grade = '빠름 (학년 평균 대비 125% 초과)';
    ELSE
        SET v_compared_to_grade = '보통 (학년 평균 수준)';
    END IF;
    
    -- 절대 수준 평가 (기준표 참조)
    SELECT 
        CASE 
            WHEN v_user_cpm <= rb.slow_max_cpm THEN '초급'
            WHEN v_user_cpm >= rb.fast_min_cpm THEN '고급'
            ELSE '중급'
        END
    INTO v_reading_level
    FROM reading_speed_benchmark rb
    WHERE rb.grade = v_user_grade
      AND rb.is_active = 1
      AND CURDATE() BETWEEN rb.effective_from AND COALESCE(rb.effective_to, '9999-12-31')
    LIMIT 1;
    
    -- 통계 테이블 업데이트
    UPDATE user_reading_statistics
    SET 
        reading_level = v_reading_level,
        compared_to_grade = v_compared_to_grade,
        calculated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
    
    -- 결과 반환
    SELECT 
        p_user_id AS user_id,
        v_user_grade AS grade,
        v_user_cpm AS my_avg_cpm,
        v_grade_avg_cpm AS grade_avg_cpm,
        ROUND((v_user_cpm / v_grade_avg_cpm) * 100, 2) AS compared_percentage,
        v_reading_level AS reading_level,
        v_compared_to_grade AS compared_to_grade;
END$$

DELIMITER ;

-- ============================================
-- 8. 통계 조회 뷰
-- ============================================

-- 사용자 vs 학년 평균 비교 뷰
CREATE OR REPLACE VIEW v_user_vs_grade_reading AS
SELECT 
    u.user_id,
    u.user_name,
    u.grade,
    urs.overall_avg_cpm AS my_avg_cpm,
    grs.avg_overall_cpm AS grade_avg_cpm,
    ROUND((urs.overall_avg_cpm / grs.avg_overall_cpm) * 100, 2) AS percentage_of_grade_avg,
    urs.reading_level,
    urs.compared_to_grade,
    urs.total_sessions,
    urs.last_session_date
FROM user u
JOIN user_reading_statistics urs ON u.user_id = urs.user_id
LEFT JOIN grade_reading_statistics grs ON u.grade = grs.grade AND grs.calculation_period = 'all'
WHERE urs.overall_avg_cpm IS NOT NULL
ORDER BY u.grade, urs.overall_avg_cpm DESC;

-- 학년별 상위권 학생 뷰
CREATE OR REPLACE VIEW v_grade_top_readers AS
SELECT 
    u.grade,
    u.user_id,
    u.user_name,
    urs.overall_avg_cpm,
    urs.total_sessions,
    urs.total_passages,
    RANK() OVER (PARTITION BY u.grade ORDER BY urs.overall_avg_cpm DESC) AS grade_rank
FROM user u
JOIN user_reading_statistics urs ON u.user_id = urs.user_id
WHERE urs.overall_avg_cpm IS NOT NULL
ORDER BY u.grade, grade_rank;

-- ============================================
-- 9. 기준 데이터 초기 입력
-- ============================================

-- 학년별 읽기 속도 기준 (예시)
INSERT INTO reading_speed_benchmark (
    grade, slow_max_cpm, normal_min_cpm, normal_max_cpm, fast_min_cpm, 
    recommended_cpm, description, effective_from
) VALUES
('초1', 150, 151, 250, 251, 200, '초등 1학년 읽기 속도 기준', '2024-01-01'),
('초2', 200, 201, 300, 301, 250, '초등 2학년 읽기 속도 기준', '2024-01-01'),
('초3', 250, 251, 350, 351, 300, '초등 3학년 읽기 속도 기준', '2024-01-01'),
('초4', 300, 301, 400, 401, 350, '초등 4학년 읽기 속도 기준', '2024-01-01'),
('초5', 350, 351, 450, 451, 400, '초등 5학년 읽기 속도 기준', '2024-01-01'),
('초6', 400, 401, 500, 501, 450, '초등 6학년 읽기 속도 기준', '2024-01-01'),
('중1', 450, 451, 550, 551, 500, '중등 1학년 읽기 속도 기준', '2024-01-01'),
('중2', 500, 501, 600, 601, 550, '중등 2학년 읽기 속도 기준', '2024-01-01'),
('중3', 550, 551, 650, 651, 600, '중등 3학년 읽기 속도 기준', '2024-01-01');

-- ============================================
-- 10. 사용 예시
-- ============================================

/*
-- 1. 특정 사용자의 읽기 통계 조회
SELECT * FROM user_reading_statistics WHERE user_id = 1;

-- 2. 사용자 vs 학년 평균 비교
SELECT * FROM v_user_vs_grade_reading WHERE user_id = 1;

-- 3. 학년별 통계 갱신
CALL sp_update_grade_reading_statistics('초3', 'all');

-- 4. 사용자 읽기 수준 평가
CALL sp_evaluate_user_reading_level(1);

-- 5. 학년별 상위 10명
SELECT * FROM v_grade_top_readers 
WHERE grade = '초3' AND grade_rank <= 10;

-- 6. 학년 전체 통계
SELECT * FROM grade_reading_statistics 
WHERE grade = '초3' 
ORDER BY calculated_at DESC 
LIMIT 1;
*/

SELECT '✅ 통계 테이블 생성이 완료되었습니다!' AS status;