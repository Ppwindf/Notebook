import { DatabaseHelper } from '../utils/DatabaseHelper';
import { ErrorHandler } from '../utils/ErrorHandler';
import { DiaryEditParams } from '../types/DiaryTypes';
import router from '@ohos.router';

@Entry
@Component
struct ChangePasswordPage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State userId: number = 0;
  @State pageOpacity: number = 0;
  @State formOpacity: number = 0;
  @State formTranslateY: number = 50;
  @State isLoading: boolean = false;
  
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  aboutToAppear() {
    const params = router.getParams() as DiaryEditParams;
    this.userId = params?.userId || 0;
    this.startAnimation();
  }

  startAnimation() {
    setTimeout(() => {
      animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
        this.pageOpacity = 1;
      });
    }, 200);

    setTimeout(() => {
      animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
        this.formOpacity = 1;
        this.formTranslateY = 0;
      });
    }, 400);
  }

  validateInputs(): string | null {
    if (!this.oldPassword.trim()) {
      return '请输入当前密码';
    }
    if (!this.newPassword.trim()) {
      return '请输入新密码';
    }
    if (this.newPassword.length < 6) {
      return '新密码长度不能少于6位';
    }
    if (this.newPassword === this.oldPassword) {
      return '新密码不能与当前密码相同';
    }
    if (this.newPassword !== this.confirmPassword) {
      return '两次输入的新密码不一致';
    }
    return null;
  }

  async handleChangePassword() {
    const error = this.validateInputs();
    if (error) {
      ErrorHandler.showWarning(error);
      return;
    }

    this.isLoading = true;
    try {
      const success = await this.dbHelper.changePassword(
        this.userId,
        this.oldPassword,
        this.newPassword
      );

      if (success) {
        ErrorHandler.showSuccess('密码修改成功');
        // 返回上一页
        router.back();
      } else {
        ErrorHandler.showWarning('当前密码不正确');
      }
    } catch (error) {
      ErrorHandler.handleDatabaseError(error as Error, '修改密码');
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#f8f9fa', 0.0], ['#e9ecef', 1.0]]
        })

      Column() {
        // 顶部导航栏
        Row() {
          Row() {
            Text('←')
              .fontSize(24)
              .fontColor('#06283D')
              .onClick(() => {
                router.back();
              })
            
            Text('修改密码')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#06283D')
              .margin({ left: 16 })
          }
          .layoutWeight(1)

          if (this.isLoading) {
            LoadingProgress()
              .color(Color.White)
              .width(20)
              .height(20)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })

        // 主内容区域
        Column() {
          // 标题
          Text('修改密码')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .margin({ bottom: 8 })

          Text('请输入当前密码和新密码')
            .fontSize(16)
            .fontColor('#2563eb')
            .margin({ bottom: 40 })

          // 表单内容
          Column() {
            // 当前密码
            Column() {
              Text('当前密码')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2c3e50')
                .margin({ bottom: 8 })
                .alignSelf(ItemAlign.Start)

              TextInput({ placeholder: '请输入当前密码', text: this.oldPassword })
                .width('100%')
                .height(50)
                .backgroundColor('#f8f9fa')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .fontSize(16)
                .fontColor('#2c3e50')
                .placeholderColor('#95a5a6')
                .onChange((value: string) => {
                  this.oldPassword = value;
                })
                .type(InputType.Password)
            }
            .margin({ bottom: 24 })

            // 新密码
            Column() {
              Text('新密码')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2c3e50')
                .margin({ bottom: 8 })
                .alignSelf(ItemAlign.Start)

              TextInput({ placeholder: '请输入新密码（至少6位）', text: this.newPassword })
                .width('100%')
                .height(50)
                .backgroundColor('#f8f9fa')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .fontSize(16)
                .fontColor('#2c3e50')
                .placeholderColor('#95a5a6')
                .onChange((value: string) => {
                  this.newPassword = value;
                })
                .type(InputType.Password)
            }
            .margin({ bottom: 24 })

            // 确认新密码
            Column() {
              Text('确认新密码')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2c3e50')
                .margin({ bottom: 8 })
                .alignSelf(ItemAlign.Start)

              TextInput({ placeholder: '请再次输入新密码', text: this.confirmPassword })
                .width('100%')
                .height(50)
                .backgroundColor('#f8f9fa')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .fontSize(16)
                .fontColor('#2c3e50')
                .placeholderColor('#95a5a6')
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
                .type(InputType.Password)
            }
            .margin({ bottom: 32 })

            // 修改密码按钮
            Button('修改密码', { type: ButtonType.Capsule })
              .width('100%')
              .height(50)
              .backgroundColor('#0ea5e9')
              .borderRadius(25)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .onClick(() => {
                this.handleChangePassword();
              })
              .enabled(!this.isLoading)

          }
          .width('100%')
          .padding(20)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 20, topRight: 20 })
        .padding({ top: 20 })
        .opacity(this.formOpacity)
        .translate({ y: this.formTranslateY })
      }
      .width('100%')
      .height('100%')
      .opacity(this.pageOpacity)
    }
    .width('100%')
    .height('100%')
  }
}
