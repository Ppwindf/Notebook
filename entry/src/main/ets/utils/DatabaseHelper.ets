import relationalStore from '@ohos.data.relationalStore';
import { Diary, User, UserInfo, StoreConfig } from '../types/DiaryTypes';

export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly STORE_CONFIG: StoreConfig = {
    name: 'diary.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  private constructor() {}

  public static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  async initDatabase(): Promise<void> {
    try {
      const context = getContext();
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);
      await this.createTables();
    } catch (error) {
      console.error('数据库初始化失败:', error);
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;

    // 创建用户表
    const userTableSql = `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // 创建日记表
    const diaryTableSql = `
      CREATE TABLE IF NOT EXISTS diaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `;

    await this.rdbStore.executeSql(userTableSql);
    await this.rdbStore.executeSql(diaryTableSql);
  }

  // 用户相关操作
  async registerUser(username: string, password: string): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      const sql = 'INSERT INTO users (username, password) VALUES (?, ?)';
      await this.rdbStore.executeSql(sql, [username, password]);
      return true;
    } catch (error) {
      console.error('用户注册失败:', error);
      return false;
    }
  }

  async loginUser(username: string, password: string): Promise<number | null> {
    if (!this.rdbStore) return null;

    try {
      const sql = 'SELECT id FROM users WHERE username = ? AND password = ?';
      const resultSet = await this.rdbStore.querySql(sql, [username, password]);
      
      if (resultSet.goToFirstRow()) {
        return resultSet.getLong(resultSet.getColumnIndex('id'));
      }
      return null;
    } catch (error) {
      console.error('用户登录失败:', error);
      return null;
    }
  }

  async checkUsernameExists(username: string): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      const sql = 'SELECT COUNT(*) as count FROM users WHERE username = ?';
      const resultSet = await this.rdbStore.querySql(sql, [username]);
      
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(resultSet.getColumnIndex('count'));
        return count > 0;
      }
      return false;
    } catch (error) {
      console.error('检查用户名失败:', error);
      return false;
    }
  }

  // 修改密码
  async changePassword(userId: number, oldPassword: string, newPassword: string): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      // 首先验证旧密码
      const verifySql = 'SELECT id FROM users WHERE id = ? AND password = ?';
      const verifyResultSet = await this.rdbStore.querySql(verifySql, [userId, oldPassword]);
      
      if (!verifyResultSet.goToFirstRow()) {
        return false; // 旧密码不正确
      }

      // 更新密码
      const updateSql = 'UPDATE users SET password = ? WHERE id = ?';
      await this.rdbStore.executeSql(updateSql, [newPassword, userId]);
      return true;
    } catch (error) {
      console.error('修改密码失败:', error);
      return false;
    }
  }

  // 获取用户信息
  async getUserById(userId: number): Promise<UserInfo | null> {
    if (!this.rdbStore) return null;

    try {
      const sql = 'SELECT id, username, created_at FROM users WHERE id = ?';
      const resultSet = await this.rdbStore.querySql(sql, [userId]);
      
      if (resultSet.goToFirstRow()) {
        return {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          username: resultSet.getString(resultSet.getColumnIndex('username')),
          created_at: resultSet.getString(resultSet.getColumnIndex('created_at'))
        };
      }
      return null;
    } catch (error) {
      console.error('获取用户信息失败:', error);
      return null;
    }
  }

  // 日记相关操作
  async addDiary(userId: number, title: string, content: string): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      const sql = 'INSERT INTO diaries (user_id, title, content) VALUES (?, ?, ?)';
      await this.rdbStore.executeSql(sql, [userId, title, content]);
      return true;
    } catch (error) {
      console.error('添加日记失败:', error);
      return false;
    }
  }

  async getDiaries(userId: number): Promise<Diary[]> {
    if (!this.rdbStore) return [];

    try {
      const sql = 'SELECT id, title, content, created_at, updated_at FROM diaries WHERE user_id = ? ORDER BY updated_at DESC';
      const resultSet = await this.rdbStore.querySql(sql, [userId]);
      
      const diaries: Diary[] = [];
      if (resultSet.goToFirstRow()) {
        do {
          diaries.push({
            id: resultSet.getLong(resultSet.getColumnIndex('id')),
            title: resultSet.getString(resultSet.getColumnIndex('title')),
            content: resultSet.getString(resultSet.getColumnIndex('content')),
            created_at: resultSet.getString(resultSet.getColumnIndex('created_at')),
            updated_at: resultSet.getString(resultSet.getColumnIndex('updated_at'))
          });
        } while (resultSet.goToNextRow());
      }
      return diaries;
    } catch (error) {
      console.error('获取日记列表失败:', error);
      return [];
    }
  }

  async getDiaryById(diaryId: number): Promise<Diary | null> {
    if (!this.rdbStore) return null;

    try {
      const sql = 'SELECT id, title, content, created_at, updated_at FROM diaries WHERE id = ?';
      const resultSet = await this.rdbStore.querySql(sql, [diaryId]);
      
      if (resultSet.goToFirstRow()) {
        return {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          created_at: resultSet.getString(resultSet.getColumnIndex('created_at')),
          updated_at: resultSet.getString(resultSet.getColumnIndex('updated_at'))
        };
      }
      return null;
    } catch (error) {
      console.error('获取日记详情失败:', error);
      return null;
    }
  }

  async updateDiary(diaryId: number, title: string, content: string): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      const sql = 'UPDATE diaries SET title = ?, content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?';
      await this.rdbStore.executeSql(sql, [title, content, diaryId]);
      return true;
    } catch (error) {
      console.error('更新日记失败:', error);
      return false;
    }
  }

  async deleteDiary(diaryId: number): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      const sql = 'DELETE FROM diaries WHERE id = ?';
      await this.rdbStore.executeSql(sql, [diaryId]);
      return true;
    } catch (error) {
      console.error('删除日记失败:', error);
      return false;
    }
  }
}
