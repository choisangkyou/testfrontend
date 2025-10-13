import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { getHello } from '../api/helloApi';
import './HomePage.css';

const HomePage: React.FC = () => {
  const { user, logout } = useAuth();
  const [message, setMessage] = useState('');

  useEffect(() => {
    getHello().then(setMessage).catch(err => {
      console.error('API 호출 실패:', err);
      setMessage('메시지를 불러올 수 없습니다.');
    });
  }, []);

  const handleLogout = () => {
    logout();
  };

  return (
    <div className="home-container">
      <div className="home-card">
        <div className="header">
          <h1>환영합니다!</h1>
          <button onClick={handleLogout} className="logout-button">
            로그아웃
          </button>
        </div>
        
        <div className="user-info">
          <h3>사용자 정보</h3>
          <p><strong>사용자명:</strong> {user?.username}</p>
          {user?.email && <p><strong>이메일:</strong> {user.email}</p>}
          {user?.roles && user.roles.length > 0 && (
            <p><strong>권한:</strong> {user.roles.join(', ')}</p>
          )}
        </div>

        <div className="api-response">
          <h3>API 응답</h3>
          <p>{message || '로딩 중...'}</p>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
