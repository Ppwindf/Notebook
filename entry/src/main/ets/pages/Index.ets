import router from '@ohos.router';

@Entry
@Component
struct Index {

  @State countdown: number = 0
  private timerId: number = 0

  aboutToAppear(): void {
    this.countdown = 2
    this.timerId = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        this.stopCountdown()
      }
    }, 1000)
  }
  stopCountdown() {
    clearInterval(this.timerId)
    try {
      router.replaceUrl({
        url: 'pages/LoginPage'
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error('跳转登录页面失败: ', message);
    }
  }

  build() {
    RelativeContainer() {
      Column(){
        Button(this.countdown.toString(), {type: ButtonType.Circle})
          .width('38').height('38')
          .onClick(() =>{
            this.stopCountdown()
          })
          .backgroundColor(Color.Gray)
      }
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top},
        right: {anchor: '__container__', align: HorizontalAlign.End}
      })
      .margin(20)

      // 主要内容
      Column() {
        Column() {
          Text('时光笔记')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .margin({ bottom: 16 })
            .shadow({ radius: 10, color: '#00000030', offsetX: 0, offsetY: 4 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ff114a60')
  }
}