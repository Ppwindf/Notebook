import promptAction from '@ohos.promptAction';

export class ErrorHandler {

  // 处理数据库操作错误
  static handleDatabaseError(error: Error | null, operation: string) {
    console.error(`${operation}失败:`, error);
    promptAction.showToast({ 
      message: `${operation}失败，请重试`,
      duration: 2000
    });
  }

  // 处理网络错误
  static handleNetworkError(error: Error, operation: string) {
    console.error(`${operation}网络错误:`, error);
    promptAction.showToast({
      message: '网络连接失败，请检查网络设置',
      duration: 2000
    });
  }

  // 处理通用错误
  static handleGeneralError(error: Error, message: string) {
    console.error(`${message}:`, error);
    promptAction.showToast({ 
      message: message,
      duration: 2000
    });
  }

  // 显示成功消息
  static showSuccess(message: string) {
    promptAction.showToast({ 
      message: message,
      duration: 1000
    });
  }

  // 显示警告消息
  static showWarning(message: string) {
    promptAction.showToast({ 
      message: message,
      duration: 1500
    });
  }
}
