import { DatabaseHelper } from '../utils/DatabaseHelper';
import { ErrorHandler } from '../utils/ErrorHandler';
import { DiaryListParams } from '../types/DiaryTypes';
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State isLoginMode: boolean = true
  @State isLoading: boolean = false
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance()

  aboutToAppear() {
    this.dbHelper.initDatabase()
  }


  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#ff114a60')
      .width('100%')
      .height('100%')

      // 主要内容
      Column() {
        // 顶部标题
        Column() {
           Text(this.isLoginMode ? '欢迎回来' : '创建账户')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

           Text(this.isLoginMode ? '登录记事本' : '注册记事本')
            .fontSize(16)
             .fontColor(Color.Blue)
        }
        .margin({ top: 100, bottom: 30 })
        .alignItems(HorizontalAlign.Center)

        // 表单容器
        Column() {
          // 顶部分段切换
          Row() {
            Button('登录',{type: ButtonType.Normal})
              .buttonStyle(ButtonStyleMode.NORMAL)
              .layoutWeight(1)
              .height(40)
              .backgroundColor(this.isLoginMode ? '#0ea5e9' : '#f1f5f9')
              .fontColor(this.isLoginMode ? Color.White : '#0ea5e9')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                if (!this.isLoginMode) {
                  this.isLoginMode = true;
                  this.username = '';
                  this.password = '';
                }
              })

            Button('注册',{type: ButtonType.Normal})
              .buttonStyle(ButtonStyleMode.NORMAL)
              .layoutWeight(1)
              .height(40)
              .backgroundColor(!this.isLoginMode ? '#0ea5e9' : '#f1f5f9')
              .fontColor(!this.isLoginMode ? Color.White : '#0ea5e9')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                if (this.isLoginMode) {
                  this.isLoginMode = false;
                  this.username = '';
                  this.password = '';
                }
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 用户名输入
          Row() {
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .layoutWeight(1)
              .height(50)
              .backgroundColor('#f8fafc')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .onChange((value: string) => {
                this.username = value;
              })
              .border({ width: 1, color: '#e2e8f0' })
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 密码输入
          Row() {
            TextInput({ placeholder: '请输入密码', text: this.password })
              .layoutWeight(1)
              .height(50)
              .backgroundColor('#f8fafc')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.password = value;
              })
              .border({ width: 1, color: '#e2e8f0' })

          }
          .width('100%')
          .margin({ bottom: 24 })

          // 提交按钮
          Button(this.isLoginMode ? '登录' : '注册')
            .width('100%')
            .height(50)
            .backgroundColor('#0ea5e9')
            .borderRadius(12)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.handleSubmit();
            })
            .shadow({ radius: 8, color: '#0ea5e940', offsetX: 0, offsetY: 4 })
        }
        .width('85%')
        .padding(24)
        .backgroundColor('#ff0d2741')
        .borderRadius(20)
        .shadow({ radius: 20, color: '#00000020', offsetX: 0, offsetY: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  async handleSubmit() {
    if (!this.username.trim() || !this.password.trim()) {
      ErrorHandler.showWarning('请填写完整信息');
      return;
    }

    this.isLoading = true;

    try {
      if (this.isLoginMode) {
        // 登录逻辑
        const userId = await this.dbHelper.loginUser(this.username, this.password);
        if (userId) {
          ErrorHandler.showSuccess('登录成功');
          // 跳转到主页面
          router.replaceUrl({
            url: 'pages/MainPage',
            params: { userId: userId } as DiaryListParams
          });
        } else {
          ErrorHandler.showWarning('用户名或密码错误');
        }
      } else {
        // 注册逻辑
        const exists = await this.dbHelper.checkUsernameExists(this.username);
        if (exists) {
          ErrorHandler.showWarning('用户名已存在');
          return;
        }

        const success = await this.dbHelper.registerUser(this.username, this.password);
        if (success) {
          ErrorHandler.showSuccess('注册成功，请登录');
          this.isLoginMode = true;
          this.username = '';
          this.password = '';
        } else {
          ErrorHandler.handleDatabaseError(null, '注册');
        }
      }
    } catch (error) {
      ErrorHandler.handleGeneralError(error as Error, '操作失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }
}
