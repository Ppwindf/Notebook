// 日记数据类型定义
export interface Diary {
  id: number;
  title: string;
  content: string;
  created_at: string;
  updated_at: string;
}

// 用户数据类型定义
export interface User {
  id: number;
  username: string;
  password: string;
  created_at: string;
}

// 用户信息显示类型定义（不包含密码）
export interface UserInfo {
  id: number;
  username: string;
  created_at: string;
}

// 数据库配置类型
export interface StoreConfig {
  name: string;
  securityLevel: number;
}

// 路由参数类型定义
export interface DiaryListParams {
  userId: number;
}

export interface DiaryEditParams {
  userId: number;
  mode: 'add' | 'edit';
  diaryId?: number;
  title?: string;
  content?: string;
}
